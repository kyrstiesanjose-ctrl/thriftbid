<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$parentCat = trim($_GET['parent']   ?? ''); // e.g. 'Tops'
$catId     = (int)($_GET['cat']     ?? 0);  // specific category, e.g. 'Blouse'
$brandId   = (int)($_GET['brand']   ?? 0);
$q         = trim($_GET['q']        ?? '');
$sort      = $_GET['sort']          ?? 'newest';
$type      = $_GET['type']          ?? 'all';
$luxuryOnly = isset($_GET['luxury']);
$sizeVal   = trim($_GET['size']    ?? '');
$cond      = $_GET['condition']     ?? '';
$colorFilter    = trim($_GET['color']    ?? '');
$materialFilter = trim($_GET['material'] ?? '');
$genderFilter   = $_GET['gender']        ?? '';
$madeInFilter   = trim($_GET['made_in']  ?? '');
$page      = max(1, (int)($_GET['page'] ?? 1));
$per       = 16; $offset = ($page - 1) * $per;


$parentCats = DB::fetchAll('SELECT parent_category_id, parent_category FROM PARENT_CATEGORIES ORDER BY parent_category');
$categories = DB::fetchAll(
    $parentCat
        ? 'SELECT c.* FROM CATEGORIES c JOIN PARENT_CATEGORIES pc ON c.parent_category_id=pc.parent_category_id WHERE pc.parent_category=? ORDER BY c.name'
        : 'SELECT c.* FROM CATEGORIES c ORDER BY c.name',
    $parentCat ? [$parentCat] : []
);
$brands = DB::fetchAll('SELECT * FROM BRANDS ORDER BY brand_name');

// Sizes adapt to current scope: exact category sizes, union of sizes across a parent tab 
// (e.g. "Tops"), or all sizes for "All". Ensures dropdown is always usable before picking a subcategory.
if ($catId) {
    $sizesForCat = DB::fetchAll('SELECT DISTINCT size_value FROM CATEGORY_SIZES WHERE category_id=? ORDER BY size_value', [$catId]);
} elseif ($parentCat) {
    $sizesForCat = DB::fetchAll(
        'SELECT DISTINCT cs.size_value FROM CATEGORY_SIZES cs
         JOIN CATEGORIES c ON cs.category_id=c.category_id
         JOIN PARENT_CATEGORIES pc ON c.parent_category_id=pc.parent_category_id
         WHERE pc.parent_category=? ORDER BY cs.size_value',
        [$parentCat]
    );
} else {
    $sizesForCat = DB::fetchAll('SELECT DISTINCT size_value FROM CATEGORY_SIZES ORDER BY size_value');
}

$conditions = ['Brand New','Like New','Lightly Used','Well Used','Heavily Used'];

// Distinct values actually present in active listings, so the filter
// dropdowns never show an option with zero matching results.
$colorOptions    = DB::fetchAll('SELECT DISTINCT color FROM LISTINGS WHERE color IS NOT NULL AND is_active=1 ORDER BY color');
$materialOptions = DB::fetchAll('SELECT DISTINCT material FROM LISTINGS WHERE material IS NOT NULL AND is_active=1 ORDER BY material');
$madeInOptions   = DB::fetchAll('SELECT DISTINCT made_in FROM LISTINGS WHERE made_in IS NOT NULL AND is_active=1 ORDER BY made_in');
$genderOptions   = ['Women','Men','Unisex','Kids'];

$where  = 'l.is_active=1 AND l.deleted_at IS NULL'; $params = [];
if ($catId)     { $where .= ' AND l.category_id=?'; $params[] = $catId; }
elseif ($parentCat) { $where .= ' AND l.category_id IN (SELECT category_id FROM CATEGORIES WHERE parent_category_id=(SELECT parent_category_id FROM PARENT_CATEGORIES WHERE parent_category=?))'; $params[] = $parentCat; }
if ($brandId)   { $where .= ' AND pl.brand_id=?'; $params[] = $brandId; }
if ($q)         { $where .= ' AND (l.title LIKE ? OR l.description LIKE ? OR b.brand_name LIKE ?)'; $params = array_merge($params, ["%$q%", "%$q%", "%$q%"]); }
if ($type === 'fixed')   $where .= ' AND l.listing_id NOT IN (SELECT listing_id FROM AUCTIONS WHERE status="Active")';
if ($type === 'auction') $where .= ' AND l.listing_id IN (SELECT listing_id FROM AUCTIONS WHERE status="Active")';

