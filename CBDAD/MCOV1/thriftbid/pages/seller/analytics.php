<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php'; // live exchange rates (replaces old hardcoded convertCurrency)
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole(['seller','admin']);

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id']; // session row IS the seller row now

// Which report tab are we on? Mapping per product spec:
//   overview     -> landing summary
//   performance  -> Descriptive Report
//   sales-drivers-> Diagnostic Report
//   forecast     -> Predictive Report
//   optimization -> Prescriptive Report (KPIs only for now, full recommendation engine TBD)
$tab = $_GET['tab'] ?? 'overview';
$validTabs = ['overview','performance','sales-drivers','forecast','optimization'];
if (!in_array($tab, $validTabs, true)) $tab = 'overview';

function tabUrl(string $t): string { return '?tab=' . $t; }

// ------------------------------------------------------------------
// Shared / Overview data
// ------------------------------------------------------------------
$totalRevenue = DB::fetch(
    'SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p
     JOIN ORDERS o ON p.order_id=o.order_id
     WHERE o.seller_id=? AND p.payment_status="Completed"',
    [$sellerId]
)['s'] ?? 0;

$totalOrders = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE seller_id=?', [$sellerId])['c'] ?? 0;

$listingsSold = DB::fetch(
    "SELECT COUNT(*) c FROM ORDERS WHERE seller_id=? AND status IN ('Delivered','Shipped','Out for Delivery')",
    [$sellerId]
)['c'] ?? 0;

$avgRating = DB::fetch(
    'SELECT COALESCE(AVG(rating),0) a FROM REVIEWS WHERE seller_id=? AND deleted_at IS NULL',
    [$sellerId]
)['a'] ?? 0;

$penaltyCount = DB::fetch('SELECT COUNT(*) c FROM PENALTIES WHERE seller_id=?', [$sellerId])['c'] ?? 0;
$activePenaltyCount = DB::fetch("SELECT COUNT(*) c FROM PENALTIES WHERE seller_id=? AND status='Active'", [$sellerId])['c'] ?? 0;

$revByMonth = DB::callAll('sp_monthly_revenue_trend', [$sellerId, 6]);

$revByCat = DB::callAll('sp_revenue_by_category', [$sellerId]);

$penalties = DB::fetchAll('SELECT * FROM PENALTIES WHERE seller_id=? ORDER BY issued_at DESC LIMIT 5', [$sellerId]);
$awards    = DB::fetchAll('SELECT * FROM SELLER_AWARDS WHERE seller_id=? ORDER BY issued_at DESC LIMIT 3', [$sellerId]);

// ------------------------------------------------------------------
// PERFORMANCE tab -- Descriptive Report KPIs
// ------------------------------------------------------------------
$authStats = ['Verified'=>0,'Pending'=>0,'Rejected'=>0];
if ($tab === 'performance') {
    $rows = DB::fetchAll(
        'SELECT a.authentication_status status, COUNT(*) c
         FROM AUTHENTICATION a JOIN LISTINGS l ON a.listing_id=l.listing_id
         WHERE l.seller_id=? GROUP BY a.authentication_status',
        [$sellerId]
    );
    foreach ($rows as $r) $authStats[$r['status']] = (int)$r['c'];
    $authTotal = array_sum($authStats);

    $authDetails = DB::fetchAll(
        'SELECT b.brand_name brand, l.title item, a.manufacture_year, a.authentication_status status,
                a.verified_by_admin_id, a.date_verified
         FROM AUTHENTICATION a
         JOIN LISTINGS l ON a.listing_id=l.listing_id
         JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
         JOIN BRANDS b ON pl.brand_id=b.brand_id
         WHERE l.seller_id=?
         ORDER BY a.date_verified DESC LIMIT 10',
        [$sellerId]
    );
}

// ------------------------------------------------------------------
// SALES DRIVERS tab -- Diagnostic Report KPIs
// ------------------------------------------------------------------
if ($tab === 'sales-drivers') {
    $totalCustomers = DB::fetch(
        'SELECT COUNT(DISTINCT buyer_id) c FROM ORDERS WHERE seller_id=?', [$sellerId]
    )['c'] ?? 0;

    $repeatCustomers = DB::fetch(
        'SELECT COUNT(*) c FROM (
            SELECT buyer_id FROM ORDERS WHERE seller_id=? GROUP BY buyer_id HAVING COUNT(*) > 1
         ) t', [$sellerId]
    )['c'] ?? 0;

    $avgSpendPerCustomer = $totalCustomers > 0 ? ($totalRevenue / $totalCustomers) : 0;

    $topCustomers = DB::callAll('sp_top_customers_for_seller', [$sellerId, 6]);

    $avgFollowers = DB::fetch(
        'SELECT COALESCE(AVG(la.follower_count),0) a
         FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=?', [$sellerId]
    )['a'] ?? 0;

    $avgConversion = DB::fetch(
        'SELECT COALESCE(AVG(la.view_to_bid_score),0) a
         FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=?', [$sellerId]
    )['a'] ?? 0;
}

