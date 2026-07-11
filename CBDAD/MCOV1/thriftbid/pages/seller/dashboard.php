<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('/pages/login.php');
requireRole(['seller','admin'], '/pages/login.php');

$user   = currentUser();
$seller = DB::fetch('SELECT seller_id FROM SELLER WHERE user_id = ?', [$user['user_id']]);
if (!$seller) {
    
    DB::query('INSERT INTO SELLER (user_id) VALUES (?)', [$user['user_id']]);
    $seller = DB::fetch('SELECT seller_id FROM SELLER WHERE user_id = ?', [$user['user_id']]);
}
$sellerId = $seller['seller_id'];

// Revenue KPIs
$totalRevenue    = DB::fetch('SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.seller_id=? AND p.payment_status="Completed"', [$sellerId])['s'] ?? 0;
$totalOrders     = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE seller_id=?', [$sellerId])['c'] ?? 0;
$activeAuctions  = DB::fetch('SELECT COUNT(*) c FROM AUCTIONS a JOIN LISTINGS l ON a.listing_id=l.listing_id WHERE l.seller_id=? AND a.status="Active"', [$sellerId])['c'] ?? 0;
$toShipCount     = DB::fetch('SELECT COUNT(*) c FROM ORDERS o LEFT JOIN SHIPMENTS s ON o.order_id=s.order_id WHERE o.seller_id=? AND o.status="Preparing" AND s.shipment_id IS NULL', [$sellerId])['c'] ?? 0;
$avgBid          = DB::fetch('SELECT COALESCE(AVG(b.bid_amount),0) a FROM BIDDINGS b JOIN AUCTIONS a ON b.auction_id=a.auction_id JOIN LISTINGS l ON a.listing_id=l.listing_id WHERE l.seller_id=?', [$sellerId])['a'] ?? 0;
$avgRating       = DB::fetch('SELECT COALESCE(AVG(rating),0) a FROM REVIEWS WHERE seller_id=?', [$sellerId])['a'] ?? 0;
$totalListings   = DB::fetch('SELECT COUNT(*) c FROM LISTINGS WHERE seller_id=? AND is_active=1', [$sellerId])['c'] ?? 0;
$pendingPayments = DB::fetch('SELECT COUNT(*) c FROM ORDERS o LEFT JOIN PAYMENTS p ON o.order_id=p.order_id WHERE o.seller_id=? AND o.status="Preparing" AND (p.payment_id IS NULL OR p.payment_status="Pending")', [$sellerId])['c'] ?? 0;

// Monthly revenue (last 6 months)
$revByMonth = DB::fetchAll(
    'SELECT DATE_FORMAT(p.payment_date,"%b") mo, MONTH(p.payment_date) mn, YEAR(p.payment_date) yr, SUM(p.amount_paid) total
     FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id
     WHERE o.seller_id=? AND p.payment_status="Completed" AND p.payment_date>=DATE_SUB(NOW(),INTERVAL 6 MONTH)
     GROUP BY yr,mn,mo ORDER BY yr,mn',
    [$sellerId]
);

// Revenue by category
$revByCat = DB::fetchAll(
    'SELECT c.name, COALESCE(SUM(p.amount_paid),0) total, COUNT(DISTINCT o.order_id) orders_cnt
     FROM PAYMENTS p
     JOIN ORDERS o   ON p.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     WHERE o.seller_id=? AND p.payment_status="Completed"
     GROUP BY c.category_id,c.name ORDER BY total DESC LIMIT 8',
    [$sellerId]
);

// Top selling categories bar chart data
$maxCatRev = !empty($revByCat) ? (float)$revByCat[0]['total'] : 1;

// Live auctions monitor
$liveAuctions = DB::fetchAll(
    'SELECT a.*,l.title,l.image_url,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id) as bid_count
     FROM AUCTIONS a
     JOIN LISTINGS l ON a.listing_id=l.listing_id
     WHERE l.seller_id=? AND a.status="Active"
     ORDER BY a.end_time ASC LIMIT 5',
    [$sellerId]
);

