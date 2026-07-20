<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole(['seller','admin'], '/pages/login.php');

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id']; // session row IS the seller row now

$stats = DB::callOne('sp_seller_dashboard_stats', [$sellerId]);
$totalRevenue   = $stats['total_revenue'] ?? 0;
$activeListings = $stats['active_listings'] ?? 0;
$pendingShip    = $stats['pending_shipments'] ?? 0;
$activeAuctions = $stats['active_auctions'] ?? 0;
$avgRating      = $stats['avg_rating'] ?? 0;
$pendingAuth    = $stats['pending_authenticity'] ?? 0;

$recentOrders = DB::fetchAll(
    "SELECT o.*, l.title, bu.username AS buyer_name,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER bu   ON o.buyer_id=bu.buyer_id
     WHERE o.seller_id=?
     ORDER BY o.order_date DESC LIMIT 6",
    [$sellerId]
);

$unreadNotifs = DB::fetchAll(
    'SELECT title, message, notification_type, created_at FROM NOTIFICATIONS
     WHERE seller_id=? ORDER BY created_at DESC LIMIT 5',
    [$sellerId]
);

renderHead('Seller Dashboard');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('home', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('overview'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Welcome back, <?= htmlspecialchars($user['username']) ?>!</h1>
  <p class="tb-page-subtitle mb-8">Here's what's happening with your shop today.</p>

  <?php if ($pendingAuth > 0): ?>
  <div class="tb-alert tb-alert-warning show mb-6">
    <span class="material-symbols-outlined icon-sm">hourglass_top</span>
    You have <?= $pendingAuth ?> luxury listing<?= $pendingAuth!==1?'s':'' ?> awaiting admin authenticity review.
  </div>
  <?php endif; ?>
  <?php if ($pendingShip > 0): ?>
  <div class="tb-alert tb-alert-error show mb-6">
    <span class="material-symbols-outlined icon-sm">local_shipping</span>
    You have <?= $pendingShip ?> order<?= $pendingShip!==1?'s':'' ?> waiting to be shipped — remember, it's within 48 hours of payment.
    <a href="to-ship.php" style="font-weight:700;margin-left:6px">Ship now &rarr;</a>
  </div>
  <?php endif; ?>

  <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'payments',   'label'=>'Total Revenue',   'val'=>convertCurrency((float)$totalRevenue)],
      ['icon'=>'storefront', 'label'=>'Active Listings', 'val'=>$activeListings],
      ['icon'=>'gavel',      'label'=>'Active Auctions', 'val'=>$activeAuctions],
      ['icon'=>'local_shipping','label'=>'To Ship',      'val'=>$pendingShip],
      ['icon'=>'star',       'label'=>'Avg Rating',      'val'=>$avgRating?number_format($avgRating,1).'/5':'N/A'],
    ]; foreach($kpis as $k): ?>
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value"><?= $k['val'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    <div class="tb-card lg:col-span-2">
      <div class="tb-card-header">
        <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Recent Orders</h3>
        <a href="../customer/orders.php" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View All</a>
      </div>
      <div class="tb-card-body">
        <?php if (empty($recentOrders)): ?>
        <div style="text-align:center;padding:24px;color:var(--clr-tertiary)">No orders yet.</div>
        <?php else: foreach ($recentOrders as $o): ?>
        <div style="display:flex;align-items:center;gap:14px;padding:10px 0;border-bottom:1px solid var(--clr-outline)">
          <div style="width:48px;height:48px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
            <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
          </div>
          <div style="flex:1;min-width:0">
            <p style="font-weight:600;font-size:var(--fs-label-md);overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($o['title']) ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">@<?= htmlspecialchars($o['buyer_name']) ?> &bull; <?= date('M d, Y', strtotime($o['order_date'])) ?></p>
          </div>
          <span class="tb-badge <?= $o['status']==='Delivered'?'tb-badge-green':($o['status']==='Cancelled'?'tb-badge-red':'tb-badge-blue') ?>"><?= $o['status'] ?></span>
        </div>
        <?php endforeach; endif; ?>
      </div>
    </div>

    <div class="tb-card">
      <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Recent Notifications</h3></div>
      <div class="tb-card-body">
        <?php if (empty($unreadNotifs)): ?>
        <div style="text-align:center;padding:24px;color:var(--clr-tertiary)">No notifications yet.</div>
        <?php else: foreach ($unreadNotifs as $n): ?>
        <div style="padding:10px 0;border-bottom:1px solid var(--clr-outline)">
          <p style="font-weight:600;font-size:var(--fs-label-md)"><?= htmlspecialchars($n['title']) ?></p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($n['message']) ?></p>
          <p style="font-size:11px;color:var(--clr-tertiary);margin-top:2px"><?= date('M d, Y H:i', strtotime($n['created_at'])) ?></p>
        </div>
        <?php endforeach; endif; ?>
      </div>
    </div>

  </div>

</div>
</main>
</div>
</body></html>