// ------------------------------------------------------------------
// FORECAST tab -- Predictive Report KPIs
// ------------------------------------------------------------------
if ($tab === 'forecast') {
    // Simple trailing-average extrapolation (transparent, no black-box ML):
    // average of last 3 completed months x a modest seasonal growth factor.
    $last3 = DB::fetchAll(
        'SELECT SUM(p.amount_paid) total, COUNT(DISTINCT o.order_id) orders
         FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id
         WHERE o.seller_id=? AND p.payment_status="Completed"
           AND p.payment_date >= DATE_SUB(NOW(), INTERVAL 3 MONTH)',
        [$sellerId]
    );
    $baseRevenue = ((float)($last3[0]['total'] ?? 0)) / 3;
    $baseOrders  = ((float)($last3[0]['orders'] ?? 0)) / 3;
    $growthFactor = 1.10; // placeholder seasonal uplift, matches "BER months" bump in schema notes
    $projectedRevenue = $baseRevenue * $growthFactor;
    $projectedOrders  = round($baseOrders * $growthFactor);

    $avgPredictedPrice = DB::fetch(
        'SELECT COALESCE(AVG((pl.estimated_price_min + pl.estimated_price_max) / 2),0) a
         FROM LISTINGS l JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
         WHERE l.seller_id=? AND l.deleted_at IS NULL', [$sellerId]
    )['a'] ?? 0;

    $bestMonthRow = DB::fetch(
        'SELECT DATE_FORMAT(p.payment_date,"%M") mo, SUM(p.amount_paid) total
         FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id
         WHERE o.seller_id=? AND p.payment_status="Completed"
         GROUP BY MONTH(p.payment_date), mo ORDER BY total DESC LIMIT 1',
        [$sellerId]
    );
    $bestMonth = $bestMonthRow['mo'] ?? 'N/A';

    // 12-month seasonality projection: baseline = trailing 3-month average,
    // with the same "BER months" (Sep-Dec) seasonal uplift used when the
    // seed data was generated — transparent multipliers, not a black box.
    $seasonalMultipliers = [1=>0.95,2=>0.85,3=>0.85,4=>0.90,5=>0.90,6=>0.95,
                            7=>0.95,8=>1.00,9=>1.15,10=>1.25,11=>1.35,12=>1.45];
    $seasonalityForecast = [];
    for ($i = 0; $i < 12; $i++) {
        $monthNum = (int)date('n', strtotime("+$i month"));
        $label    = date('M', strtotime("+$i month"));
        $seasonalityForecast[] = ['label' => $label, 'value' => round($baseRevenue * ($seasonalMultipliers[$monthNum] ?? 1.0))];
    }

    // Brand Pricing Predictor: per-listing actual price vs. the predicted
    // price (midpoint of the brand/line's estimated price range) — same
    // "branded items cost more" assumption the reference report tests.
    $brandPricingPoints = DB::fetchAll(
        "SELECT l.price AS actual, (pl.estimated_price_min + pl.estimated_price_max)/2 AS predicted, pl.tier
         FROM LISTINGS l JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
         WHERE l.seller_id=? AND l.deleted_at IS NULL AND pl.estimated_price_min IS NOT NULL",
        [$sellerId]
    );

    // Top Brand Predictions table: aggregated by brand
    $topBrandPredictions = DB::fetchAll(
        "SELECT b.brand_name, pl.tier, AVG(l.price) AS avg_price,
                AVG((pl.estimated_price_min + pl.estimated_price_max)/2) AS avg_predicted
         FROM LISTINGS l
         JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
         JOIN BRANDS b ON pl.brand_id=b.brand_id
         WHERE l.seller_id=? AND l.deleted_at IS NULL AND pl.estimated_price_min IS NOT NULL AND b.brand_name != 'Unbranded'
         GROUP BY b.brand_id, b.brand_name, pl.tier
         ORDER BY avg_price DESC LIMIT 8",
        [$sellerId]
    );
}