// Weekly bid volume (last 7 days)
$weekData = DB::fetchAll(
    'SELECT DAYNAME(b.bid_time) day_name, DAYOFWEEK(b.bid_time) dow, COUNT(*) cnt
     FROM BIDDINGS b
     JOIN AUCTIONS a ON b.auction_id=a.auction_id
     JOIN LISTINGS l ON a.listing_id=l.listing_id
     WHERE l.seller_id=? AND b.bid_time>=DATE_SUB(NOW(),INTERVAL 7 DAY)
     GROUP BY DAYOFWEEK(b.bid_time),DAYNAME(b.bid_time)
     ORDER BY DAYOFWEEK(b.bid_time)',
    [$sellerId]
);

// Recent orders
$recentOrders = DB::fetchAll(
    'SELECT o.*,l.title,u.username as buyer_name,p.amount_paid,p.payment_status
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER by2  ON o.buyer_id=by2.buyer_id
     JOIN USERS u    ON by2.user_id=u.user_id
     LEFT JOIN PAYMENTS p ON o.order_id=p.order_id
     WHERE o.seller_id=?
     ORDER BY o.order_date DESC LIMIT 6',
    [$sellerId]
);

function fmtTimeLeft(string $end): string {
    $d = strtotime($end) - time();
    if ($d <= 0) return 'Ended';
    if ($d >= 86400) return floor($d/86400).'d '.floor(($d%86400)/3600).'h';
    return str_pad(floor($d/3600),2,'0',STR_PAD_LEFT).':'.str_pad(floor(($d%3600)/60),2,'0',STR_PAD_LEFT);
}

renderHead('Seller Dashboard');
?>
<body style="height:100vh;overflow:hidden;display:flex;flex-direction:column;background:var(--clr-bg)">
<?php renderNavbar('home', true); ?>

<div style="display:flex;flex:1;overflow:hidden">
<?php renderSellerSidebar('overview'); ?>

