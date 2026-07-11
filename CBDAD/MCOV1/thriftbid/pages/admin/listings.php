<?php
// pages/admin/listings.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole('admin','/pages/login.php');

$q      = trim($_GET['q'] ?? '');
$page   = max(1,(int)($_GET['page'] ?? 1));
$per    = 20; $offset = ($page-1)*$per;

if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['toggle_listing'])) {
    $lid = (int)$_POST['listing_id'];
    $cur = (int)$_POST['current'];
    DB::query('UPDATE LISTINGS SET is_active=? WHERE listing_id=?', [$cur?0:1, $lid]);
    header('Location: /pages/admin/listings.php' . ($q?"?q=$q":'')); exit;
}

$where = '1=1'; $params = [];
if ($q) { $where .= ' AND (l.title LIKE ? OR u.username LIKE ?)'; $params = array_merge($params, ["%$q%", "%$q%"]); }

$total = DB::fetch("SELECT COUNT(*) c FROM LISTINGS l JOIN SELLER s ON l.seller_id=s.seller_id JOIN USERS u ON s.user_id=u.user_id WHERE $where", $params)['c'] ?? 0;
$listings = DB::fetchAll(
    "SELECT l.*,c.name as cat_name,u.username as seller_name,
            (SELECT COUNT(*) FROM AUCTIONS WHERE listing_id=l.listing_id AND status='Active') as has_auction
     FROM LISTINGS l JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s ON l.seller_id=s.seller_id JOIN USERS u ON s.user_id=u.user_id
     WHERE $where ORDER BY l.created_at DESC LIMIT $per OFFSET $offset",
    $params
);
$totalPages = max(1,ceil($total/$per));
renderHead('Manage Listings');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('listings'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('listings'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">
  <div class="flex items-center justify-between mb-6 flex-wrap gap-4">
    <div><h1 class="tb-page-title">All Listings</h1><p class="tb-page-subtitle"><?= number_format($total) ?> total listings</p></div>
    <form method="GET" class="flex gap-2">
      <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Search title or seller..." class="tb-input" style="width:240px">
      <button type="submit" class="btn btn-primary btn-sm">Search</button>
      <?php if ($q): ?><a href="/pages/admin/listings.php" class="btn btn-ghost btn-sm">Clear</a><?php endif; ?>
    </form>
  </div>
  <div class="tb-table-wrapper">
    <table class="tb-table">
      <thead><tr><th>Item</th><th>Seller</th><th>Category</th><th>Price</th><th>Type</th><th>Status</th><th>Listed</th><th>Action</th></tr></thead>
      <tbody>
        <?php if (empty($listings)): ?>
        <tr><td colspan="8" style="text-align:center;padding:40px;color:var(--clr-tertiary)">No listings found.</td></tr>
        <?php else: foreach ($listings as $l): ?>
        <tr>
          <td style="font-weight:600;max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($l['title']) ?></td>
          <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($l['seller_name']) ?></td>
          <td><span class="tb-badge tb-badge-gray"><?= htmlspecialchars($l['cat_name']) ?></span></td>
          <td style="font-weight:700"><?= convertCurrency((float)$l['price']) ?></td>
          <td><span class="tb-badge <?= $l['has_auction']?'tb-badge-coral':'tb-badge-gray' ?>"><?= $l['has_auction']?'Auction':'Fixed' ?></span></td>
          <td><span class="tb-badge <?= $l['is_active']?'tb-badge-green':'tb-badge-red' ?>"><?= $l['is_active']?'Active':'Inactive' ?></span></td>
          <td style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)"><?= date('M d, Y',strtotime($l['created_at'])) ?></td>
          <td>
            <form method="POST">
              <input type="hidden" name="toggle_listing" value="1">
              <input type="hidden" name="listing_id" value="<?= $l['listing_id'] ?>">
              <input type="hidden" name="current" value="<?= $l['is_active'] ?>">
              <button type="submit" class="btn btn-ghost btn-sm"><?= $l['is_active']?'Deactivate':'Reactivate' ?></button>
            </form>
          </td>
        </tr>
        <?php endforeach; endif; ?>
      </tbody>
    </table>
    <?php if ($totalPages>1): ?>
    <div class="tb-pagination">
      <p class="tb-pagination-info">Page <?=$page?> of <?=$totalPages?></p>
      <div class="tb-pagination-btns">
        <?php if($page>1): ?><a href="?page=<?=$page-1?>&q=<?=urlencode($q)?>" class="tb-pagination-btn">Prev</a><?php endif; ?>
        <?php if($page<$totalPages): ?><a href="?page=<?=$page+1?>&q=<?=urlencode($q)?>" class="tb-pagination-btn">Next</a><?php endif; ?>
      </div>
    </div>
    <?php endif; ?>
  </div>
</div>
</main>
</div>
</body></html>