// ------------------------------------------------------------------
// OPTIMIZATION tab -- Prescriptive Report
// ------------------------------------------------------------------
if ($tab === 'optimization') {
    $listingsAnalyzed = DB::fetch(
        'SELECT COUNT(*) c FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=?', [$sellerId]
    )['c'] ?? 0;

    $avgCompleteness = DB::fetch(
        'SELECT COALESCE(AVG(la.completeness_score),0) a
         FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=?', [$sellerId]
    )['a'] ?? 0;

    $avgViewToBid = DB::fetch(
        'SELECT COALESCE(AVG(la.view_to_bid_score),0) a
         FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=?', [$sellerId]
    )['a'] ?? 0;

    $needsImprovement = DB::fetch(
        'SELECT COUNT(*) c FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=? AND la.completeness_score < 70', [$sellerId]
    )['c'] ?? 0;

    // Sub-score breakdown for the completeness donut/bars
    $scoreBreakdown = DB::fetch(
        'SELECT COALESCE(AVG(la.photo_score),0) photos, COALESCE(AVG(la.details_score),0) details,
                COALESCE(AVG(la.condition_score),0) condition_s, COALESCE(AVG(la.shipping_score),0) shipping,
                COALESCE(AVG(la.pricing_score),0) pricing
         FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=?', [$sellerId]
    ) ?: ['photos'=>0,'details'=>0,'condition_s'=>0,'shipping'=>0,'pricing'=>0];

    // Top Listing Issues: how many listings fall below a healthy threshold
    // on each dimension — this is what actually drives the recommendation
    // cards below (still just counts/links, not a full suggestion engine).
    $issueThresholds = [
        'photos'     => ['label' => 'Missing or low-quality photos',   'icon' => 'image',            'col' => 'photo_score'],
        'details'    => ['label' => 'Missing product details',         'icon' => 'description',      'col' => 'details_score'],
        'condition_s'=> ['label' => 'Incomplete item condition',       'icon' => 'checklist',         'col' => 'condition_score'],
        'shipping'   => ['label' => 'No shipping information',         'icon' => 'local_shipping',    'col' => 'shipping_score'],
        'pricing'    => ['label' => 'Pricing not competitive',         'icon' => 'payments',          'col' => 'pricing_score'],
    ];
    $topIssues = [];
    foreach ($issueThresholds as $key => $meta) {
        $cnt = DB::fetch(
            "SELECT COUNT(*) c FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
             WHERE l.seller_id=? AND la.{$meta['col']} < 70",
            [$sellerId]
        )['c'] ?? 0;
        $topIssues[] = ['label' => $meta['label'], 'icon' => $meta['icon'], 'count' => (int)$cnt];
    }
    usort($topIssues, fn($a,$b) => $b['count'] <=> $a['count']);
}