<main style="flex:1;overflow-y:auto;background:var(--clr-bg)">
<div style="max-width:1100px;margin:0 auto;padding:32px 40px 80px">

  <!-- Header -->
  <div style="margin-bottom:28px">
    <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:700;color:var(--clr-text)">Merchant Overview</h1>
    <p style="color:var(--clr-tertiary);margin-top:4px">Track your revenue, auctions, and fulfillment performance.</p>
  </div>

  <!-- KPI Cards -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4" style="margin-bottom:28px">
    <?php $kpis = [
      ['label'=>'Total Revenue',   'value'=>'₱'.number_format((float)$totalRevenue,2), 'sub'=>'Completed payments', 'icon'=>'payments',       'accent'=>true],
      ['label'=>'Total Orders',    'value'=>$totalOrders,    'sub'=>'All time',                   'icon'=>'package_2',      'accent'=>false],
      ['label'=>'Active Auctions', 'value'=>$activeAuctions, 'sub'=>'Live right now',              'icon'=>'gavel',          'accent'=>false],
      ['label'=>'To Ship',         'value'=>$toShipCount,    'sub'=>'Awaiting shipment',           'icon'=>'local_shipping', 'accent'=>$toShipCount>0],
      ['label'=>'Avg Bid Value',   'value'=>'₱'.number_format((float)$avgBid,2), 'sub'=>'Per auction', 'icon'=>'trending_up', 'accent'=>false],
      ['label'=>'Seller Rating',   'value'=>$avgRating ? number_format($avgRating,1).'/5' : 'N/A','sub'=>'Customer reviews','icon'=>'star',         'accent'=>false],
      ['label'=>'Active Listings', 'value'=>$totalListings,  'sub'=>'Currently live',              'icon'=>'storefront',     'accent'=>false],
      ['label'=>'Pending Payments','value'=>$pendingPayments,'sub'=>'Awaiting buyer checkout',     'icon'=>'hourglass_empty', 'accent'=>$pendingPayments>0],
    ]; foreach ($kpis as $k): ?>
    <div class="tb-stat-card" style="<?= $k['accent'] ? 'border-left:3px solid var(--clr-coral)' : '' ?>">
      <div class="tb-stat-icon">
        <span class="material-symbols-outlined icon-sm"><?= $k['icon'] ?></span>
      </div>
      <div style="min-width:0">
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value" style="font-size:20px;color:<?= $k['accent']?'var(--clr-coral)':'var(--clr-text)' ?>"><?= $k['value'] ?></div>
        <div style="font-size:11px;color:var(--clr-tertiary);margin-top:1px"><?= $k['sub'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <!-- Revenue Chart + Bid Volume -->
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-5" style="margin-bottom:28px">

    <!-- Monthly revenue bar chart -->
    <div class="tb-card lg:col-span-2">
      <div class="tb-card-header">
        <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Monthly Revenue (Last 6 Months)</span>
        <span class="tb-badge tb-badge-coral">₱<?= number_format((float)$totalRevenue,2) ?> total</span>
      </div>
      <div style="padding:20px">
        <?php if (!empty($revByMonth)): ?>
        <canvas id="revChart" height="140"></canvas>
        <?php else: ?>
        <div style="height:140px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary);font-size:var(--fs-label-md)">No revenue data yet</div>
        <?php endif; ?>
      </div>
    </div>

    <!-- Bid volume (last 7 days) -->
    <div class="tb-card">
      <div class="tb-card-header">
        <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Bid Volume</span>
        <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Last 7 days</span>
      </div>
      <div style="padding:20px">
        <?php if (!empty($weekData)): ?>
        <canvas id="bidChart" height="140"></canvas>
        <?php else: ?>
        <div style="height:140px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary);font-size:var(--fs-label-md)">No bid data yet</div>
        <?php endif; ?>
      </div>
    </div>
  </div>

  <!-- Top Selling Categories -->
  <?php if (!empty($revByCat)): ?>
  <div class="tb-card" style="margin-bottom:28px">
    <div class="tb-card-header">
      <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Top Selling Categories</span>
    </div>
    <div style="overflow-x:auto">
      <table class="tb-table">
        <thead>
          <tr>
            <th>Category</th>
            <th>Orders</th>
            <th>Revenue</th>
            <th>Share</th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($revByCat as $cat):
            $pct = $maxCatRev > 0 ? round((float)$cat['total'] / $maxCatRev * 100) : 0;
          ?>
          <tr>
            <td style="font-weight:600;color:var(--clr-text)"><?= htmlspecialchars($cat['name']) ?></td>
            <td style="color:var(--clr-tertiary)"><?= $cat['orders_cnt'] ?></td>
            <td style="font-weight:700;color:var(--clr-coral)">₱<?= number_format((float)$cat['total'],2) ?></td>
            <td style="min-width:180px">
              <div style="display:flex;align-items:center;gap:8px">
                <div class="tb-progress-bar" style="flex:1">
                  <div class="tb-progress-fill" style="width:<?= $pct ?>%"></div>
                </div>
                <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);min-width:32px;text-align:right"><?= $pct ?>%</span>
              </div>
            </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>
  <?php endif; ?>

  <!-- Live Auctions Monitor + Recent Orders -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-5">

    <!-- Live auctions -->
    <div class="tb-card">
      <div class="tb-card-header">
        <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Live Auctions</span>
        <a href="active-auctions.php" class="text-thrift-coral text-sm font-medium hover:underline">View All</a>
      </div>
      <?php if (empty($liveAuctions)): ?>
      <div style="padding:32px;text-align:center;color:var(--clr-tertiary)">
        <span class="material-symbols-outlined icon-lg" style="color:var(--clr-outline);display:block;margin-bottom:8px">gavel</span>
        <p>No active auctions.</p>
        <a href="create-listing.php" class="btn btn-primary btn-sm" style="margin-top:12px">Create Listing</a>
      </div>
      <?php else: ?>
      <div style="overflow-x:auto">
        <table class="tb-table">
          <thead><tr><th>Item</th><th>Highest Bid</th><th>Bids</th><th>Ends</th></tr></thead>
          <tbody>
            <?php foreach ($liveAuctions as $a):
              $urgent = (strtotime($a['end_time']) - time()) < 3600;
            ?>
            <tr>
              <td>
                <div style="display:flex;align-items:center;gap:10px">
                  <div style="width:36px;height:36px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
                    <?php if ($a['image_url']): ?><img src="<?= htmlspecialchars($a['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined" style="font-size:16px;color:var(--clr-outline)">checkroom</span><?php endif; ?>
                  </div>
                  <span style="font-weight:600;font-size:var(--fs-label-md);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:120px"><?= htmlspecialchars($a['title']) ?></span>
                </div>
              </td>
              <td style="font-weight:700;color:var(--clr-text)">₱<?= number_format((float)$a['current_highest_bid'],2) ?></td>
              <td style="color:var(--clr-tertiary)"><?= $a['bid_count'] ?></td>
              <td style="font-size:var(--fs-label-sm);color:<?= $urgent?'var(--clr-error)':'var(--clr-tertiary)' ?>;font-weight:<?= $urgent?'700':'400' ?>"><?= fmtTimeLeft($a['end_time']) ?></td>
            </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      </div>
      <?php endif; ?>
    </div>

    <!-- Recent orders -->
    <div class="tb-card">
      <div class="tb-card-header">
        <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Recent Orders</span>
        <a href="transactions.php" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View All</a>
      </div>
      <?php if (empty($recentOrders)): ?>
      <div style="padding:32px;text-align:center;color:var(--clr-tertiary)">No orders yet.</div>
      <?php else: ?>
      <div style="overflow-x:auto">
        <table class="tb-table">
          <thead><tr><th>Item</th><th>Buyer</th><th>Amount</th><th>Status</th></tr></thead>
          <tbody>
            <?php foreach ($recentOrders as $o): ?>
            <tr>
              <td style="font-weight:600;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($o['title']) ?></td>
              <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($o['buyer_name']) ?></td>
              <td style="font-weight:700;color:var(--clr-coral)">
                <?= $o['amount_paid'] ? '₱'.number_format((float)$o['amount_paid'],2) : '—' ?>
              </td>
              <td>
                <span class="tb-badge <?= match($o['status']) {
                  'Delivered'       => 'tb-badge-active',
                  'Shipped'         => 'tb-badge-blue',
                  'Out for Delivery'=> 'tb-badge-blue',
                  default           => 'tb-badge-gray'
                } ?>"><?= htmlspecialchars($o['status']) ?></span>
              </td>
            </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
      </div>
      <?php endif; ?>
    </div>

  </div><!-- /grid -->

