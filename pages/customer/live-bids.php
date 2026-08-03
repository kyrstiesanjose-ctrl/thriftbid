<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

// --- MULTI-CURRENCY SUPPORT ---
if (isset($_GET['set_currency']) && in_array($_GET['set_currency'], ['PHP','USD','KRW'])) {
    $_SESSION['pref_currency'] = $_GET['set_currency'];
    $qs = $_GET; unset($qs['set_currency']);
    header('Location: ?' . http_build_query($qs)); exit;
}
$prefCur = $_SESSION['pref_currency'] ?? 'PHP';
$liveRates = getLiveCurrencyRates();

function getConversionRate(string $baseCur, string $prefCur, array $rates): float {
    $inPhp = $baseCur === 'PHP' ? 1.0 : 1.0 / ($rates[$baseCur] ?? 1.0);
    return $prefCur === 'PHP' ? $inPhp : $inPhp * ($rates[$prefCur] ?? 1.0);
}
function formatPriceMulti(float $amount, string $baseCur, string $prefCur, array $rates): string {
    $rate = getConversionRate($baseCur, $prefCur, $rates);
    $converted = $amount * $rate;
    $syms = ['PHP'=>'₱', 'USD'=>'$', 'KRW'=>'₩'];
    return $syms[$prefCur] . number_format($converted, $prefCur === 'KRW' ? 0 : 2);
}
// ------------------------------

$q         = trim($_GET['q']        ?? '');
$catId     = (int)($_GET['cat']     ?? 0);
$brandId   = (int)($_GET['brand']   ?? 0);
$sizeVal   = trim($_GET['size']     ?? '');
$cond      = $_GET['condition']     ?? '';
$colorFilter    = trim($_GET['color']    ?? '');
$materialFilter = trim($_GET['material'] ?? '');
$genderFilter   = $_GET['gender']        ?? '';
$madeInFilter   = trim($_GET['made_in']  ?? '');
$sort      = $_GET['sort']          ?? 'ending';
$luxuryOnly = isset($_GET['luxury']);