renderHead('Analytics');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('analytics', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('analytics'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Seller Analytics</h1>
  <p class="tb-page-subtitle mb-6">Track performance, revenue, and marketplace insights.</p>

  <!-- Report tabs -->
  <div class="tb-tabs mb-8">
    <?php
    $tabLabels = [
        'overview'      => 'Overview',
        'performance'   => 'Performance',
        'sales-drivers' => 'Sales Drivers',
        'forecast'      => 'Forecast',
        'optimization'  => 'Optimization',
    ];
    foreach ($tabLabels as $key => $label): ?>
    <a href="<?= tabUrl($key) ?>" class="tb-tab-link <?= $tab === $key ? 'active' : '' ?>"><?= $label ?></a>
    <?php endforeach; ?>
  </div>

  <?php if ($tab === 'overview'): ?>
  <!-- =================== OVERVIEW =================== -->
  <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'payments',   'label'=>'Total Revenue',  'val'=>convertCurrency((float)$totalRevenue)],
      ['icon'=>'package_2',  'label'=>'Listings Sold',  'val'=>$listingsSold],
      ['icon'=>'receipt_long','label'=>'Total Orders',  'val'=>$totalOrders],
      ['icon'=>'star',       'label'=>'Avg Seller Rating','val'=>($avgRating?number_format($avgRating,1).'/5':'N/A')],
      ['icon'=>'block',      'label'=>'Penalty Count',  'val'=>$penaltyCount],
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

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:20px">Monthly Revenue</h3>
      <?php if (!empty($revByMonth)): ?>
      <canvas id="revChart" height="180"></canvas>
      <?php else: ?>
      <div style="height:180px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary)">No revenue data yet</div>
      <?php endif; ?>
    </div>
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:20px">Revenue by Category</h3>
      <?php if (!empty($revByCat)): ?>
      <div style="display:flex;align-items:center;gap:20px;flex-wrap:wrap">
        <div style="position:relative;width:180px;height:180px;flex-shrink:0">
          <canvas id="catDonut"></canvas>
          <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;pointer-events:none">
            <span style="font-size:11px;color:var(--clr-tertiary)">Total Revenue</span>
            <span style="font-size:15px;font-weight:800;color:var(--clr-text)"><?= convertCurrency((float)array_sum(array_column($revByCat,'total'))) ?></span>
          </div>
        </div>
        <div style="flex:1;min-width:160px;display:flex;flex-direction:column;gap:8px">
          <?php $catColors=['#ff6b6b','#66bb6a','#ffc107','#4a7fc9','#8e6bff','#26c6da','#ef5350','#78909c'];
          foreach ($revByCat as $i => $rc): ?>
          <div style="display:flex;align-items:center;gap:8px;font-size:var(--fs-label-sm)">
            <span style="width:9px;height:9px;border-radius:50%;background:<?= $catColors[$i % count($catColors)] ?>;flex-shrink:0"></span>
            <span style="flex:1"><?= htmlspecialchars($rc['name']) ?></span>
            <span style="color:var(--clr-tertiary);font-weight:600"><?= convertCurrency((float)$rc['total']) ?></span>
          </div>
          <?php endforeach; ?>
        </div>
      </div>
      <?php else: ?>
      <div style="color:var(--clr-tertiary)">No category data yet</div>
      <?php endif; ?>
    </div>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div class="tb-card">
      <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Recent Penalties</h3></div>
      <div class="tb-card-body">
        <?php if (empty($penalties)): ?>
        <div style="text-align:center;padding:24px;color:var(--clr-tertiary)">
          <span class="material-symbols-outlined icon-lg" style="color:var(--clr-success)">verified_user</span>
          <p style="margin-top:8px;font-weight:600">Clean record</p>
        </div>
        <?php else: foreach ($penalties as $p): ?>
        <div style="display:flex;justify-content:space-between;align-items:flex-start;padding:12px;border-radius:var(--radius-lg);background:var(--clr-surface-low);margin-bottom:8px">
          <div>
            <p style="font-size:var(--fs-label-md);font-weight:600"><?= htmlspecialchars($p['reason']) ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($p['issued_at'])) ?></p>
          </div>
          <span class="tb-badge <?= $p['status']==='Active'?'tb-badge-red':'tb-badge-gray' ?>"><?= $p['status'] ?></span>
        </div>
        <?php endforeach; endif; ?>
      </div>
    </div>
    <div class="tb-card">
      <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Recent Awards</h3></div>
      <div class="tb-card-body">
        <?php if (empty($awards)): ?>
        <div style="text-align:center;padding:24px;color:var(--clr-tertiary)">No awards yet. Keep selling to earn recognition!</div>
        <?php else: foreach ($awards as $a): ?>
        <div style="display:flex;justify-content:space-between;align-items:flex-start;padding:12px;border-radius:var(--radius-lg);background:rgba(255,203,119,0.12);border:1px solid rgba(255,203,119,0.3);margin-bottom:8px">
          <div>
            <p style="font-size:var(--fs-label-md);font-weight:600"><?= htmlspecialchars($a['reason']) ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($a['issued_at'])) ?></p>
          </div>
          <span class="tb-badge tb-badge-coral"><?= $a['status'] ?></span>
        </div>
        <?php endforeach; endif; ?>
      </div>
    </div>
  </div>

  <?php elseif ($tab === 'performance'): ?>
  <!-- =================== PERFORMANCE (Descriptive Report) =================== -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'payments',    'label'=>'Total Revenue',  'val'=>convertCurrency((float)$totalRevenue)],
      ['icon'=>'package_2',   'label'=>'Listings Sold',  'val'=>$listingsSold],
      ['icon'=>'star',        'label'=>'Seller Rating',  'val'=>($avgRating?number_format($avgRating,1).'/5':'N/A')],
      ['icon'=>'block',       'label'=>'Penalty Count',  'val'=>$penaltyCount],
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

  <div class="tb-card mb-6">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Seller Performance</h3></div>
    <div class="tb-card-body">
      <canvas id="perfChart" height="140"></canvas>
      <p style="text-align:center;font-size:11px;color:var(--clr-tertiary);margin-top:8px">Performance Scale (Higher is Better) — each metric normalized to 0–100</p>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-2">
    <div class="tb-card tb-card-body" style="text-align:center;background:rgba(102,187,106,0.08)">
      <div style="font-size:32px;font-weight:800;color:var(--clr-success)"><?= $authStats['Verified'] ?></div>
      <p style="font-weight:600">Verified</p>
      <p style="font-size:12px;color:var(--clr-tertiary)"><?= $authTotal>0?round($authStats['Verified']/$authTotal*100):0 ?>% of total</p>
    </div>
    <div class="tb-card tb-card-body" style="text-align:center;background:rgba(255,203,119,0.12)">
      <div style="font-size:32px;font-weight:800;color:#c98a1f"><?= $authStats['Pending'] ?></div>
      <p style="font-weight:600">Pending</p>
      <p style="font-size:12px;color:var(--clr-tertiary)"><?= $authTotal>0?round($authStats['Pending']/$authTotal*100):0 ?>% of total</p>
    </div>
    <div class="tb-card tb-card-body" style="text-align:center;background:rgba(255,107,107,0.08)">
      <div style="font-size:32px;font-weight:800;color:var(--clr-coral)"><?= $authStats['Rejected'] ?></div>
      <p style="font-weight:600">Rejected</p>
      <p style="font-size:12px;color:var(--clr-tertiary)"><?= $authTotal>0?round($authStats['Rejected']/$authTotal*100):0 ?>% of total</p>
    </div>
  </div>

  <div class="tb-card">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Product Authentication Details</h3></div>
    <div class="tb-card-body" style="overflow-x:auto">
      <?php if (empty($authDetails)): ?>
      <div style="color:var(--clr-tertiary)">No branded items submitted for authentication yet.</div>
      <?php else: ?>
      <table class="tb-table">
        <thead><tr><th>Brand</th><th>Item</th><th>Year Manufactured</th><th>Status</th><th>Date Verified</th></tr></thead>
        <tbody>
        <?php foreach ($authDetails as $d): ?>
        <tr>
          <td><?= htmlspecialchars($d['brand']) ?></td>
          <td><?= htmlspecialchars($d['item']) ?></td>
          <td><?= $d['manufacture_year'] ?: '-' ?></td>
          <td><span class="tb-badge <?= $d['status']==='Verified'?'tb-badge-green':($d['status']==='Rejected'?'tb-badge-red':'tb-badge-coral') ?>"><?= $d['status'] ?></span></td>
          <td><?= $d['date_verified'] ? date('M d, Y', strtotime($d['date_verified'])) : '-' ?></td>
        </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
      <?php endif; ?>
    </div>
  </div>

  <?php elseif ($tab === 'sales-drivers'): ?>
  <!-- =================== SALES DRIVERS (Diagnostic Report) =================== -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'group',        'label'=>'Total Customers',       'val'=>$totalCustomers],
      ['icon'=>'receipt_long', 'label'=>'Total Orders',          'val'=>$totalOrders],
      ['icon'=>'repeat',       'label'=>'Repeat Customers',      'val'=>$repeatCustomers],
      ['icon'=>'payments',     'label'=>'Avg Spend / Customer',  'val'=>convertCurrency((float)$avgSpendPerCustomer)],
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

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:16px">Top Customers by Spending</h3>
      <?php if (empty($topCustomers)): ?>
      <div style="color:var(--clr-tertiary)">No customer data yet</div>
      <?php else: ?>
      <div style="position:relative;height:<?= max(140, count($topCustomers) * 40) ?>px">
        <canvas id="topCustomersChart"></canvas>
      </div>
      <?php endif; ?>
    </div>
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:12px">Insights</h3>
      <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:10px">
        Average Instagram follower count across your listings is
        <strong><?= number_format($avgFollowers) ?></strong>, with an average view-to-bid conversion of
        <strong><?= number_format($avgConversion,1) ?>%</strong>.
      </p>
      <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary)">
        Listings with higher follower counts tend to have better conversion rates. Focus on
        increasing followers and engagement to boost sales.
      </p>
    </div>
  </div>

  <?php elseif ($tab === 'forecast'): ?>
  <!-- =================== FORECAST (Predictive Report) =================== -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'trending_up', 'label'=>'Projected Revenue (30d)', 'val'=>convertCurrency((float)$projectedRevenue)],
      ['icon'=>'shopping_bag','label'=>'Projected Orders (30d)',  'val'=>$projectedOrders],
      ['icon'=>'sell',        'label'=>'Avg Predicted Price',     'val'=>convertCurrency((float)$avgPredictedPrice)],
      ['icon'=>'event',       'label'=>'Best Performing Month',   'val'=>$bestMonth],
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
  <div class="tb-card mb-2">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Seasonality Forecast — Next 12 Months</h3></div>
    <div class="tb-card-body">
      <canvas id="seasonChart" height="110"></canvas>
      <p style="text-align:center;font-size:11px;color:var(--clr-tertiary);margin-top:8px">Peak season: "BER" months (Sep–Dec) &bull; based on your trailing 3-month sales average</p>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Brand Pricing Predictor</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Tests the assumption that branded items are inherently more expensive.</p>
      <?php if (empty($brandPricingPoints)): ?>
      <div style="color:var(--clr-tertiary)">Not enough brand data yet.</div>
      <?php else: ?>
      <canvas id="brandScatter" height="200"></canvas>
      <?php endif; ?>
    </div>
    <div class="tb-card">
      <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Top Brand Predictions</h3></div>
      <div class="tb-card-body" style="overflow-x:auto">
        <?php if (empty($topBrandPredictions)): ?>
        <div style="color:var(--clr-tertiary)">Not enough brand data yet.</div>
        <?php else: ?>
        <table class="tb-table">
          <thead><tr><th>Brand</th><th>Tier</th><th>Avg Price</th><th>Predicted</th><th>Difference</th></tr></thead>
          <tbody>
            <?php foreach ($topBrandPredictions as $bp):
              $diff = $bp['avg_predicted'] > 0 ? (($bp['avg_price'] - $bp['avg_predicted']) / $bp['avg_predicted']) * 100 : 0;
            ?>
            <tr>
              <td style="font-weight:600"><?= htmlspecialchars($bp['brand_name']) ?></td>
              <td><span class="tb-badge tb-badge-gray"><?= htmlspecialchars($bp['tier']) ?></span></td>
              <td><?= convertCurrency((float)$bp['avg_price']) ?></td>
              <td style="color:var(--clr-tertiary)"><?= convertCurrency((float)$bp['avg_predicted']) ?></td>
              <td style="color:<?= $diff>=0?'var(--clr-success)':'var(--clr-error)' ?>;font-weight:600"><?= $diff>=0?'+':'' ?><?= number_format($diff,1) ?>%</td>
            </tr>
            <?php endforeach; ?>
          </tbody>
        </table>
        <?php endif; ?>
      </div>
    </div>
  </div>

  <?php elseif ($tab === 'optimization'): ?>
  <!-- =================== OPTIMIZATION (Prescriptive Report) =================== -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'checklist',  'label'=>'Total Listings Analyzed', 'val'=>$listingsAnalyzed],
      ['icon'=>'task_alt',   'label'=>'Avg Completeness Score',  'val'=>number_format($avgCompleteness,0).'/100'],
      ['icon'=>'insights',   'label'=>'Avg View-to-Bid Conv.',    'val'=>number_format($avgViewToBid,1).'%'],
      ['icon'=>'warning',    'label'=>'Listings Needing Improvement','val'=>$needsImprovement],
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

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Listing Completeness Score</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Your listings' completeness score</p>
      <div style="display:flex;align-items:center;gap:24px;flex-wrap:wrap">
        <div style="position:relative;width:150px;height:150px;flex-shrink:0">
          <canvas id="completenessGauge"></canvas>
          <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;pointer-events:none">
            <span style="font-size:26px;font-weight:800;color:var(--clr-text)"><?= number_format($avgCompleteness,0) ?></span>
            <span style="font-size:11px;color:var(--clr-tertiary)">/ 100</span>
            <span style="font-size:11px;font-weight:700;color:var(--clr-coral);margin-top:2px"><?= $avgCompleteness>=70?'Good':($avgCompleteness>=50?'Fair':'Needs Work') ?></span>
          </div>
        </div>
        <div style="flex:1;min-width:180px;display:flex;flex-direction:column;gap:10px">
          <?php $subScores=[
            ['icon'=>'image','label'=>'Photos','val'=>$scoreBreakdown['photos']],
            ['icon'=>'description','label'=>'Product Details','val'=>$scoreBreakdown['details']],
            ['icon'=>'checklist','label'=>'Item Condition','val'=>$scoreBreakdown['condition_s']],
            ['icon'=>'local_shipping','label'=>'Shipping Info','val'=>$scoreBreakdown['shipping']],
            ['icon'=>'payments','label'=>'Pricing Info','val'=>$scoreBreakdown['pricing']],
          ]; foreach ($subScores as $s): $pct=round($s['val']); ?>
          <div style="display:flex;align-items:center;gap:8px;font-size:var(--fs-label-sm)">
            <span class="material-symbols-outlined icon-sm" style="color:var(--clr-tertiary)"><?= $s['icon'] ?></span>
            <span style="width:90px"><?= $s['label'] ?></span>
            <div class="tb-progress-bar" style="flex:1"><div class="tb-progress-fill" style="width:<?= $pct ?>%;background:<?= $pct>=70?'var(--clr-success)':'var(--clr-yellow)' ?>"></div></div>
            <span style="width:44px;text-align:right;color:var(--clr-tertiary)"><?= $pct ?>/100</span>
          </div>
          <?php endforeach; ?>
        </div>
      </div>
      <p style="font-size:11px;color:var(--clr-tertiary);margin-top:14px">A complete listing increases the chance of getting higher bids and more sales.</p>
    </div>

    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Top Listing Issues</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Common issues found in your listings</p>
      <?php if ($listingsAnalyzed === 0): ?>
      <div style="color:var(--clr-tertiary)">No listings analyzed yet.</div>
      <?php else: foreach ($topIssues as $issue): ?>
      <div style="display:flex;align-items:center;gap:12px;padding:10px 0;border-bottom:1px solid var(--clr-outline)">
        <span class="material-symbols-outlined icon-sm" style="color:var(--clr-tertiary)"><?= $issue['icon'] ?></span>
        <span style="flex:1;font-size:var(--fs-label-md)"><?= $issue['label'] ?></span>
        <span class="tb-badge tb-badge-coral"><?= $issue['count'] ?></span>
        <a href="active-auctions.php" class="btn btn-outline btn-sm">View Listings</a>
      </div>
      <?php endforeach; endif; ?>
      <p style="font-size:11px;color:var(--clr-tertiary);margin-top:14px">Fixing these issues can significantly improve your listing performance.</p>
    </div>
  </div>

  <div class="tb-card tb-card-body">
    <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Listing Optimization Recommendations</h3>
    <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Actionable suggestions to improve your listings and increase the likelihood of a successful sale.</p>
    <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
      <?php $recs = [
        ['color'=>'#e3f0ff','icon'=>'image','label'=>'Add More Photos','desc'=>'Listings with 3+ high quality photos get more views and higher bids.','cta'=>'Add Photos','href'=>'create-listing.php'],
        ['color'=>'#e3f7e8','icon'=>'description','label'=>'Complete Buyer Details','desc'=>'Add brand, material, size, and other key details to build buyer trust.','cta'=>'Edit Details','href'=>'active-auctions.php'],
        ['color'=>'#fff6de','icon'=>'checklist','label'=>'Specify Item Condition','desc'=>'Clear condition helps buyers make decisions with confidence.','cta'=>'Update Condition','href'=>'active-auctions.php'],
        ['color'=>'#f1e9ff','icon'=>'local_shipping','label'=>'Add Shipping Info','desc'=>'Provide shipping cost and delivery time to avoid cart abandonment.','cta'=>'Add Shipping Info','href'=>'active-auctions.php'],
        ['color'=>'#ffe3e3','icon'=>'payments','label'=>'Review Your Pricing','desc'=>'Consider some items that may be priced higher than similar listings.','cta'=>'Review Pricing','href'=>'active-auctions.php'],
      ]; foreach ($recs as $r): ?>
      <div style="background:<?= $r['color'] ?>;border-radius:var(--radius-lg);padding:16px">
        <span class="material-symbols-outlined icon-md" style="color:var(--clr-text)"><?= $r['icon'] ?></span>
        <p style="font-weight:700;font-size:var(--fs-label-md);margin-top:8px"><?= $r['label'] ?></p>
        <p style="font-size:11px;color:var(--clr-tertiary);margin-top:4px;min-height:44px"><?= $r['desc'] ?></p>
        <a href="<?= $r['href'] ?>" class="btn btn-outline btn-sm btn-full" style="background:#fff;margin-top:8px"><?= $r['cta'] ?></a>
      </div>
      <?php endforeach; ?>
    </div>
    <p style="font-size:11px;color:var(--clr-tertiary);margin-top:16px">Small improvements can lead to big results. Follow these recommendations and watch your sales grow.</p>
  </div>
  <?php endif; ?>