// Filter by tier "High" for luxury. Safe because listings only become active 
// (is_active=1) after admin approval via `after_authentication_status_change` 

if ($luxuryOnly) $where .= ' AND pl.tier="High"';
if ($sizeVal)   { $where .= ' AND l.size_id IN (SELECT size_id FROM CATEGORY_SIZES WHERE size_value=?)'; $params[] = $sizeVal; }
if ($cond)      { $where .= ' AND l.condition_grade=?'; $params[] = $cond; }
if ($colorFilter)    { $where .= ' AND l.color=?'; $params[] = $colorFilter; }
if ($materialFilter) { $where .= ' AND l.material=?'; $params[] = $materialFilter; }
if ($genderFilter)   { $where .= ' AND l.target_gender=?'; $params[] = $genderFilter; }
if ($madeInFilter)   { $where .= ' AND l.made_in=?'; $params[] = $madeInFilter; }

$orderBy = match($sort) {
    'price_asc'  => 'l.price ASC',
    'price_desc' => 'l.price DESC',
    'ending'     => 'a.end_time ASC',
    default      => 'l.created_at DESC',
};

$baseFrom = 'FROM LISTINGS l
     JOIN CATEGORIES c2 ON l.category_id=c2.category_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     JOIN BRANDS b ON pl.brand_id=b.brand_id
     LEFT JOIN AUCTIONS a ON l.listing_id=a.listing_id AND a.status="Active"
     JOIN SELLER s ON l.seller_id=s.seller_id';

$total = DB::fetch("SELECT COUNT(*) c $baseFrom WHERE $where", $params)['c'] ?? 0;

$listings = DB::fetchAll(
    "SELECT l.*, c2.name AS cat_name, b.brand_name, pl.tier,
            a.auction_id, a.end_time, a.current_highest_bid, COALESCE(s.shop_name, s.username) AS seller_name,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
     $baseFrom
     WHERE $where ORDER BY $orderBy LIMIT $per OFFSET $offset",
    $params
);
$totalPages = max(1, ceil($total / $per));
$activeCatName = $catId ? DB::fetch('SELECT name FROM CATEGORIES WHERE category_id=?', [$catId])['name'] ?? null : null;

renderHead('Browse - ' . ($activeCatName ?: ($parentCat ?: 'All Items')));
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('categories'); ?>

<!-- Parent category tabs -->
<div style="background:var(--clr-white);border-bottom:1px solid var(--clr-outline);position:sticky;top:56px;z-index:100">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:0 var(--sp-margin-desktop)">
    <div class="tb-tabs">
      <a href="categories.php" class="tb-tab-link <?= !$parentCat && !$catId && !$q ? 'active' : '' ?>">All</a>
      <?php foreach ($parentCats as $pc): $name = $pc['parent_category']; ?>
      <a href="categories.php?parent=<?= urlencode($name) ?>" class="tb-tab-link <?= $parentCat === $name ? 'active' : '' ?>"><?= htmlspecialchars($name) ?></a>
      <?php endforeach; ?>
    </div>
  </div>
</div>