$categories = DB::fetchAll('SELECT * FROM CATEGORIES ORDER BY name');
$brands     = DB::fetchAll('SELECT * FROM BRANDS ORDER BY brand_name');
$sizesAll   = DB::fetchAll('SELECT DISTINCT size_value FROM CATEGORY_SIZES ORDER BY size_value');
$conditions = ['Brand New','Like New','Lightly Used','Well Used','Heavily Used'];
$colorOptions    = DB::fetchAll('
    SELECT DISTINCT c.color_name AS color 
    FROM COLORS c 
    JOIN LISTING_COLORS lc ON c.color_id = lc.color_id 
    JOIN LISTINGS l ON lc.listing_id = l.listing_id 
    WHERE l.is_active = 1 
    ORDER BY c.color_name
');

$materialOptions = DB::fetchAll('
    SELECT DISTINCT m.material_name AS material 
    FROM MATERIALS m 
    JOIN LISTING_MATERIALS lm ON m.material_id = lm.material_id 
    JOIN LISTINGS l ON lm.listing_id = l.listing_id 
    WHERE l.is_active = 1 
    ORDER BY m.material_name
');
$madeInOptions   = DB::fetchAll('SELECT DISTINCT made_in FROM LISTINGS WHERE made_in IS NOT NULL AND is_active=1 ORDER BY made_in');
$genderOptions   = ['Women','Men','Unisex','Kids'];

$where  = 'a.status="Active" AND a.end_time>NOW() AND l.deleted_at IS NULL';
$params = [];
if ($q !== '') {
    $where .= ' AND (l.title LIKE ? OR s.username LIKE ? OR s.shop_name LIKE ?)';
    $like = "%$q%"; $params[] = $like; $params[] = $like; $params[] = $like;
}
if ($catId)   { $where .= ' AND l.category_id=?'; $params[] = $catId; }
if ($brandId) { $where .= ' AND pl.brand_id=?'; $params[] = $brandId; }
if ($sizeVal !== '') { $where .= ' AND cs.size_value=?'; $params[] = $sizeVal; }
if ($cond !== '') { $where .= ' AND l.condition_grade=?'; $params[] = $cond; }
if ($colorFilter !== '') { 
    $where .= ' AND l.listing_id IN (SELECT lc.listing_id FROM LISTING_COLORS lc JOIN COLORS c ON lc.color_id = c.color_id WHERE c.color_name=?)'; 
    $params[] = $colorFilter; 
}
if ($materialFilter !== '') { 
    $where .= ' AND l.listing_id IN (SELECT lm.listing_id FROM LISTING_MATERIALS lm JOIN MATERIALS m ON lm.material_id = m.material_id WHERE m.material_name=?)'; 
    $params[] = $materialFilter; 
}
if ($genderFilter !== '') { $where .= ' AND l.target_gender=?'; $params[] = $genderFilter; }
if ($madeInFilter !== '') { $where .= ' AND l.made_in=?'; $params[] = $madeInFilter; }
if ($luxuryOnly) { $where .= ' AND pl.tier="High"'; } /* Rule 15: is_active=1 only after admin authentication approval, so pl.tier alone is a safe filter here */

$orderBy = match ($sort) {
    'highest_bid' => 'a.current_highest_bid DESC',
    'most_bids'   => 'bid_count DESC',
    'newest'      => 'l.created_at DESC',
    default       => 'a.end_time ASC', /* 'ending' - soonest first */
};

$auctions = DB::fetchAll(
    "SELECT a.*, l.title, l.description, l.condition_grade, l.listing_id, l.base_currency,
            c.name AS cat_name, COALESCE(s.shop_name, s.username) AS seller_name, s.seller_id,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id AND is_deleted=0) AS bid_count
     FROM AUCTIONS a
     JOIN LISTINGS l   ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s     ON l.seller_id=s.seller_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     LEFT JOIN CATEGORY_SIZES cs ON l.size_id=cs.size_id
     WHERE $where
     GROUP BY a.auction_id
     ORDER BY $orderBy",
    $params
);

renderHead('Live Auctions');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('livebids'); ?>

<!-- Currency Selection Strip -->
<div style="background:var(--clr-surface-mid); border-bottom:1px solid var(--clr-outline);">
  <div style="display:flex; justify-content: flex-end; padding: 10px var(--sp-margin-desktop); max-width: var(--sp-container); margin: 0 auto;">
    <form method="GET" style="display:inline-flex; align-items:center; gap:8px;">
      <?php foreach($_GET as $k=>$v): if($k!=='set_currency'): ?>
      <input type="hidden" name="<?=htmlspecialchars($k)?>" value="<?=htmlspecialchars($v)?>">
      <?php endif; endforeach; ?>
      <label style="font-size:var(--fs-label-sm); color:var(--clr-tertiary); font-weight:600;">Preferred Currency:</label>
      <select name="set_currency" onchange="this.form.submit()" class="tb-input" style="width:auto; padding:4px 8px; font-size:var(--fs-label-sm);">
        <option value="PHP" <?=$prefCur==='PHP'?'selected':''?>>PHP (₱)</option>
        <option value="USD" <?=$prefCur==='USD'?'selected':''?>>USD ($)</option>
        <option value="KRW" <?=$prefCur==='KRW'?'selected':''?>>KRW (₩)</option>
      </select>
    </form>
  </div>
</div>

<!-- Hero strip -->
<div style="padding:24px var(--sp-margin-desktop)">
  <div style="max-width:var(--sp-container);margin:0 auto;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:14px">
    <div>
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);color:var(--clr-text);font-weight:800">Live Bidding Room</h1>
      <p style="color:var(--clr-tertiary);margin-top:4px;font-size:var(--fs-label-md)">Place bids before time runs out.</p>
    </div>
    <a href="categories.php?type=auction" class="btn btn-outline">Browse All Auctions</a>
  </div>
</div>

