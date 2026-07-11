<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$catId    = (int)($_GET['cat']       ?? 0);
$q        = trim($_GET['q']          ?? '');
$sort     = $_GET['sort']            ?? 'newest';
$type     = $_GET['type']            ?? 'all';
$size     = $_GET['size']            ?? '';
$cond     = $_GET['condition']       ?? '';
$page     = max(1, (int)($_GET['page'] ?? 1));
$per      = 16; $offset = ($page - 1) * $per;

$categories = DB::fetchAll('SELECT * FROM CATEGORIES ORDER BY category_id');


$where  = 'l.is_active=1'; $params = [];
if ($catId) { $where .= ' AND l.category_id=?'; $params[] = $catId; }
if ($q)     { $where .= ' AND (l.title LIKE ? OR l.description LIKE ?)'; $params = array_merge($params, ["%$q%", "%$q%"]); }
if ($type === 'fixed')   $where .= ' AND l.listing_id NOT IN (SELECT listing_id FROM AUCTIONS WHERE status="Active")';
if ($type === 'auction') $where .= ' AND l.listing_id IN (SELECT listing_id FROM AUCTIONS WHERE status="Active")';
if ($size)  { $where .= ' AND l.size=?'; $params[] = $size; }
if ($cond)  { $where .= ' AND l.item_condition=?'; $params[] = $cond; }

$orderBy = match($sort) {
    'price_asc'  => 'l.price ASC',
    'price_desc' => 'l.price DESC',
    'ending'     => 'a.end_time ASC',
    default      => 'l.created_at DESC',
};

$total    = DB::fetch("SELECT COUNT(*) c FROM LISTINGS l LEFT JOIN AUCTIONS a ON l.listing_id=a.listing_id AND a.status='Active' WHERE $where", $params)['c'] ?? 0;
$listings = DB::fetchAll(
    "SELECT l.*, c2.name as cat_name, a.auction_id, a.end_time, a.current_highest_bid, u.username as seller_name, s.seller_id
     FROM LISTINGS l
     JOIN CATEGORIES c2 ON l.category_id=c2.category_id
     LEFT JOIN AUCTIONS a ON l.listing_id=a.listing_id AND a.status='Active'
     JOIN SELLER s ON l.seller_id=s.seller_id
     JOIN USERS u ON s.user_id=u.user_id
     WHERE $where ORDER BY $orderBy LIMIT $per OFFSET $offset",
    $params
);
$totalPages = max(1, ceil($total / $per));
$activeCat  = $catId ? DB::fetch('SELECT name FROM CATEGORIES WHERE category_id=?', [$catId]) : null;

renderHead('Browse — ' . ($activeCat ? $activeCat['name'] : 'All Items'));
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('categories'); ?>

<!-- Category tabs -->
<div style="background:var(--clr-white);border-bottom:1px solid var(--clr-outline);position:sticky;top:56px;z-index:100">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:0 var(--sp-margin-desktop)">
    <div class="tb-tabs">
      <a href="categories.php" class="tb-tab-link <?= !$catId && !$q ? 'active' : '' ?>">All</a>
      <?php foreach ($categories as $c): ?>
      <a href="categories.php?cat=<?= $c['category_id'] ?>" class="tb-tab-link <?= $catId == $c['category_id'] ? 'active' : '' ?>"><?= htmlspecialchars($c['name']) ?></a>
      <?php endforeach; ?>
    </div>
  </div>
</div>

<main style="flex:1">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px">

    <!-- Title + filter bar -->
    <div style="display:flex;flex-direction:column;gap:16px;margin-bottom:24px">
      <div style="display:flex;align-items:flex-end;justify-content:space-between;flex-wrap:wrap;gap:12px">
        <div>
          <h1 class="tb-page-title"><?= $q ? 'Search: "'.htmlspecialchars($q).'"' : ($activeCat ? htmlspecialchars($activeCat['name']) : 'All Items') ?></h1>
          <p class="tb-page-subtitle"><?= number_format($total) ?> item<?= $total !== 1 ? 's' : '' ?> found</p>
        </div>
      </div>

      <!-- Filter bar -->
      <form method="GET" class="tb-filter-bar">
        <?php if ($catId): ?><input type="hidden" name="cat" value="<?= $catId ?>"><?php endif; ?>
        <!-- Search -->
        <div style="position:relative;flex:1;min-width:200px;max-width:280px">
          <span class="material-symbols-outlined icon-sm" style="position:absolute;left:9px;top:50%;transform:translateY(-50%);color:var(--clr-tertiary)">search</span>
          <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Search items..." class="tb-input" style="padding-left:32px;font-size:var(--fs-label-md)">
        </div>
        <!-- Type -->
        <select name="type" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="all"     <?= $type==='all'?'selected':'' ?>>All Types</option>
          <option value="fixed"   <?= $type==='fixed'?'selected':'' ?>>Buy Now</option>
          <option value="auction" <?= $type==='auction'?'selected':'' ?>>Auction</option>
        </select>
        <!-- Size -->
        <select name="size" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Sizes</option>
          <?php foreach (['XS','S','M','L','XL','XXL','Free Size'] as $sz): ?>
          <option value="<?= $sz ?>" <?= $size===$sz?'selected':'' ?>><?= $sz ?></option>
          <?php endforeach; ?>
        </select>
        <!-- Condition -->
        <select name="condition" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="">All Conditions</option>
          <?php foreach (['Like New','Very Good','Good','Fair','For Parts'] as $cd): ?>
          <option value="<?= $cd ?>" <?= $cond===$cd?'selected':'' ?>><?= $cd ?></option>
          <?php endforeach; ?>
        </select>
        <!-- Sort -->
        <select name="sort" class="tb-input" style="width:auto" onchange="this.form.submit()">
          <option value="newest"     <?= $sort==='newest'?'selected':'' ?>>Newest First</option>
          <option value="price_asc"  <?= $sort==='price_asc'?'selected':'' ?>>Price: Low–High</option>
          <option value="price_desc" <?= $sort==='price_desc'?'selected':'' ?>>Price: High–Low</option>
          <option value="ending"     <?= $sort==='ending'?'selected':'' ?>>Ending Soonest</option>
        </select>
        <button type="submit" class="btn btn-primary btn-sm">Apply</button>
        <?php if ($q || $size || $cond || $catId || $type !== 'all'): ?>
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
          <?php if ($l['image_url']): ?>
          <img src="<?= htmlspecialchars($l['image_url']) ?>" alt="<?= htmlspecialchars($l['title']) ?>">
          <?php else: ?>
          <span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span>
          <?php endif; ?>
          <?php if ($l['auction_id']): ?>
          <span class="tb-badge-float top-left" style="background:var(--badge-live-bg);color:var(--badge-live-text)">Live</span>
          <?php endif; ?>
        </div>
        <div class="tb-listing-body">
          <div class="tb-listing-title"><?= htmlspecialchars($l['title']) ?></div>
          <?php if ($l['auction_id']): ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['current_highest_bid']) ?></div>
          <div class="tb-listing-meta">Bid &bull; Ends <?= formatTimeLeft($l['end_time']) ?></div>
          <?php else: ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['price']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= htmlspecialchars($l['item_condition']) ?></div>
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
