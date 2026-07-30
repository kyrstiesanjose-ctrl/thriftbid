<?php
// pages/admin/reports.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole('admin');

$tab = $_GET['tab'] ?? 'platform';


$totalRevenue      = DB::fetch('SELECT COALESCE(SUM(amount_paid),0) s FROM PAYMENTS WHERE payment_status="Completed"')['s'] ?? 0;
$totalSellers      = DB::fetch('SELECT COUNT(*) c FROM SELLER')['c'] ?? 0;
$totalBuyers       = DB::fetch('SELECT COUNT(*) c FROM BUYER')['c'] ?? 0;
$totalUsers        = $totalSellers + $totalBuyers;
$verifiedUsers     = (DB::fetch('SELECT COUNT(*) c FROM SELLER WHERE is_verified=1')['c'] ?? 0)
                   + (DB::fetch('SELECT COUNT(*) c FROM BUYER WHERE is_verified=1')['c'] ?? 0);
$totalOrders       = DB::fetch('SELECT COUNT(*) c FROM ORDERS')['c'] ?? 0;
$completedOrders   = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE status="Delivered"')['c'] ?? 0;
$totalAuctions     = DB::fetch('SELECT COUNT(*) c FROM AUCTIONS')['c'] ?? 0;
$activeAuctions    = DB::fetch('SELECT COUNT(*) c FROM AUCTIONS WHERE status="Active"')['c'] ?? 0;
$totalDisputes     = DB::fetch('SELECT COUNT(*) c FROM DISPUTES')['c'] ?? 0;
$resolvedDisputes  = DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE status="Resolved"')['c'] ?? 0;
$avgAucDuration    = DB::fetch('SELECT COALESCE(AVG(TIMESTAMPDIFF(HOUR,start_time,end_time)),0) a FROM AUCTIONS WHERE status="Closed"')['a'] ?? 0;

$revTrend = DB::fetchAll(
    'SELECT DATE_FORMAT(payment_date,"%b %Y") mo, YEAR(payment_date) yr, MONTH(payment_date) mn, SUM(amount_paid) total
     FROM PAYMENTS WHERE payment_status="Completed" AND payment_date>=DATE_SUB(NOW(),INTERVAL 12 MONTH)
     GROUP BY yr,mn,mo ORDER BY yr,mn'
);

$topCats = DB::fetchAll(
    'SELECT c.name, COUNT(o.order_id) orders_cnt, COALESCE(SUM(p.amount_paid),0) revenue
     FROM ORDERS o JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status="Completed"
     GROUP BY c.category_id,c.name ORDER BY revenue DESC LIMIT 8'
);

$topSellers = DB::fetchAll(
    'SELECT COALESCE(s.shop_name, s.username) AS display_name, COALESCE(SUM(p.amount_paid),0) revenue,
            COUNT(DISTINCT o.order_id) orders_cnt,
            COALESCE(AVG(r.rating),0) avg_rating,
            s.offense_count
     FROM SELLER s
     LEFT JOIN ORDERS o ON o.seller_id=s.seller_id
     LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status="Completed"
     LEFT JOIN REVIEWS r ON r.seller_id=s.seller_id AND r.deleted_at IS NULL
     GROUP BY s.seller_id, display_name, s.offense_count
     ORDER BY revenue DESC LIMIT 10'
);

$topBuyers = DB::fetchAll(
    'SELECT bu.username, COUNT(DISTINCT o.order_id) orders_cnt,
            COALESCE(SUM(p.amount_paid),0) total_spent,
            COUNT(DISTINCT b2.bidding_id) total_bids
     FROM BUYER bu
     LEFT JOIN ORDERS o    ON o.buyer_id=bu.buyer_id
     LEFT JOIN PAYMENTS p  ON o.order_id=p.order_id AND p.payment_status="Completed"
     LEFT JOIN BIDDINGS b2 ON b2.buyer_id=bu.buyer_id AND b2.is_deleted=0
     GROUP BY bu.buyer_id, bu.username ORDER BY total_spent DESC LIMIT 10'
);

$dispRes = $totalDisputes > 0 ? round($resolvedDisputes / $totalDisputes * 100, 1) : 0;