<main style="flex:1">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:0 var(--sp-margin-desktop) 80px">

    <!-- Filter bar -->
    <form method="GET" class="tb-filter-bar">
      <div style="position:relative;flex:1;min-width:200px;max-width:280px">
        <span class="material-symbols-outlined icon-sm" style="position:absolute;left:9px;top:50%;transform:translateY(-50%);color:var(--clr-tertiary)">search</span>
        <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Search auctions or sellers..." class="tb-input" style="padding-left:32px;font-size:var(--fs-label-md)">
      </div>

      <select name="cat" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Categories</option>
        <?php foreach ($categories as $c): ?>
        <option value="<?= $c['category_id'] ?>" <?= $catId==$c['category_id']?'selected':'' ?>><?= htmlspecialchars($c['name']) ?></option>
        <?php endforeach; ?>
      </select>

      <select name="brand" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Brands</option>
        <?php foreach ($brands as $b): ?>
        <option value="<?= $b['brand_id'] ?>" <?= $brandId==$b['brand_id']?'selected':'' ?>><?= htmlspecialchars($b['brand_name']) ?></option>
        <?php endforeach; ?>
      </select>

      <select name="size" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Sizes</option>
        <?php foreach ($sizesAll as $sz): ?>
        <option value="<?= htmlspecialchars($sz['size_value']) ?>" <?= $sizeVal===$sz['size_value']?'selected':'' ?>><?= htmlspecialchars($sz['size_value']) ?></option>
        <?php endforeach; ?>
      </select>

      <select name="condition" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Conditions</option>
        <?php foreach ($conditions as $cd): ?>
        <option value="<?= $cd ?>" <?= $cond===$cd?'selected':'' ?>><?= $cd ?></option>
        <?php endforeach; ?>
      </select>

      <select name="color" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Colors</option>
        <?php foreach ($colorOptions as $co): ?>
        <option value="<?= htmlspecialchars($co['color']) ?>" <?= $colorFilter===$co['color']?'selected':'' ?>><?= htmlspecialchars($co['color']) ?></option>
        <?php endforeach; ?>
      </select>

      <select name="material" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Materials</option>
        <?php foreach ($materialOptions as $mo): ?>
        <option value="<?= htmlspecialchars($mo['material']) ?>" <?= $materialFilter===$mo['material']?'selected':'' ?>><?= htmlspecialchars($mo['material']) ?></option>
        <?php endforeach; ?>
      </select>

      <select name="gender" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Genders</option>
        <?php foreach ($genderOptions as $ge): ?>
        <option value="<?= $ge ?>" <?= $genderFilter===$ge?'selected':'' ?>><?= $ge ?></option>
        <?php endforeach; ?>
      </select>

      <select name="made_in" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="">All Countries</option>
        <?php foreach ($madeInOptions as $mi): ?>
        <option value="<?= htmlspecialchars($mi['made_in']) ?>" <?= $madeInFilter===$mi['made_in']?'selected':'' ?>><?= htmlspecialchars($mi['made_in']) ?></option>
        <?php endforeach; ?>
      </select>

      <select name="sort" class="tb-input" style="width:auto" onchange="this.form.submit()">
        <option value="ending"      <?= $sort==='ending'?'selected':'' ?>>Ending Soonest</option>
        <option value="highest_bid" <?= $sort==='highest_bid'?'selected':'' ?>>Highest Bid</option>
        <option value="most_bids"   <?= $sort==='most_bids'?'selected':'' ?>>Most Bids</option>
        <option value="newest"      <?= $sort==='newest'?'selected':'' ?>>Newest First</option>
      </select>

      <label style="display:flex;align-items:center;gap:6px;padding:0 10px;border:1px solid var(--clr-outline);border-radius:var(--radius-sm);height:38px;cursor:pointer;background:<?= $luxuryOnly ? '#1a1a1a' : 'var(--clr-white)' ?>;color:<?= $luxuryOnly ? '#fff' : 'var(--clr-text)' ?>">
        <input type="checkbox" name="luxury" value="1" <?= $luxuryOnly?'checked':'' ?> onchange="this.form.submit()" style="accent-color:var(--clr-coral)">
        <span class="material-symbols-outlined icon-sm">verified</span>
        <span style="font-size:var(--fs-label-sm);font-weight:600">Luxury Only</span>
      </label>

      <button type="submit" class="btn btn-primary btn-sm">Apply</button>
      <?php if ($q || $catId || $brandId || $sizeVal || $cond || $colorFilter || $materialFilter || $genderFilter || $madeInFilter || $luxuryOnly || $sort !== 'ending'): ?>
      <a href="live-bids.php" class="btn btn-ghost btn-sm">Clear</a>
      <?php endif; ?>
    </form>

    <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin:16px 0"><?= count($auctions) ?> live auction<?= count($auctions)!==1?'s':'' ?> found</p>

    <?php if (empty($auctions)): ?>
    <div style="text-align:center;padding:64px 20px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
      <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">gavel</span>
      <p style="font-weight:700;font-size:var(--fs-headline-sm)">No live auctions match these filters</p>
      <p style="margin-top:6px">Try widening your search, or check back soon for new auctions.</p>
      <a href="live-bids.php" class="btn btn-outline" style="margin-top:20px">Clear Filters</a>
    </div>
    <?php else: ?>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
      <?php foreach ($auctions as $a):
        $isUrgent  = (strtotime($a['end_time']) - time()) < 3600;
        $timeLeft  = formatTimeLeft($a['end_time']);
        $baseCur   = $a['base_currency'] ?? 'PHP';
      ?>
      <div class="tb-card" style="display:flex;flex-direction:column;transition:box-shadow var(--transition)">
        <!-- Image -->
        <div style="position:relative;aspect-ratio:4/3;background:var(--clr-surface-mid);display:flex;align-items:center;justify-content:center;overflow:hidden">
          <?php if ($a['cover_image']): ?>
          <img src="<?= htmlspecialchars($a['cover_image']) ?>" alt="<?= htmlspecialchars($a['title']) ?>" style="width:100%;height:100%;object-fit:cover">
          <?php else: ?>
          <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline)">checkroom</span>
          <?php endif; ?>
          <?php if ($isUrgent): ?>
          <span class="tb-badge-float top-left" style="background:var(--clr-error);color:#fff">Ending Soon</span>
          <?php else: ?>
          <span class="tb-badge-float top-left" style="background:var(--badge-live-bg);color:var(--badge-live-text)">Live</span>
          <?php endif; ?>
        </div>

        <!-- Body -->
        <div style="padding:16px 18px;flex:1;display:flex;flex-direction:column;gap:10px">
          <div>
            <span class="tb-badge tb-badge-gray" style="margin-bottom:6px"><?= htmlspecialchars($a['cat_name']) ?></span>
            <h3 style="font-weight:700;font-size:var(--fs-body-md);color:var(--clr-text);line-height:1.3;margin-bottom:2px"><?= htmlspecialchars($a['title']) ?></h3>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
              by <a href="seller_profile.php?id=<?= $a['seller_id'] ?>" style="color:var(--clr-coral);font-weight:600"><?= htmlspecialchars($a['seller_name']) ?></a>
              &bull; <?= htmlspecialchars($a['condition_grade']) ?>
            </p>
          </div>

          <!-- Stats row -->
          <div class="grid grid-cols-2 gap-2" style="background:var(--clr-bg);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:10px 12px">
            <div>
              <p style="font-size:10px;font-weight:700;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:2px">Current Bid</p>
              <p style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:800;color:var(--clr-text)">
                <?= formatPriceMulti((float)$a['current_highest_bid'], $baseCur, $prefCur, $liveRates) ?>
              </p>
            </div>
            <div>
              <p style="font-size:10px;font-weight:700;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:2px">Time Left</p>
              <p style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-label-md);font-weight:800;color:<?= $isUrgent?'var(--clr-error)':'var(--clr-coral)' ?>" data-end="<?= strtotime($a['end_time']) ?>"><?= $timeLeft ?></p>
            </div>
          </div>

          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $a['bid_count'] ?> bid<?= $a['bid_count']!==1?'s':'' ?> &bull; Min. increment: <?= formatPriceMulti((float)$a['min_increment'], $baseCur, $prefCur, $liveRates) ?></p>

          <a href="auction_room.php?id=<?= $a['auction_id'] ?>" class="btn btn-yellow btn-full" style="margin-top:auto">
            <span class="material-symbols-outlined icon-sm">gavel</span>Join Bid
          </a>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>

  </div>
</main>
<?php renderFooter(); ?>
<script>
document.querySelectorAll('[data-end]').forEach(el => {
  function upd() {
    const d = parseInt(el.dataset.end) - Math.floor(Date.now()/1000);
    if (d <= 0) { el.textContent='Ended'; el.style.color='var(--clr-tertiary)'; return; }
    const h=Math.floor(d/3600),m=Math.floor((d%3600)/60),s=d%60;
    const hh=Math.floor((d%86400)/3600); /* remainder hours within the current day, for the "Xd Yh Zm" format below */
    el.textContent = d>=86400 ? Math.floor(d/86400)+'d '+hh+'h '+m+'m'
                               : String(h).padStart(2,'0')+':'+String(m).padStart(2,'0')+':'+String(s).padStart(2,'0');
    if (d<3600) el.style.color='var(--clr-error)';
  }
  setInterval(upd,1000); upd();
});
</script>
</body></html>