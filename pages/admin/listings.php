<?php
// pages/admin/listings.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole('admin');

$q      = trim($_GET['q'] ?? '');
$page   = max(1,(int)($_GET['page'] ?? 1));
$per    = 20; $offset = ($page-1)*$per;

if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['toggle_listing']) && verifyCsrf($_POST['csrf'] ?? '')) {
    $lid = (int)$_POST['listing_id'];
    $cur = (int)$_POST['current'];
    DB::query('UPDATE LISTINGS SET is_active=? WHERE listing_id=?', [$cur?0:1, $lid]);
    header('Location: ' . BASE_URL . '/pages/admin/listings.php' . ($q?"?q=$q":'')); exit;
}

$where = '1=1'; $params = [];
if ($q) { $where .= ' AND (l.title LIKE ? OR s.username LIKE ? OR s.shop_name LIKE ?)'; $params = array_merge($params, ["%$q%", "%$q%", "%$q%"]); }

$total = DB::fetch("SELECT COUNT(*) c FROM LISTINGS l JOIN SELLER s ON l.seller_id=s.seller_id WHERE $where", $params)['c'] ?? 0;

$imgSub = '(SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image';

$listings = DB::fetchAll(
    "SELECT l.*, c.name as cat_name, COALESCE(s.shop_name, s.username) AS seller_name, $imgSub,
            (SELECT COUNT(*) FROM AUCTIONS WHERE listing_id=l.listing_id AND status='Active') as has_auction
     FROM LISTINGS l JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s ON l.seller_id=s.seller_id
     WHERE $where ORDER BY l.created_at DESC LIMIT $per OFFSET $offset",
    $params
);
$totalPages = max(1,ceil($total/$per));

function groupListingsByMonth(array $rows): array {
    $groups = [];
    foreach ($rows as $row) { $groups[date('F Y', strtotime($row['created_at']))][] = $row; }
    return $groups;
}
$listingsByMonth = groupListingsByMonth($listings);

renderHead('Manage Listings');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('listings'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('listings'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">
  <div class="flex items-center justify-between mb-6 flex-wrap gap-4">
    <div><h1 class="tb-page-title">All Listings</h1><p class="tb-page-subtitle"><?= number_format($total) ?> total listings, organized by month</p></div>
    <form method="GET" class="flex gap-2">
      <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Search title or seller..." class="tb-input" style="width:240px">
      <button type="submit" class="btn btn-primary btn-sm">Search</button>
      <?php if ($q): ?><a href="<?= BASE_URL ?>/pages/admin/listings.php" class="btn btn-ghost btn-sm">Clear</a><?php endif; ?>
    </form>
  </div>

  <?php if (empty($listingsByMonth)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">No listings found.</div>
  <?php else: foreach ($listingsByMonth as $month => $rows): ?>
  <div style="margin-bottom:28px">
    <h2 style="font-size:var(--fs-label-md);font-weight:800;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:12px;padding-bottom:6px;border-bottom:1px solid var(--clr-outline)">
      <?= htmlspecialchars($month) ?> <span style="font-weight:500;text-transform:none;letter-spacing:normal">(<?= count($rows) ?>)</span>
    </h2>
    <div style="display:flex;flex-direction:column;gap:12px">
      <?php foreach ($rows as $l): ?>
      <div class="tb-card" style="display:flex;align-items:center;gap:20px;padding:18px 20px">
        <div style="width:72px;height:72px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
          <?php if ($l['cover_image']): ?>
            <img src="<?= htmlspecialchars($l['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover">
          <?php else: ?>
            <span class="material-symbols-outlined" style="color:var(--clr-outline)">checkroom</span>
          <?php endif; ?>
        </div>
        <div style="flex:1;min-width:0">
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;flex-wrap:wrap">
            <span class="tb-badge <?= $l['is_active']?'tb-badge-active':'tb-badge-gray' ?>"><?= $l['is_active']?'Active':'Inactive' ?></span>
            <span class="tb-badge tb-badge-gray"><?= htmlspecialchars($l['cat_name']) ?></span>
            <span class="tb-badge tb-badge-gray"><?= $l['has_auction']?'Auction':'Fixed Price' ?></span>
          </div>
          <h3 style="font-weight:700;font-size:var(--fs-body-md);color:var(--clr-text);overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($l['title']) ?></h3>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px">Seller: <?= htmlspecialchars($l['seller_name']) ?></p>
          <div style="display:flex;flex-wrap:wrap;gap:14px;margin-top:6px;font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
            <span>Price: <strong style="color:var(--clr-text)"><?= convertCurrency((float)$l['price']) ?></strong></span>
            <span>Listed: <?= date('M d, Y', strtotime($l['created_at'])) ?></span>
          </div>
        </div>
        <div style="display:flex;flex-direction:column;gap:8px;flex-shrink:0;min-width:150px">
          <a href="<?= BASE_URL ?>/pages/customer/listing.php?id=<?= $l['listing_id'] ?>" target="_blank" class="btn btn-outline btn-sm">View Listing</a>
          <form method="POST">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="toggle_listing" value="1">
            <input type="hidden" name="listing_id" value="<?= $l['listing_id'] ?>">
            <input type="hidden" name="current" value="<?= $l['is_active'] ?>">
            <button type="submit" class="btn btn-ghost btn-sm" style="width:100%"><?= $l['is_active']?'Deactivate':'Reactivate' ?></button>
          </form>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
  <?php endforeach; endif; ?>

  <?php if ($totalPages>1): ?>
  <div class="tb-pagination">
    <p class="tb-pagination-info">Page <?=$page?> of <?=$totalPages?> &bull; <?= number_format($total) ?> total</p>
    <div class="tb-pagination-btns">
      <?php if($page>1): ?><a href="?page=<?=$page-1?>&q=<?=urlencode($q)?>" class="tb-pagination-btn">Prev</a><?php endif; ?>
      <?php if($page<$totalPages): ?><a href="?page=<?=$page+1?>&q=<?=urlencode($q)?>" class="tb-pagination-btn">Next</a><?php endif; ?>
    </div>
  </div>
  <?php endif; ?>
</div>
</main>
</div>
</body></html>