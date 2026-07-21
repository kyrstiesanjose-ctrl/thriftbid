<?php
// pages/admin/auctions.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole('admin');

if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['force_close']) && verifyCsrf($_POST['csrf'] ?? '')) {
    $aid = (int)$_POST['auction_id'];
    // Runs sp_close_auction to process the highest bidder, create the order, and notify both parties.
    // A simple status update here would drop the winning bid without creating an order.
    DB::callProc('sp_close_auction', [$aid]);
    header('Location: ' . BASE_URL . '/pages/admin/auctions.php?tab=closed'); exit;
}

$tab = in_array($_GET['tab'] ?? 'active', ['active','closed'], true) ? ($_GET['tab'] ?? 'active') : 'active';

$imgSub = '(SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image';

$active = DB::fetchAll(
    "SELECT a.*, l.title, l.listing_id, l.created_at, c.name AS cat_name, COALESCE(s.shop_name, s.username) AS seller_name, $imgSub,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id AND is_deleted=0) bc
     FROM AUCTIONS a
     JOIN LISTINGS l ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s ON l.seller_id=s.seller_id
     WHERE a.status='Active' ORDER BY l.created_at DESC"
);
$closed = DB::fetchAll(
    "SELECT a.*, l.title, l.listing_id, l.created_at, c.name AS cat_name, COALESCE(s.shop_name, s.username) AS seller_name, $imgSub,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id AND is_deleted=0) bc
     FROM AUCTIONS a
     JOIN LISTINGS l ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s ON l.seller_id=s.seller_id
     WHERE a.status='Closed' ORDER BY a.end_time DESC LIMIT 60"
);

function groupAuctionsByMonth(array $rows): array {
    $groups = [];
    foreach ($rows as $row) { $groups[date('F Y', strtotime($row['created_at']))][] = $row; }
    return $groups;
}
$activeByMonth = groupAuctionsByMonth($active);
$closedByMonth = groupAuctionsByMonth($closed);

renderHead('Auction Management');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('home'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('auctions'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">
  <h1 class="tb-page-title mb-2">Auction Management</h1>
  <p class="tb-page-subtitle mb-6">Every live and closed auction on the platform, organized by month. Fraud reports live in Moderation now.</p>

  <div class="tb-tabs mb-6">
    <a href="?tab=active" class="tb-tab-link <?=$tab==='active'?'active':''?>">Active (<?=count($active)?>)</a>
    <a href="?tab=closed" class="tb-tab-link <?=$tab==='closed'?'active':''?>">Closed (<?=count($closed)?>)</a>
  </div>

  <?php $groups = $tab==='closed' ? $closedByMonth : $activeByMonth; ?>
  <?php if (empty($groups)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">No <?= $tab ?> auctions found.</div>
  <?php else: foreach ($groups as $month => $rows): ?>
  <div style="margin-bottom:28px">
    <h2 style="font-size:var(--fs-label-md);font-weight:800;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:12px;padding-bottom:6px;border-bottom:1px solid var(--clr-outline)">
      <?= htmlspecialchars($month) ?> <span style="font-weight:500;text-transform:none;letter-spacing:normal">(<?= count($rows) ?>)</span>
    </h2>
    <div style="display:flex;flex-direction:column;gap:12px">
      <?php foreach ($rows as $a):
        $isUrgent = $tab==='active' && (strtotime($a['end_time']) - time()) < 3600;
      ?>
      <div class="tb-card" style="display:flex;align-items:center;gap:20px;padding:18px 20px">
        <div style="width:72px;height:72px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
          <?php if ($a['cover_image']): ?>
            <img src="<?= htmlspecialchars($a['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover">
          <?php else: ?>
            <span class="material-symbols-outlined" style="color:var(--clr-outline)">checkroom</span>
          <?php endif; ?>
        </div>
        <div style="flex:1;min-width:0">
          <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;flex-wrap:wrap">
            <?php if ($tab==='active'): ?>
            <span class="tb-badge <?= $isUrgent ? 'tb-badge-red' : 'tb-badge-active' ?>"><?= $isUrgent ? 'Ending Soon' : 'Active' ?></span>
            <?php else: ?>
            <span class="tb-badge tb-badge-gray">Closed</span>
            <?php endif; ?>
            <span class="tb-badge tb-badge-gray"><?= htmlspecialchars($a['cat_name']) ?></span>
          </div>
          <h3 style="font-weight:700;font-size:var(--fs-body-md);color:var(--clr-text);overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($a['title']) ?></h3>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px">Seller: <?= htmlspecialchars($a['seller_name']) ?></p>
          <div style="display:flex;flex-wrap:wrap;gap:14px;margin-top:6px;font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
            <span>Highest Bid: <strong style="color:var(--clr-text)"><?= convertCurrency((float)$a['current_highest_bid']) ?></strong></span>
            <span><?= $a['bc'] ?> bid<?= $a['bc']!==1?'s':'' ?></span>
            <?php if ($tab==='active'): ?>
            <span style="color:<?= $isUrgent ? 'var(--clr-error)' : 'inherit' ?>">Ends: <?= formatTimeLeft($a['end_time']) ?></span>
            <span>Min increment: <?= convertCurrency((float)$a['min_increment']) ?></span>
            <?php else: ?>
            <span>Ended: <?= date('M d, Y', strtotime($a['end_time'])) ?></span>
            <?php endif; ?>
          </div>
        </div>
        <div style="display:flex;flex-direction:column;gap:8px;flex-shrink:0;min-width:150px">
          <a href="<?= BASE_URL ?>/pages/customer/auction_room.php?id=<?= $a['auction_id'] ?>" target="_blank" class="btn btn-outline btn-sm">View Auction Room</a>
          <a href="<?= BASE_URL ?>/pages/customer/listing.php?id=<?= $a['listing_id'] ?>" target="_blank" class="btn btn-ghost btn-sm" style="text-align:center">View Listing</a>
          <?php if ($tab==='active'): ?>
          <form method="POST" onsubmit="return confirm('Force close this auction?')">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="force_close" value="1">
            <input type="hidden" name="auction_id" value="<?= $a['auction_id'] ?>">
            <button type="submit" class="btn btn-ghost btn-sm" style="width:100%">Force Close</button>
          </form>
          <?php endif; ?>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
  <?php endforeach; endif; ?>
</div>
</main>
</div>
</body></html>