</div>
</main>
</div>

<?php if (in_array($tab, ['overview','performance','sales-drivers','forecast','optimization'], true)): ?>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
<?php if ($tab === 'overview'): ?>
  <?php if (!empty($revByMonth)): ?>
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
  <?php endif; ?>
  <?php if (!empty($revByCat)): ?>
  new Chart(document.getElementById('catDonut'), {
    type:'doughnut',
    data:{
      labels:<?= json_encode(array_column($revByCat,'name')) ?>,
      datasets:[{
        data:<?= json_encode(array_map(fn($r)=>(float)$r['total'],$revByCat)) ?>,
        backgroundColor:['#ff6b6b','#66bb6a','#ffc107','#4a7fc9','#8e6bff','#26c6da','#ef5350','#78909c'],
        borderWidth:2, borderColor:'#fff',
      }]
    },
    options:{responsive:true,cutout:'68%',plugins:{legend:{display:false}}}
  });
  <?php endif; ?>

<?php elseif ($tab === 'performance'): ?>
  new Chart(document.getElementById('perfChart'), {
    type:'bar',
    data:{
      labels:['Total Revenue','Listings Sold','Seller Rating','Penalty Count'],
      datasets:[{
        data:[
          Math.min(100, <?= (float)$totalRevenue ?> / 2000),
          Math.min(100, <?= (int)$listingsSold ?> * 2),
          <?= (float)$avgRating ?> * 20,
          Math.max(0, 100 - <?= (int)$penaltyCount ?> * 25)
        ],
        backgroundColor:'rgba(255,107,107,0.7)', borderColor:'#ff6b6b', borderWidth:2, borderRadius:6,
      }]
    },
    options:{indexAxis:'y',responsive:true,plugins:{legend:{display:false}},scales:{x:{beginAtZero:true,max:100}}}
  });