renderHead('Platform Analytics');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('reports'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('reports'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <div class="flex items-center justify-between mb-6 flex-wrap gap-4">
    <div>
      <h1 class="tb-page-title">Platform Analytics</h1>
      <p class="tb-page-subtitle">Detailed platform-wide trends, top sellers/buyers, and category breakdowns — the Dashboard is for a quick daily glance, this is for deeper analysis.</p>
    </div>
    <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Generated: <?= date('M d, Y H:i') ?></span>
  </div>

  <div class="tb-tabs mb-8">
    <a href="?tab=platform" class="tb-tab-link <?= $tab==='platform'?'active':'' ?>">Platform</a>
    <a href="?tab=sellers"  class="tb-tab-link <?= $tab==='sellers'?'active':'' ?>">Seller Report</a>
    <a href="?tab=buyers"   class="tb-tab-link <?= $tab==='buyers'?'active':'' ?>">Buyer Report</a>
  </div>

  <?php if ($tab === 'platform'): ?>

  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $pkpis = [
      ['icon'=>'payments',      'label'=>'Total Revenue',        'val'=>convertCurrency((float)$totalRevenue),'badge'=>'All time'],
      ['icon'=>'group',         'label'=>'Total Users',          'val'=>$totalUsers,                           'badge'=>$verifiedUsers.' verified'],
      ['icon'=>'package_2',     'label'=>'Total Orders',         'val'=>$totalOrders,                          'badge'=>$completedOrders.' delivered'],
      ['icon'=>'gavel',         'label'=>'Total Auctions',       'val'=>$totalAuctions,                        'badge'=>$activeAuctions.' active'],
      ['icon'=>'report_problem','label'=>'Disputes',             'val'=>$totalDisputes,                        'badge'=>$dispRes.'% resolved'],
      ['icon'=>'timer',         'label'=>'Avg Auction Duration', 'val'=>round($avgAucDuration,1).'h',          'badge'=>'Closed auctions'],
      ['icon'=>'storefront',    'label'=>'Total Sellers',        'val'=>$totalSellers, 'badge'=>'Registered'],
      ['icon'=>'shopping_cart', 'label'=>'Total Buyers',         'val'=>$totalBuyers,  'badge'=>'Registered'],
    ];
    foreach ($pkpis as $k): ?>
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value"><?= $k['val'] ?></div>
        <div style="font-size:11px;color:var(--clr-tertiary);margin-top:2px"><?= $k['badge'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
    <div class="tb-card tb-card-body lg:col-span-2">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:20px">Revenue Trend (12 Months)</h3>
      <?php if (!empty($revTrend)): ?>
      <canvas id="revTrendChart" height="140"></canvas>
      <?php else: ?>
      <div style="height:140px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary)">No revenue data</div>
      <?php endif; ?>
    </div>
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:16px">Dispute Summary</h3>
      <div class="flex flex-col gap-4">
        <div>
          <div class="flex justify-between mb-1" style="font-size:var(--fs-label-sm)">
            <span>Resolution Rate</span><span style="font-weight:700;color:var(--clr-coral)"><?= $dispRes ?>%</span>
          </div>
          <div class="tb-progress-bar"><div class="tb-progress-fill" style="width:<?= $dispRes ?>%"></div></div>
        </div>
        <?php
        $openDisp = DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE status="Open"')['c'] ?? 0;
        $rejDisp  = DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE status="Rejected"')['c'] ?? 0;
        foreach ([['Open', $openDisp, 'tb-badge-red'], ['Resolved', $resolvedDisputes, 'tb-badge-green'], ['Rejected', $rejDisp, 'tb-badge-gray']] as [$label, $val, $color]): ?>
        <div class="flex justify-between items-center">
          <span class="tb-badge <?= $color ?>" style="margin-right:auto"><?= $label ?></span>
          <span style="font-weight:700;font-size:var(--fs-label-md)"><?= $val ?></span>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </div>

  <div class="tb-card">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Top Selling Categories</h3></div>
    <div class="overflow-x-auto">
      <table class="tb-table">
        <thead><tr><th>Category</th><th>Orders</th><th>Revenue</th><th>Share</th></tr></thead>
        <tbody>
          <?php $maxRev=(float)($topCats[0]['revenue']??1); foreach ($topCats as $cat): $pct=$maxRev>0?round((float)$cat['revenue']/$maxRev*100):0; ?>
          <tr>
            <td style="font-weight:600"><?= htmlspecialchars($cat['name']) ?></td>
            <td style="color:var(--clr-tertiary)"><?= $cat['orders_cnt'] ?></td>
            <td style="font-weight:700;color:var(--clr-coral)"><?= convertCurrency((float)$cat['revenue']) ?></td>
            <td style="min-width:160px">
              <div class="flex items-center gap-2">
                <div class="tb-progress-bar" style="flex:1"><div class="tb-progress-fill" style="width:<?= $pct ?>%"></div></div>
                <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);min-width:30px"><?= $pct ?>%</span>
              </div>
            </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>

  <?php elseif ($tab === 'sellers'): ?>
  <div class="tb-card">
    <div class="tb-card-header">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Top Sellers by Revenue</h3>
      <span class="tb-badge tb-badge-gray">All Time</span>
    </div>
    <div class="overflow-x-auto">
      <table class="tb-table">
        <thead><tr><th>#</th><th>Seller</th><th>Revenue</th><th>Orders</th><th>Avg Rating</th><th>Offenses</th><th>Status</th></tr></thead>
        <tbody>
          <?php foreach ($topSellers as $i => $s): ?>
          <tr>
            <td style="font-weight:700;color:var(--clr-coral)"><?= $i+1 ?></td>
            <td style="font-weight:700"><?= htmlspecialchars($s['display_name']) ?></td>
            <td style="font-weight:700"><?= convertCurrency((float)$s['revenue']) ?></td>
            <td style="color:var(--clr-tertiary)"><?= $s['orders_cnt'] ?></td>
            <td>
              <?php if ($s['avg_rating'] > 0): ?>
              <div class="flex items-center gap-1">
                <span class="material-symbols-outlined icon-sm filled" style="color:var(--clr-yellow)">star</span>
                <span style="font-weight:600"><?= number_format($s['avg_rating'],1) ?></span>
              </div>
              <?php else: ?><span style="color:var(--clr-tertiary)">No reviews</span><?php endif; ?>
            </td>
            <td>
              <span class="tb-badge <?= $s['offense_count']>=3?'tb-badge-red':($s['offense_count']>=1?'tb-badge-coral':'tb-badge-green') ?>">
                <?= $s['offense_count'] ?> offense<?= $s['offense_count']!==1?'s':'' ?>
              </span>
            </td>
            <td>
              <span class="tb-badge <?= $s['offense_count']>=3?'tb-badge-red':($s['offense_count']>=2?'tb-badge-coral':'tb-badge-green') ?>">
                <?= $s['offense_count']>=3?'Banned':($s['offense_count']>=2?'Suspended':'Good') ?>
              </span>
            </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>

  <?php elseif ($tab === 'buyers'): ?>
  <div class="tb-card">
    <div class="tb-card-header">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Top Buyers by Spending</h3>
      <span class="tb-badge tb-badge-gray">All Time</span>
    </div>
    <div class="overflow-x-auto">
      <table class="tb-table">
        <thead><tr><th>#</th><th>Buyer</th><th>Total Spent</th><th>Orders Won</th><th>Total Bids</th><th>Bid-to-Win Ratio</th></tr></thead>
        <tbody>
          <?php foreach ($topBuyers as $i => $b):
            $btr = $b['total_bids'] > 0 ? round($b['orders_cnt'] / $b['total_bids'] * 100, 1) : 0;
          ?>
          <tr>
            <td style="font-weight:700;color:var(--clr-coral)"><?= $i+1 ?></td>
            <td style="font-weight:700"><?= htmlspecialchars($b['username']) ?></td>
            <td style="font-weight:700"><?= convertCurrency((float)$b['total_spent']) ?></td>
            <td style="color:var(--clr-tertiary)"><?= $b['orders_cnt'] ?></td>
            <td style="color:var(--clr-tertiary)"><?= $b['total_bids'] ?></td>
            <td>
              <div class="flex items-center gap-2">
                <div class="tb-progress-bar" style="width:80px"><div class="tb-progress-fill" style="width:<?= $btr ?>%"></div></div>
                <span style="font-size:var(--fs-label-sm)"><?= $btr ?>%</span>
              </div>
            </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>
  <?php endif; ?>

</div>
</main>
</div>

<?php if (!empty($revTrend) && $tab==='platform'): ?>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
new Chart(document.getElementById('revTrendChart'), {
  type:'line',
  data:{
    labels:<?= json_encode(array_column($revTrend,'mo')) ?>,
    datasets:[{
      label:'Revenue',
      data:<?= json_encode(array_map(fn($r)=>(float)$r['total'],$revTrend)) ?>,
      borderColor:'#ff6b6b',backgroundColor:'rgba(255,107,107,0.08)',
      borderWidth:2,fill:true,tension:0.4,
      pointBackgroundColor:'#ff6b6b',pointRadius:4,
    }]
  },
  options:{responsive:true,plugins:{legend:{display:false}},
    scales:{y:{beginAtZero:true,ticks:{callback:v=>'₱'+v.toLocaleString()}}}}
});
</script>
<?php endif; ?>
</body></html>