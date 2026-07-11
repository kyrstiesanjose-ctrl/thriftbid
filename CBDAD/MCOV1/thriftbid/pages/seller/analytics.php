<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole(['seller','admin'],'/pages/login.php');

$user     = currentUser();
$seller   = DB::fetch('SELECT * FROM SELLER WHERE user_id=?',[$user['user_id']]);
$sellerId = $seller['seller_id'] ?? 0;

// KPIs
$totalRevenue    = DB::fetch('SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.seller_id=? AND p.payment_status="Completed"',[$sellerId])['s'] ?? 0;
$totalOrders     = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE seller_id=?',[$sellerId])['c'] ?? 0;
$totalListings   = DB::fetch('SELECT COUNT(*) c FROM LISTINGS WHERE seller_id=? AND is_active=1',[$sellerId])['c'] ?? 0;
$avgBid          = DB::fetch('SELECT COALESCE(AVG(b.bid_amount),0) a FROM BIDDINGS b JOIN AUCTIONS a2 ON b.auction_id=a2.auction_id JOIN LISTINGS l ON a2.listing_id=l.listing_id WHERE l.seller_id=?',[$sellerId])['a'] ?? 0;
$avgRating       = DB::fetch('SELECT COALESCE(AVG(rating),0) a FROM REVIEWS WHERE seller_id=?',[$sellerId])['a'] ?? 0;
$disputeRate     = $totalOrders > 0 ? round((DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE seller_id=?',[$sellerId])['c'] ?? 0) / $totalOrders * 100, 1) : 0;
$fulfillRate     = $totalOrders > 0 ? round((DB::fetch('SELECT COUNT(*) c FROM ORDERS o JOIN SHIPMENTS s ON o.order_id=s.order_id WHERE o.seller_id=? AND TIMESTAMPDIFF(HOUR,o.order_date,s.shipped_date)<=48',[$sellerId])['c'] ?? 0) / $totalOrders * 100, 1) : 0;

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
    'SELECT c.name, COALESCE(SUM(p.amount_paid),0) total
     FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     WHERE o.seller_id=? AND p.payment_status="Completed"
     GROUP BY c.category_id,c.name ORDER BY total DESC LIMIT 6',
    [$sellerId]
);

// Penalties
$penalties = DB::fetchAll('SELECT * FROM PENALTIES WHERE seller_id=? ORDER BY issued_at DESC LIMIT 5',[$sellerId]);
$awards    = DB::fetchAll('SELECT * FROM AWARDS WHERE seller_id=? ORDER BY issued_at DESC LIMIT 3',[$sellerId]);

renderHead('Analytics');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('analytics', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('analytics'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Seller Analytics</h1>
  <p class="tb-page-subtitle mb-8">Track performance, revenue, and buyer behavior across your listings.</p>

  <!-- KPI Grid -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'payments',       'label'=>'Total Revenue',    'val'=>convertCurrency((float)$totalRevenue),'note'=>'Completed payments'],
      ['icon'=>'package_2',      'label'=>'Total Orders',     'val'=>$totalOrders,                          'note'=>'All time'],
      ['icon'=>'storefront',     'label'=>'Active Listings',  'val'=>$totalListings,                        'note'=>'Currently live'],
      ['icon'=>'trending_up',    'label'=>'Avg Bid Value',    'val'=>convertCurrency((float)$avgBid),       'note'=>'Per auction'],
      ['icon'=>'star',           'label'=>'Seller Rating',    'val'=>($avgRating?number_format($avgRating,1).'/5':'N/A'),'note'=>'Customer reviews'],
      ['icon'=>'local_shipping', 'label'=>'Fulfillment Rate', 'val'=>$fulfillRate.'%',                      'note'=>'Ships within 48h'],
      ['icon'=>'report_problem', 'label'=>'Dispute Rate',     'val'=>$disputeRate.'%',                      'note'=>'Of total orders'],
      ['icon'=>'block',          'label'=>'Active Penalties', 'val'=>count(array_filter($penalties,fn($p)=>$p['status']==='Active')),'note'=>'Platform flags'],
    ]; foreach($kpis as $k): ?>
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value"><?= $k['val'] ?></div>
        <div style="font-size:11px;color:var(--clr-tertiary);margin-top:2px"><?= $k['note'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <!-- Charts row -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
    <!-- Revenue trend -->
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:20px">Monthly Revenue</h3>
      <?php if (!empty($revByMonth)): ?>
      <canvas id="revChart" height="180"></canvas>
      <?php else: ?>
      <div style="height:180px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary)">No revenue data yet</div>
      <?php endif; ?>
    </div>

    <!-- Revenue by category -->
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:20px">Revenue by Category</h3>
      <?php if (!empty($revByCat)): ?>
      <div class="flex flex-col gap-4">
        <?php $maxCat = (float)($revByCat[0]['total']??1); foreach ($revByCat as $rc): $pct=$maxCat>0?round((float)$rc['total']/$maxCat*100):0; ?>
        <div>
          <div class="flex justify-between mb-1" style="font-size:var(--fs-label-sm)">
            <span style="font-weight:600"><?= htmlspecialchars($rc['name']) ?></span>
            <span style="color:var(--clr-tertiary)"><?= convertCurrency((float)$rc['total']) ?></span>
          </div>
          <div class="tb-progress-bar"><div class="tb-progress-fill" style="width:<?= $pct ?>%"></div></div>
        </div>
        <?php endforeach; ?>
      </div>
      <?php else: ?>
      <div style="color:var(--clr-tertiary)">No category data yet</div>
      <?php endif; ?>
    </div>
  </div>

  <!-- Penalties + Awards -->
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div class="tb-card">
      <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Penalties</h3></div>
      <div class="tb-card-body">
        <?php if (empty($penalties)): ?>
        <div style="text-align:center;padding:24px;color:var(--clr-tertiary)">
          <span class="material-symbols-outlined icon-lg" style="color:var(--clr-success)">verified_user</span>
          <p style="margin-top:8px;font-weight:600">Clean record</p>
        </div>
        <?php else: ?>
        <div class="flex flex-col gap-3">
          <?php foreach ($penalties as $p): ?>
          <div style="display:flex;justify-content:space-between;align-items:flex-start;padding:12px;border-radius:var(--radius-lg);background:var(--clr-surface-low)">
            <div>
              <p style="font-size:var(--fs-label-md);font-weight:600"><?= htmlspecialchars($p['reason']) ?></p>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($p['issued_at'])) ?></p>
            </div>
            <span class="tb-badge <?= $p['status']==='Active'?'tb-badge-red':($p['status']==='Served'?'tb-badge-gray':'tb-badge-gray') ?>"><?= $p['status'] ?></span>
          </div>
          <?php endforeach; ?>
        </div>
        <?php endif; ?>
      </div>
    </div>
    <div class="tb-card">
      <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Awards</h3></div>
      <div class="tb-card-body">
        <?php if (empty($awards)): ?>
        <div style="text-align:center;padding:24px;color:var(--clr-tertiary)">No awards yet. Keep selling to earn recognition!</div>
        <?php else: ?>
        <div class="flex flex-col gap-3">
          <?php foreach ($awards as $a): ?>
          <div style="display:flex;justify-content:space-between;align-items:flex-start;padding:12px;border-radius:var(--radius-lg);background:rgba(255,203,119,0.12);border:1px solid rgba(255,203,119,0.3)">
            <div>
              <p style="font-size:var(--fs-label-md);font-weight:600"><?= htmlspecialchars($a['reason']) ?></p>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($a['issued_at'])) ?></p>
            </div>
            <span class="tb-badge tb-badge-yellow"><?= $a['status'] ?></span>
          </div>
          <?php endforeach; ?>
        </div>
        <?php endif; ?>
      </div>
    </div>
  </div>

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
      backgroundColor:'rgba(255,107,107,0.7)',
      borderColor:'#ff6b6b',
      borderWidth:2,
      borderRadius:6,
    }]
  },
  options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{callback:v=>'₱'+v.toLocaleString()}}}}
});
</script>
<?php endif; ?>
</body></html>