<?php elseif ($tab === 'sales-drivers'): ?>
  <?php if (!empty($topCustomers)): ?>
  new Chart(document.getElementById('topCustomersChart'), {
    type:'bar',
    data:{
      labels:<?= json_encode(array_column($topCustomers,'username')) ?>,
      datasets:[{
        label:'Total Spending (₱)',
        data:<?= json_encode(array_map(fn($r)=>(float)$r['total'],$topCustomers)) ?>,
        backgroundColor:'rgba(255,107,107,0.7)', borderColor:'#ff6b6b', borderWidth:2, borderRadius:6,
      }]
    },
    options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{beginAtZero:true,ticks:{callback:v=>'₱'+v.toLocaleString()}}}}
  });
  <?php endif; ?>

<?php elseif ($tab === 'forecast'): ?>
  new Chart(document.getElementById('seasonChart'), {
    type:'line',
    data:{
      labels:<?= json_encode(array_column($seasonalityForecast,'label')) ?>,
      datasets:[{
        label:'Projected Revenue (₱)',
        data:<?= json_encode(array_column($seasonalityForecast,'value')) ?>,
        borderColor:'#ff6b6b', backgroundColor:'rgba(255,107,107,0.12)',
        borderWidth:2, fill:true, tension:0.35, pointBackgroundColor:'#ff6b6b', pointRadius:3,
      }]
    },
    options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{callback:v=>'₱'+v.toLocaleString()}}}}
  });
  <?php if (!empty($brandPricingPoints)): ?>
  <?php
    $tierColors = ['High' => '#ff6b6b', 'Mid' => '#4a7fc9', 'Low' => '#66bb6a', 'Unbranded' => '#78909c'];
    $byTier = [];
    foreach ($brandPricingPoints as $pt) { $byTier[$pt['tier']][] = ['x' => (float)$pt['actual'], 'y' => (float)$pt['predicted']]; }
  ?>
  new Chart(document.getElementById('brandScatter'), {
    type:'scatter',
    data:{
      datasets:[
        <?php foreach ($byTier as $tier => $pts): ?>
        { label:<?= json_encode($tier) ?>, data:<?= json_encode($pts) ?>, backgroundColor:<?= json_encode($tierColors[$tier] ?? '#999') ?> },
        <?php endforeach; ?>
      ]
    },
    options:{responsive:true,plugins:{legend:{position:'top'}},
      scales:{
        x:{title:{display:true,text:'Actual Price (₱)'},ticks:{callback:v=>'₱'+v.toLocaleString()}},
        y:{title:{display:true,text:'Predicted Price (₱)'},ticks:{callback:v=>'₱'+v.toLocaleString()}}
      }}
  });
  <?php endif; ?>
<?php elseif ($tab === 'optimization'): ?>
  new Chart(document.getElementById('completenessGauge'), {
    type:'doughnut',
    data:{
      datasets:[{
        data:[<?= (float)$avgCompleteness ?>, <?= max(0, 100 - (float)$avgCompleteness) ?>],
        backgroundColor:['#ff6b6b', '#f0f0f0'],
        borderWidth:0,
      }]
    },
    options:{responsive:true,cutout:'75%',plugins:{legend:{display:false},tooltip:{enabled:false}}}
  });
<?php endif; ?>
</script>
<?php endif; ?>

</body></html>