</div>
</main>
</div>

<?php if (!empty($revByMonth)): ?>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
new Chart(document.getElementById('revChart'), {
  type:'bar',
  data:{
    labels:<?= json_encode(array_column($revByMonth,'mo')) ?>,
    datasets:[{
      label:'Revenue (₱)',
      data:<?= json_encode(array_map(fn($r)=>(float)$r['total'],$revByMonth)) ?>,
      backgroundColor:'rgba(255,107,107,0.65)',
      borderColor:'#ff6b6b',borderWidth:1,borderRadius:2,
    }]
  },
  options:{
    responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false}},
    scales:{y:{beginAtZero:true,ticks:{callback:v=>'₱'+v.toLocaleString()}}}
  }
});
</script>
<?php endif; ?>

<?php if (!empty($weekData)): ?>
<script src="https://cdn.jsdelivr.net/npm/chart.js" <?= !empty($revByMonth)?'':'id="cjs"'?>></script>
<script>
new Chart(document.getElementById('bidChart'), {
  type:'bar',
  data:{
    labels:<?= json_encode(array_column($weekData,'day_name')) ?>,
    datasets:[{
      data:<?= json_encode(array_map(fn($r)=>(int)$r['cnt'],$weekData)) ?>,
      backgroundColor:'rgba(255,107,107,0.65)',
      borderColor:'#ff6b6b',borderWidth:1,borderRadius:2,
    }]
  },
  options:{
    responsive:true,maintainAspectRatio:false,
    plugins:{legend:{display:false}},
    scales:{y:{beginAtZero:true,ticks:{stepSize:1,precision:0}}}
  }
});
</script>
<?php endif; ?>
</body></html>