<main style="flex:1">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px">

    <div style="display:flex;flex-direction:column;gap:16px;margin-bottom:24px">
      <div style="display:flex;align-items:flex-end;justify-content:space-between;flex-wrap:wrap;gap:12px">
        <div>
          <h1 class="tb-page-title"><?= $q ? 'Search: "'.htmlspecialchars($q).'"' : ($activeCatName ?: ($parentCat ?: 'All Items')) ?></h1>
          <p class="tb-page-subtitle"><?= number_format($total) ?> item<?= $total !== 1 ? 's' : '' ?> found</p>
        </div>
      </div>

      <!-- Filter bar -->
      <form method="GET" class="tb-filter-bar">
        <?php if ($parentCat): ?><input type="hidden" name="parent" value="<?= htmlspecialchars($parentCat) ?>"><?php endif; ?>

        <div style="position:relative;flex:1;min-width:200px;max-width:280px">
          <span class="material-symbols-outlined icon-sm" style="position:absolute;left:9px;top:50%;transform:translateY(-50%);color:var(--clr-tertiary)">search</span>
          <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Search items or brands..." class="tb-input" style="padding-left:32px;font-size:var(--fs-label-md)">
        </div>

        <!-- Specific category (dependent on parent, but shows all if no parent picked) -->
        <select name="cat" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Categories</option>
          <?php foreach ($categories as $c): ?>
          <option value="<?= $c['category_id'] ?>" <?= $catId==$c['category_id']?'selected':'' ?>><?= htmlspecialchars($c['name']) ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Brand -->
        <select name="brand" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Brands</option>
          <?php foreach ($brands as $b): ?>
          <option value="<?= $b['brand_id'] ?>" <?= $brandId==$b['brand_id']?'selected':'' ?>><?= htmlspecialchars($b['brand_name']) ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Type -->
        <select name="type" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="all"     <?= $type==='all'?'selected':'' ?>>All Types</option>
          <option value="fixed"   <?= $type==='fixed'?'selected':'' ?>>Buy Now</option>
          <option value="auction" <?= $type==='auction'?'selected':'' ?>>Auction</option>
        </select>

        <!-- Size: available at any browsing level (category, parent tab, or All) -->
        <select name="size" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Sizes</option>
          <?php foreach ($sizesForCat as $sz): ?>
          <option value="<?= htmlspecialchars($sz['size_value']) ?>" <?= $sizeVal===$sz['size_value']?'selected':'' ?>><?= htmlspecialchars($sz['size_value']) ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Condition -->
        <select name="condition" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Conditions</option>
          <?php foreach ($conditions as $cd): ?>
          <option value="<?= $cd ?>" <?= $cond===$cd?'selected':'' ?>><?= $cd ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Color -->
        <select name="color" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Colors</option>
          <?php foreach ($colorOptions as $co): ?>
          <option value="<?= htmlspecialchars($co['color']) ?>" <?= $colorFilter===$co['color']?'selected':'' ?>><?= htmlspecialchars($co['color']) ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Material -->
        <select name="material" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Materials</option>
          <?php foreach ($materialOptions as $mo): ?>
          <option value="<?= htmlspecialchars($mo['material']) ?>" <?= $materialFilter===$mo['material']?'selected':'' ?>><?= htmlspecialchars($mo['material']) ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Gender -->
        <select name="gender" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Genders</option>
          <?php foreach ($genderOptions as $ge): ?>
          <option value="<?= $ge ?>" <?= $genderFilter===$ge?'selected':'' ?>><?= $ge ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Made In -->
        <select name="made_in" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Countries</option>
          <?php foreach ($madeInOptions as $mi): ?>
          <option value="<?= htmlspecialchars($mi['made_in']) ?>" <?= $madeInFilter===$mi['made_in']?'selected':'' ?>><?= htmlspecialchars($mi['made_in']) ?></option>
          <?php endforeach; ?>
        </select>

        <!-- Sort -->
        <select name="sort" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="newest"     <?= $sort==='newest'?'selected':'' ?>>Newest First</option>
          <option value="price_asc"  <?= $sort==='price_asc'?'selected':'' ?>>Price: Low–High</option>
          <option value="price_desc" <?= $sort==='price_desc'?'selected':'' ?>>Price: High–Low</option>
          <option value="ending"     <?= $sort==='ending'?'selected':'' ?>>Ending Soonest</option>
        </select>

        <!-- Luxury only -->
        <label style="display:flex;align-items:center;gap:6px;padding:0 10px;border:1px solid var(--clr-outline);border-radius:var(--radius-sm);height:38px;cursor:pointer;background:<?= $luxuryOnly ? '#1a1a1a' : 'var(--clr-white)' ?>;color:<?= $luxuryOnly ? '#fff' : 'var(--clr-text)' ?>">
          <input type="checkbox" name="luxury" value="1" <?= $luxuryOnly?'checked':'' ?> onchange="this.form.submit()" style="accent-color:var(--clr-coral)">
          <span class="material-symbols-outlined icon-sm">verified</span>
          <span style="font-size:var(--fs-label-sm);font-weight:600">Luxury Only</span>
        </label>

        <button type="submit" class="btn btn-primary btn-sm">Apply</button>
        <?php if ($q || $sizeVal || $cond || $catId || $brandId || $type !== 'all' || $parentCat || $luxuryOnly || $colorFilter || $materialFilter || $genderFilter || $madeInFilter): ?>
        <a href="categories.php" class="btn btn-ghost btn-sm">Clear</a>
        <?php endif; ?>
      </form>
    </div>

    <!-- Grid -->
    <?php if (empty($listings)): ?>
    <div style="text-align:center;padding:64px 20px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
      <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">search_off</span>
      <p style="font-weight:700;font-size:var(--fs-headline-sm)">No items found</p>
      <p style="margin-top:6px;font-size:var(--fs-label-md)">Try adjusting your filters or search term.</p>
      <a href="categories.php" class="btn btn-outline" style="margin-top:20px">Clear All Filters</a>
    </div>
    <?php else: ?>
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      <?php foreach ($listings as $l): ?>
      <div class="tb-listing-card">
        <div class="tb-listing-thumb">
          <?php if ($l['cover_image']): ?>
          <img src="<?= htmlspecialchars($l['cover_image']) ?>" alt="<?= htmlspecialchars($l['title']) ?>">
          <?php else: ?>
          <span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span>
          <?php endif; ?>
          <?php if ($l['auction_id']): ?>
          <span class="tb-badge-float top-left" style="background:var(--badge-live-bg);color:var(--badge-live-text)">Live</span>
          <?php endif; ?>
          <?php if ($l['tier'] === 'High'): ?>
          <span class="tb-badge-float top-right" style="background:#1a1a1a;color:#fff">Luxury</span>
          <?php endif; ?>
        </div>
        <div class="tb-listing-body">
          <div class="tb-listing-title"><?= htmlspecialchars($l['title']) ?></div>
          <p style="font-size:10px;color:var(--clr-tertiary)"><?= htmlspecialchars($l['brand_name']) ?></p>
          <?php if ($l['auction_id']): ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['current_highest_bid']) ?></div>
          <div class="tb-listing-meta">Bid &bull; Ends <?= formatTimeLeft($l['end_time']) ?></div>
          <?php else: ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['price']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= htmlspecialchars($l['condition_grade']) ?></div>
          <?php endif; ?>
          <div class="tb-listing-cta">
            <?php if ($l['auction_id']): ?>
            <a href="auction_room.php?id=<?= $l['auction_id'] ?>" class="btn btn-yellow btn-sm btn-full">Join Bid</a>
            <?php else: ?>
            <a href="listing.php?id=<?= $l['listing_id'] ?>" class="btn btn-primary btn-sm btn-full">View Item</a>
            <?php endif; ?>
          </div>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>

    <!-- Pagination -->
    <?php if ($totalPages > 1): ?>
    <div class="tb-table-wrapper" style="margin-top:28px;border:none">
      <div class="tb-pagination">
        <p class="tb-pagination-info">Showing <?= $offset+1 ?>–<?= min($offset+$per,$total) ?> of <?= number_format($total) ?></p>
        <div class="tb-pagination-btns">
          <?php if ($page > 1): ?><a href="?<?= http_build_query(array_merge($_GET,['page'=>$page-1])) ?>" class="tb-pagination-btn">Previous</a><?php endif; ?>
          <?php for ($p = max(1,$page-2); $p <= min($totalPages,$page+2); $p++): ?>
          <a href="?<?= http_build_query(array_merge($_GET,['page'=>$p])) ?>" class="tb-pagination-btn <?= $p===$page?'active':'' ?>"><?= $p ?></a>
          <?php endfor; ?>
          <?php if ($page < $totalPages): ?><a href="?<?= http_build_query(array_merge($_GET,['page'=>$page+1])) ?>" class="tb-pagination-btn">Next</a><?php endif; ?>
        </div>
      </div>
    </div>
    <?php endif; ?>

  </div>
</main>
<?php renderFooter(); ?>
</body></html>