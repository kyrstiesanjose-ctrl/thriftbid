<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php'; /* live exchange rates */
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole('seller'); 

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id']; /* session row IS the seller row */

/* Tab -> report type mapping:
   overview      -> summary
   performance   -> Descriptive Report
   sales-drivers -> Diagnostic Report
   forecast      -> Predictive Report
   optimization  -> Prescriptive Report */
$tab = $_GET['tab'] ?? 'overview';
$validTabs = ['overview','performance','sales-drivers','forecast','optimization'];
if (!in_array($tab, $validTabs, true)) $tab = 'overview';

function tabUrl(string $t): string { return '?tab=' . $t; }

/* Period filter (Daily/Weekly/Monthly/Yearly/Custom), shared across
   tabs via layout.php's renderPeriodFilter()/periodSqlParts() */
$period = $_GET['period'] ?? 'monthly';
$validPeriods = ['daily','weekly','monthly','yearly','custom'];
if (!in_array($period, $validPeriods, true)) $period = 'monthly';
$filterFrom = $_GET['from'] ?? null;
$filterTo   = $_GET['to'] ?? null;

/* OVERVIEW tab data */
$totalRevenue = DB::fetch(
    'SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p
     JOIN ORDERS o ON p.order_id=o.order_id
     WHERE o.seller_id=? AND p.payment_status="Completed"',
    [$sellerId]
)['s'] ?? 0;

/* Today's revenue only. SET time_zone = '+08:00'  */
$todayRevenue = DB::fetch(
    'SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p
     JOIN ORDERS o ON p.order_id=o.order_id
     WHERE o.seller_id=? AND p.payment_status="Completed" AND DATE(p.payment_date)=CURDATE()',
    [$sellerId]
)['s'] ?? 0;

/* All orders, all time (not just paid ones) */
$totalOrders = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE seller_id=?', [$sellerId])['c'] ?? 0;

/* Orders that reached Shipped/Out for Delivery/Delivered */
$listingsSold = DB::fetch(
    "SELECT COUNT(*) c FROM ORDERS WHERE seller_id=? AND status IN ('Delivered','Shipped','Out for Delivery')",
    [$sellerId]
)['c'] ?? 0;

/* REVIEWS is soft-deleted (deleted_at), not hard-deleted, hence the filter */
$avgRating = DB::fetch(
    'SELECT COALESCE(AVG(rating),0) a FROM REVIEWS WHERE seller_id=? AND deleted_at IS NULL',
    [$sellerId]
)['a'] ?? 0;

/* PENALTIES rows come from the after_penalty_insert_escalate trigger
   (Rule 6, shipping) and the Rule 7 non-paying-buyer event, nothing here writes to PENALTIES directly */

$penaltyCount = DB::fetch('SELECT COUNT(*) c FROM PENALTIES WHERE seller_id=?', [$sellerId])['c'] ?? 0;
$activePenaltyCount = DB::fetch("SELECT COUNT(*) c FROM PENALTIES WHERE seller_id=? AND status='Active'", [$sellerId])['c'] ?? 0;

[$mrGroup, $mrLabel, $mrWhere, $mrParams] = periodSqlParts($period, 'p.payment_date', $filterFrom, $filterTo);
$revByMonth = DB::fetchAll(
    "SELECT $mrGroup AS grp, $mrLabel AS mo, SUM(p.amount_paid) AS total
     FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id
     WHERE o.seller_id=? AND p.payment_status='Completed' AND $mrWhere
     GROUP BY grp, mo ORDER BY grp",
    array_merge([$sellerId], $mrParams)
);

$revByCat = DB::callAll('sp_revenue_by_category', [$sellerId]);

$penalties = DB::fetchAll('SELECT * FROM PENALTIES WHERE seller_id=? ORDER BY issued_at DESC LIMIT 5', [$sellerId]);
$awards    = DB::fetchAll('SELECT * FROM SELLER_AWARDS WHERE seller_id=? ORDER BY issued_at DESC LIMIT 3', [$sellerId]);

/* PERFORMANCE tab data */
$authStats = ['Verified'=>0,'Pending'=>0,'Rejected'=>0];
if ($tab === 'performance') {

    /* Revenue and listings sold, filtered to the selected period - feeds the Seller Performance chart */
    [$pfGroup, $pfLabel, $pfWhere, $pfParams] = periodSqlParts($period, 'p.payment_date', $filterFrom, $filterTo);
    $perfRevenue = DB::fetch(
        "SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p
         JOIN ORDERS o ON p.order_id=o.order_id
         WHERE o.seller_id=? AND p.payment_status='Completed' AND $pfWhere",
        array_merge([$sellerId], $pfParams)
    )['s'] ?? 0;

    [$pfOGroup, $pfOLabel, $pfOWhere, $pfOParams] = periodSqlParts($period, 'o.order_date', $filterFrom, $filterTo);
    $perfListingsSold = DB::fetch(
        "SELECT COUNT(*) c FROM ORDERS o
         WHERE o.seller_id=? AND o.status IN ('Delivered','Shipped','Out for Delivery') AND $pfOWhere",
        array_merge([$sellerId], $pfOParams)
    )['c'] ?? 0;

    $rows = DB::fetchAll(
        'SELECT a.authentication_status status, COUNT(*) c
         FROM AUTHENTICATION a JOIN LISTINGS l ON a.listing_id=l.listing_id
         WHERE l.seller_id=? GROUP BY a.authentication_status',
        [$sellerId]
    );
    foreach ($rows as $r) $authStats[$r['status']] = (int)$r['c'];
    $authTotal = array_sum($authStats);

    $authDetails = DB::fetchAll(
        'SELECT l.listing_id, b.brand_name brand, l.title item, a.manufacture_year, a.authentication_status status,
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

/* SALES DRIVERS tab data */

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

    /* Top spenders within the selected period */
    [$csGroup, $csLabel, $csWhere, $csParams] = periodSqlParts($period, 'p.payment_date', $filterFrom, $filterTo);
    $topCustomers = DB::fetchAll(
        "SELECT b.username, SUM(p.amount_paid) AS total, COUNT(o.order_id) AS order_volume
         FROM BUYER b
         JOIN ORDERS o ON b.buyer_id=o.buyer_id
         JOIN PAYMENTS p ON o.order_id=p.order_id
         WHERE o.seller_id=? AND p.payment_status='Completed' AND $csWhere
         GROUP BY b.buyer_id, b.username
         ORDER BY total DESC LIMIT 6",
        array_merge([$sellerId], $csParams)
    );

    /* Orders, distinct customers, and conversion rate per period -
       shows where sales activity clusters over time. */
    [$sbGroup, $sbLabel, $sbWhere, $sbParams] = periodSqlParts($period, 'o.order_date', $filterFrom, $filterTo);
    $salesBias = DB::fetchAll(
        "SELECT $sbGroup AS grp, $sbLabel AS label,
                COUNT(o.order_id) AS orders,
                COUNT(DISTINCT o.buyer_id) AS customers,
                ROUND(COUNT(o.order_id) / NULLIF(COUNT(DISTINCT o.buyer_id),0), 2) AS conversion_rate
         FROM ORDERS o
         WHERE o.seller_id=? AND $sbWhere
         GROUP BY grp, label ORDER BY grp",
        array_merge([$sellerId], $sbParams)
    );

    /* PHP to USD/KRW exchange rate trend, from the CURRENCY_RATES table */

    [$crGroup, $crLabel, $crWhere, $crParams] = periodSqlParts($period, 'recorded_date', $filterFrom, $filterTo);
    $currencyRows = DB::fetchAll(
        "SELECT $crGroup AS grp, $crLabel AS label, target_currency, exchange_rate
         FROM CURRENCY_RATES
         WHERE base_currency='PHP' AND $crWhere
         ORDER BY grp",
        $crParams
    );
    $currencyLabels = [];
    $currencyByCcy  = ['USD' => [], 'KRW' => []];
    foreach ($currencyRows as $row) {
        if (!in_array($row['label'], $currencyLabels, true)) $currencyLabels[] = $row['label'];
        if (isset($currencyByCcy[$row['target_currency']])) {
            $currencyByCcy[$row['target_currency']][$row['label']] = (float)$row['exchange_rate'];
        }
    }

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


    /* Conversion rate and its likely driver, broken down by parent category */
    $categoryDiagnostics = DB::fetchAll(
        'SELECT pc.parent_category AS category,
                COUNT(*) AS listing_count,
                AVG(la.view_to_bid_score) AS conversion,
                AVG(la.photo_score) AS photo_score,
                AVG(la.details_score) AS details_score,
                AVG(la.pricing_score) AS pricing_score,
                AVG(la.condition_score) AS condition_score
         FROM LISTING_ANALYTICS la
         JOIN LISTINGS l ON la.listing_id=l.listing_id
         JOIN CATEGORIES c ON l.category_id=c.category_id
         JOIN PARENT_CATEGORIES pc ON c.parent_category_id=pc.parent_category_id
         WHERE l.seller_id=?
         GROUP BY pc.parent_category
         HAVING COUNT(*) >= 2
         ORDER BY conversion ASC',
        [$sellerId]
    );

    $diagnosticFinding = null;
    if (count($categoryDiagnostics) >= 2) {
        $worst = $categoryDiagnostics[0];
        $best  = $categoryDiagnostics[count($categoryDiagnostics) - 1];
        
        /* Only flag a finding if the gap is at least 3 points - a 1-2
           point difference on a small sample is noise, not a real cause.
           The score with the biggest gap between best and worst category
           is reported as the likely cause. */
        if ($best['conversion'] - $worst['conversion'] >= 3) {
            $scoreFields = ['photo_score' => 'photo completeness', 'details_score' => 'listing detail completeness', 'pricing_score' => 'pricing consistency', 'condition_score' => 'condition accuracy'];
            $biggestGapField = null; $biggestGap = -1;
            foreach ($scoreFields as $field => $label) {
                $gap = (float)$best[$field] - (float)$worst[$field];
                if ($gap > $biggestGap) { $biggestGap = $gap; $biggestGapField = $label; }
            }
            $diagnosticFinding = [
                'worst_category' => $worst['category'], 'worst_conversion' => (float)$worst['conversion'],
                'best_category' => $best['category'], 'best_conversion' => (float)$best['conversion'],
                'likely_cause' => $biggestGapField, 'gap' => round($biggestGap, 1),
            ];
        }
    }
}

/* FORECAST tab data */
if ($tab === 'forecast') {
    /* Projection = average of the last 3 completed months x a seasonal
       growth factor. No ML model, kept simple and explainable. */
    $last3 = DB::fetchAll(
        'SELECT SUM(p.amount_paid) total, COUNT(DISTINCT o.order_id) orders
         FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id
         WHERE o.seller_id=? AND p.payment_status="Completed"
           AND p.payment_date >= DATE_SUB(NOW(), INTERVAL 3 MONTH)',
        [$sellerId]
    );
    $baseRevenue = ((float)($last3[0]['total'] ?? 0)) / 3;
    $baseOrders  = ((float)($last3[0]['orders'] ?? 0)) / 3;
    $growthFactor = 1.10; /* seasonal uplift factor, matches "BER months" bump used elsewhere */
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

    /* Projection follows the period filter. Baseline = 3-month average,
       with a Sep-Dec ("BER month") demand uplift applied. */
    $seasonalMultipliers = [1=>0.95,2=>0.85,3=>0.85,4=>0.90,5=>0.90,6=>0.95,
                            7=>0.95,8=>1.00,9=>1.15,10=>1.25,11=>1.35,12=>1.45];
    $seasonalityForecast = [];

    if ($period === 'daily') {
        /* Next 30 days */
        for ($i = 0; $i < 30; $i++) {
            $ts       = strtotime("+$i day");
            $monthNum = (int)date('n', $ts);
            $label    = date('M d', $ts);
            $seasonalityForecast[] = ['label' => $label, 'value' => round(($baseRevenue / 30) * ($seasonalMultipliers[$monthNum] ?? 1.0))];
        }
        $forecastPeriodLabel = 'Next 30 Days';
    } elseif ($period === 'weekly') {
        /* Next 12 weeks */
        for ($i = 0; $i < 12; $i++) {
            $ts       = strtotime("+$i week");
            $monthNum = (int)date('n', $ts);
            $label    = 'Wk of ' . date('M d', $ts);
            $seasonalityForecast[] = ['label' => $label, 'value' => round(($baseRevenue / 4) * ($seasonalMultipliers[$monthNum] ?? 1.0))];
        }
        $forecastPeriodLabel = 'Next 12 Weeks';
    } elseif ($period === 'custom' && $filterFrom && $filterTo) {
        /* Day-by-day within the custom date range */
        $ts = strtotime($filterFrom);
        $te = strtotime($filterTo);
        while ($ts <= $te) {
            $monthNum = (int)date('n', $ts);
            $label    = date('M d', $ts);
            $seasonalityForecast[] = ['label' => $label, 'value' => round(($baseRevenue / 30) * ($seasonalMultipliers[$monthNum] ?? 1.0))];
            $ts = strtotime('+1 day', $ts);
        }
        $forecastPeriodLabel = date('M d, Y', strtotime($filterFrom)) . ' – ' . date('M d, Y', strtotime($filterTo));
    } elseif ($period === 'yearly') {
        /* Next 5 years */
        for ($i = 0; $i < 5; $i++) {
            $yr    = (int)date('Y') + $i;
            $label = (string)$yr;
            $seasonalityForecast[] = ['label' => $label, 'value' => round($baseRevenue * 12 * ($i === 0 ? 1.0 : pow(1.08, $i)))];
        }
        $forecastPeriodLabel = 'Next 5 Years';
    } else {
        /* Default: monthly, next 12 months */
        for ($i = 0; $i < 12; $i++) {
            $monthNum = (int)date('n', strtotime("+$i month"));
            $label    = date('M Y', strtotime("+$i month"));
            $seasonalityForecast[] = ['label' => $label, 'value' => round($baseRevenue * ($seasonalMultipliers[$monthNum] ?? 1.0))];
        }
        $forecastPeriodLabel = 'Next 12 Months';
    }

    /* Actual listing price vs. predicted price (midpoint of the brand/tier's estimated price range) */
    $brandPricingPoints = DB::fetchAll(
        "SELECT l.price AS actual, (pl.estimated_price_min + pl.estimated_price_max)/2 AS predicted, pl.tier
         FROM LISTINGS l JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
         WHERE l.seller_id=? AND l.deleted_at IS NULL AND pl.estimated_price_min IS NOT NULL",
        [$sellerId]
    );

    /* Same data as above, aggregated per brand instead of per listing */
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

/* OPTIMIZATION tab data */
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

    /* Sub-scores that make up the completeness donut and bars below */
    $scoreBreakdown = DB::fetch(
        'SELECT COALESCE(AVG(la.photo_score),0) photos, COALESCE(AVG(la.details_score),0) details,
                COALESCE(AVG(la.condition_score),0) condition_s, COALESCE(AVG(la.shipping_score),0) shipping,
                COALESCE(AVG(la.pricing_score),0) pricing
         FROM LISTING_ANALYTICS la JOIN LISTINGS l ON la.listing_id=l.listing_id
         WHERE l.seller_id=?', [$sellerId]
    ) ?: ['photos'=>0,'details'=>0,'condition_s'=>0,'shipping'=>0,'pricing'=>0];

    /* Recommendation card counts. Same 3 thresholds as
       optimization-review.php's photos/details/pricing filters — change
       one, change both, or the card count and the filtered list won't agree. */
    $recPhotosCount = DB::fetch(
        "SELECT COUNT(*) c FROM LISTINGS l
         WHERE l.seller_id=? AND l.deleted_at IS NULL
           AND (SELECT COUNT(*) FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id) < 3",
        [$sellerId]
    )['c'] ?? 0;

    /* missing color/gender/material/made_in */
/* missing color/gender/material/made_in */
    $recDetailsCount = DB::fetch(
        "SELECT COUNT(*) c FROM LISTINGS l
         WHERE l.seller_id=? AND l.deleted_at IS NULL
           AND (
               NOT EXISTS (SELECT 1 FROM LISTING_COLORS lc WHERE lc.listing_id = l.listing_id) 
               OR l.target_gender IS NULL OR l.target_gender=''
               OR NOT EXISTS (SELECT 1 FROM LISTING_MATERIALS lm WHERE lm.listing_id = l.listing_id) 
               OR l.made_in IS NULL OR l.made_in=''
           )",
        [$sellerId]
    )['c'] ?? 0;

    /* same product_line_id, different price - not a market comparison,
       just catches typos/inconsistency within the seller's own shop */
    $recPricingCount = DB::fetch(
        "SELECT COUNT(DISTINCT l.listing_id) c
         FROM LISTINGS l
         WHERE l.seller_id=? AND l.deleted_at IS NULL
           AND l.product_line_id IN (
               SELECT product_line_id FROM LISTINGS
               WHERE seller_id=? AND deleted_at IS NULL
               GROUP BY product_line_id HAVING MIN(price) <> MAX(price)
           )",
        [$sellerId, $sellerId]
    )['c'] ?? 0;
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
  <div style="display:flex;flex-wrap:wrap;gap:16px;margin-bottom:32px">
    <?php $kpis=[
      ['icon'=>'payments',   'label'=>'Total Revenue',  'val'=>convertCurrency((float)$totalRevenue)],
      ['icon'=>'today',      'label'=>'Revenue Today', 'val'=>convertCurrency((float)$todayRevenue)],
      ['icon'=>'package_2',  'label'=>'Listings Sold',  'val'=>$listingsSold],
      ['icon'=>'receipt_long','label'=>'Total Orders',  'val'=>$totalOrders],
      ['icon'=>'star',       'label'=>'Avg Seller Rating','val'=>($avgRating?number_format($avgRating,1).'/5':'N/A')],
      ['icon'=>'block',      'label'=>'Penalty Count',  'val'=>$penaltyCount],
    ]; foreach($kpis as $k): ?>
    <div class="tb-stat-card" style="flex:0 1 200px">
      <div class="tb-stat-icon"><span class="material-symbols-outlined"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label" style="white-space:nowrap"><?= $k['label'] ?></div>
        <div class="tb-stat-value"><?= $k['val'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <?php renderPeriodFilter($period, $filterFrom, $filterTo); ?>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8" style="align-items:start">
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:20px">Revenue Trend (<?= ucfirst($period) ?>)</h3>
      <?php if (!empty($revByMonth)): ?>
      <canvas id="revChart" height="180"></canvas>
      <?php else: ?>
      <div style="height:180px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary)">No revenue data yet</div>
      <?php endif; ?>
    </div>
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Revenue by Category</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Share of your total revenue contributed by each category in the selected period.</p>
      <?php if (!empty($revByCat)):
        $catTotal = array_sum(array_column($revByCat, 'total'));
      ?>
      <div style="display:flex;align-items:center;gap:20px;flex-wrap:wrap">
        <div style="position:relative;width:180px;height:180px;flex-shrink:0">
          <canvas id="catDonut"></canvas>
          <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;pointer-events:none">
            <span style="font-size:11px;color:var(--clr-tertiary)">Total Revenue</span>
            <span style="font-size:15px;font-weight:800;color:var(--clr-text)"><?= convertCurrency((float)$catTotal) ?></span>
          </div>
        </div>
        <div style="flex:1;min-width:160px;max-width:280px;display:flex;flex-direction:column;gap:8px">
          <?php $catColors=['#ff6b6b','#66bb6a','#ffc107','#4a7fc9','#8e6bff','#26c6da','#ef5350','#78909c'];
          foreach ($revByCat as $i => $rc): $pct = $catTotal > 0 ? ($rc['total'] / $catTotal) * 100 : 0; ?>
          <div style="display:flex;align-items:center;gap:8px;font-size:var(--fs-label-sm)">
            <span style="width:9px;height:9px;border-radius:50%;background:<?= $catColors[$i % count($catColors)] ?>;flex-shrink:0"></span>
            <span style="flex:1"><?= htmlspecialchars($rc['name']) ?></span>
            <span style="color:var(--clr-tertiary);font-weight:700;width:44px;text-align:right"><?= number_format($pct,1) ?>%</span>
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
      ['icon'=>'payments',    'label'=>'Total Revenue',  'val'=>convertCurrency((float)$totalRevenue), 'tip'=>'Total income from all completed sales in the selected period.'],
      ['icon'=>'package_2',   'label'=>'Listings Sold',  'val'=>$listingsSold, 'tip'=>'Number of listings successfully sold and paid for in the selected period.'],
      ['icon'=>'star',        'label'=>'Seller Rating',  'val'=>($avgRating?number_format($avgRating,1).'/5':'N/A'), 'tip'=>'Your average buyer rating across all completed orders.'],
      ['icon'=>'block',       'label'=>'Penalty Count',  'val'=>$penaltyCount, 'tip'=>'Total penalties issued to your account for policy violations (e.g. late shipping).'],
    ]; foreach($kpis as $k): ?>
    <div class="tb-stat-card" title="<?= htmlspecialchars($k['tip']) ?>">
      <div class="tb-stat-icon"><span class="material-symbols-outlined"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value"><?= $k['val'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <?php renderPeriodFilter($period, $filterFrom, $filterTo); ?>

  <div class="tb-card mb-6">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Seller Performance Overview</h3></div>
    <div class="tb-card-body">
      <canvas id="perfChart" height="140"></canvas>
      <p style="text-align:center;font-size:11px;color:var(--clr-tertiary);margin-top:8px">Revenue, listings sold, rating, and penalties, each rescaled to a common 0–100 score so they can be compared side by side.</p>
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
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Authenticity Verification History</h3></div>
    <div class="tb-card-body" style="overflow-x:auto">
      <?php if (empty($authDetails)): ?>
      <div style="color:var(--clr-tertiary)">No branded items submitted for authentication yet.</div>
      <?php else: ?>
      <table class="tb-table">
        <thead><tr><th>Brand</th><th>Item</th><th>Year Manufactured</th><th>Status</th><th>Date Verified</th></tr></thead>
        <tbody>
        <?php foreach ($authDetails as $d): ?>
        <tr class="tb-row-clickable" onclick="location.href='edit-listing.php?id=<?= $d['listing_id'] ?>&return=<?= urlencode('analytics.php?tab=performance') ?>'" style="cursor:pointer">
          <td><?= htmlspecialchars($d['brand']) ?></td>
          <td><?= htmlspecialchars($d['item']) ?></td>
          <td><?= $d['manufacture_year'] ?: '-' ?></td>
          <td><span class="tb-badge <?= $d['status']==='Verified'?'tb-badge-green':($d['status']==='Rejected'?'tb-badge-red':'tb-badge-coral') ?>"><?= $d['status'] ?></span></td>
          <td><?= $d['date_verified'] ? date('M d, Y', strtotime($d['date_verified'])) : '-' ?></td>
        </tr>
        <?php endforeach; ?>
        </tbody>
      </table>
      <style>.tb-row-clickable:hover{background:var(--clr-surface-low)}</style>
      <?php endif; ?>
    </div>
  </div>

  <?php elseif ($tab === 'sales-drivers'): ?>
  <!-- =================== SALES DRIVERS (Diagnostic Report) =================== -->
  <?php renderPeriodFilter($period, $filterFrom, $filterTo); ?>
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'group',        'label'=>'Total Customers',       'val'=>$totalCustomers, 'tip'=>'Number of distinct buyers who have ordered from you, all-time.'],
      ['icon'=>'receipt_long', 'label'=>'Total Orders',          'val'=>$totalOrders, 'tip'=>'Total orders placed with your shop, all-time.'],
      ['icon'=>'repeat',       'label'=>'Repeat Customers',      'val'=>$repeatCustomers, 'tip'=>'Buyers who have ordered from you more than once — a sign of buyer trust and satisfaction.'],
      ['icon'=>'payments',     'label'=>'Avg Spend / Customer',  'val'=>convertCurrency((float)$avgSpendPerCustomer), 'tip'=>'Total revenue divided by number of distinct customers.'],
    ]; foreach($kpis as $k): ?>
    <div class="tb-stat-card" title="<?= htmlspecialchars($k['tip']) ?>">
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
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Top Customer Revenue Contribution</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Your highest-spending buyers in the selected period — the customers worth prioritizing for repeat business.</p>
      <?php if (empty($topCustomers)): ?>
      <div style="color:var(--clr-tertiary)">No customer data yet</div>
      <?php else: ?>
      <div style="position:relative;height:<?= max(140, count($topCustomers) * 40) ?>px">
        <canvas id="topCustomersChart"></canvas>
      </div>
      <?php endif; ?>
    </div>
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Sales Insights &amp; Recommendations</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:12px">Automated findings from your listing and conversion data — which categories are underperforming, and why.</p>
      <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:14px">
        Avg. Instagram followers per listing: <strong><?= number_format($avgFollowers) ?></strong> &bull;
        Avg. view-to-bid conversion: <strong><?= number_format($avgConversion,1) ?>%</strong>
      </p>

      <?php if (count($categoryDiagnostics) >= 2): ?>
      <p class="tb-section-label" style="margin-bottom:6px">Conversion by Category (Drill-Down)</p>
      <div style="display:flex;flex-direction:column;gap:4px;margin-bottom:14px">
        <?php foreach ($categoryDiagnostics as $cd): ?>
        <div style="display:flex;justify-content:space-between;font-size:var(--fs-label-sm)">
          <span style="color:var(--clr-text)"><?= htmlspecialchars($cd['category']) ?> <span style="color:var(--clr-tertiary)">(<?= $cd['listing_count'] ?> listings)</span></span>
          <span style="font-weight:700;color:<?= $cd['conversion'] < $avgConversion ? 'var(--clr-error)' : 'var(--clr-success)' ?>"><?= number_format($cd['conversion'],1) ?>%</span>
        </div>
        <?php endforeach; ?>
      </div>
      <?php endif; ?>

      <?php if ($diagnosticFinding): ?>
      <div style="background:var(--clr-error-bg);border-left:3px solid var(--clr-error);border-radius:var(--radius-sm);padding:10px 12px">
        <p style="font-size:var(--fs-label-md);color:var(--clr-error);font-weight:700;margin-bottom:4px">Root Cause Identified</p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-text)">
          Your <strong><?= htmlspecialchars($diagnosticFinding['worst_category']) ?></strong> listings convert at
          <strong><?= number_format($diagnosticFinding['worst_conversion'],1) ?>%</strong>, well below your
          <strong><?= htmlspecialchars($diagnosticFinding['best_category']) ?></strong> listings at
          <strong><?= number_format($diagnosticFinding['best_conversion'],1) ?>%</strong>.
          The biggest measurable difference between them is <strong><?= htmlspecialchars($diagnosticFinding['likely_cause']) ?></strong>
          (a <?= $diagnosticFinding['gap'] ?>-point gap), which is the most likely driver of the lower conversion in
          <?= htmlspecialchars($diagnosticFinding['worst_category']) ?>, not follower count or luck.
        </p>
      </div>
      <?php elseif (count($categoryDiagnostics) >= 2): ?>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Conversion is fairly consistent across your categories right now, no single category stands out as a clear outlier worth investigating yet.</p>
      <?php else: ?>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Not enough listings per category yet for a reliable category-by-category comparison (need at least 2 per category). Check back once you have more listings spread across categories.</p>
      <?php endif; ?>
    </div>
  </div>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-6" style="margin-top:24px">
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Sales Trend Analysis</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">How orders, distinct customers, and conversion rate (orders per customer) have moved over the selected period.</p>
      <?php if (empty($salesBias)): ?>
      <div style="color:var(--clr-tertiary)">Not enough order data yet for this period.</div>
      <?php else: ?>
      <canvas id="salesBiasChart" height="180"></canvas>
      <?php endif; ?>
    </div>
    <div class="tb-card tb-card-body">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Exchange Rate Monitor</h3>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">PHP-to-USD and PHP-to-KRW rates used to price listings for international buyers, over the selected period.</p>
      <?php if (empty($currencyLabels)): ?>
      <div style="color:var(--clr-tertiary)">No recorded exchange rate history for this period yet.</div>
      <?php else: ?>
      <canvas id="currencyChart" height="180"></canvas>
      <?php endif; ?>
    </div>
  </div>

  <?php elseif ($tab === 'forecast'): ?>
  <!-- =================== FORECAST (Predictive Report) =================== -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'trending_up', 'label'=>'Projected Revenue (30d)', 'val'=>convertCurrency((float)$projectedRevenue), 'tip'=>'Estimated revenue for the next 30 days, based on your trailing 3-month average plus a seasonal adjustment.'],
      ['icon'=>'shopping_bag','label'=>'Projected Orders (30d)',  'val'=>$projectedOrders, 'tip'=>'Estimated order volume for the next 30 days, based on the same trailing-average method.'],
      ['icon'=>'sell',        'label'=>'Avg Predicted Price',     'val'=>convertCurrency((float)$avgPredictedPrice), 'tip'=>'Average of the predicted market price (brand/tier price band midpoint) across your listings.'],
      ['icon'=>'event',       'label'=>'Best Performing Month',   'val'=>$bestMonth, 'tip'=>'The calendar month with your highest revenue on record, all-time.'],
    ]; foreach($kpis as $k): ?>
    <div class="tb-stat-card" title="<?= htmlspecialchars($k['tip']) ?>">
      <div class="tb-stat-icon"><span class="material-symbols-outlined"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value"><?= $k['val'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php renderPeriodFilter($period, $filterFrom, $filterTo); ?>

  <div class="tb-card mb-2">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Projected Seasonal Sales Trend, <?= htmlspecialchars($forecastPeriodLabel) ?></h3></div>
    <div class="tb-card-body">
      <canvas id="seasonChart" height="110"></canvas>
      <p style="text-align:center;font-size:11px;color:var(--clr-tertiary);margin-top:8px">Projection based on your trailing 3-month sales average, adjusted for typical "BER month" (Sep–Dec) demand.</p>
    </div>
  </div>

  <div class="tb-card mb-2">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Brand Price Distribution</h3></div>
    <div class="tb-card-body">
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Each dot is one listing: its actual price vs. the predicted market price for its brand/tier. Above the diagonal means priced higher than the market band; below means priced lower. Both axes use a log scale since prices span ₱200 to ₱70,000+.</p>
      <?php if (empty($brandPricingPoints)): ?>
      <div style="color:var(--clr-tertiary)">Not enough brand data yet.</div>
      <?php else: ?>
      <canvas id="brandScatter" height="90"></canvas>
      <?php endif; ?>
    </div>
  </div>

  <div class="tb-card">
    <div class="tb-card-header"><h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Predicted Brand Market Value</h3></div>
    <div class="tb-card-body" style="overflow-x:auto">
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:12px">Your average listing price per brand vs. that brand's predicted market price — positive % means you're pricing above the predicted market value.</p>
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

  <?php elseif ($tab === 'optimization'): ?>
  <!-- =================== OPTIMIZATION (Prescriptive Report) =================== -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
    <?php $kpis=[
      ['icon'=>'checklist',  'label'=>'Total Listings Analyzed', 'val'=>$listingsAnalyzed, 'tip'=>'Number of your listings with tracked analytics data.'],
      ['icon'=>'task_alt',   'label'=>'Avg Completeness Score',  'val'=>number_format($avgCompleteness,0).'/100', 'tip'=>'Average score across photos, item details, and pricing consistency, out of 100.'],
      ['icon'=>'insights',   'label'=>'Avg View-to-Bid Rate',    'val'=>number_format($avgViewToBid,1).'%', 'tip'=>'Average share of listing views that resulted in a bid.'],
      ['icon'=>'warning',    'label'=>'Listings Needing Improvement','val'=>$needsImprovement, 'tip'=>'Listings scoring below 70/100 on completeness — the ones most likely holding back views and bids.'],
    ]; foreach($kpis as $k): ?>
    <div class="tb-stat-card" title="<?= htmlspecialchars($k['tip']) ?>">
      <div class="tb-stat-icon"><span class="material-symbols-outlined"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value"><?= $k['val'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <div class="tb-card tb-card-body mb-6">
    <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Listing Completeness Score</h3>
    <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Average score across three factors that affect how buyer-ready your listings are: photo count, item detail completeness, and pricing consistency.</p>
    <?php
      /* Score tiers, shared by the donut color and the legend below it. */
      $tier = $avgCompleteness >= 80 ? ['label'=>'Excellent','color'=>'var(--clr-success)','hex'=>'#1d6840']
            : ($avgCompleteness >= 50 ? ['label'=>'Good','color'=>'var(--clr-yellow)','hex'=>'#ffc107']
            : ['label'=>'Needs Improvement','color'=>'var(--clr-error)','hex'=>'#c0392b']);
    ?>
    <div style="display:flex;align-items:center;gap:24px;flex-wrap:wrap">
      <div style="position:relative;width:150px;height:150px;flex-shrink:0">
        <canvas id="completenessGauge"></canvas>
        <div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;pointer-events:none">
          <span style="font-size:26px;font-weight:800;color:var(--clr-text)"><?= number_format($avgCompleteness,0) ?></span>
          <span style="font-size:11px;color:var(--clr-tertiary)">/ 100</span>
          <span style="font-size:11px;font-weight:700;color:<?= $tier['color'] ?>;margin-top:2px"><?= $tier['label'] ?></span>
        </div>
      </div>
      <div style="flex:1;min-width:180px;display:flex;flex-direction:column;gap:10px">
        <?php $subScores=[
          ['icon'=>'image',      'label'=>'Photo Count',  'val'=>$scoreBreakdown['photos']],
          ['icon'=>'description','label'=>'Item Details', 'val'=>$scoreBreakdown['details']],
          ['icon'=>'payments',   'label'=>'Pricing',      'val'=>$scoreBreakdown['pricing']],
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

    <!-- Legend: what the tier colors mean, so a seller doesn't have to
         guess what "Good" or the donut color represents. -->
    <div style="display:flex;gap:18px;flex-wrap:wrap;margin-top:16px;padding-top:12px;border-top:1px solid var(--clr-outline)">
      <div style="display:flex;align-items:center;gap:6px;font-size:11px;color:var(--clr-tertiary)">
        <span style="width:10px;height:10px;border-radius:50%;background:var(--clr-success);display:inline-block"></span>80–100 &bull; Excellent
      </div>
      <div style="display:flex;align-items:center;gap:6px;font-size:11px;color:var(--clr-tertiary)">
        <span style="width:10px;height:10px;border-radius:50%;background:var(--clr-yellow);display:inline-block"></span>50–79 &bull; Good
      </div>
      <div style="display:flex;align-items:center;gap:6px;font-size:11px;color:var(--clr-tertiary)">
        <span style="width:10px;height:10px;border-radius:50%;background:var(--clr-error);display:inline-block"></span>Below 50 &bull; Needs Improvement
      </div>
    </div>

    <p style="font-size:11px;color:var(--clr-tertiary);margin-top:14px">A complete listing increases the chance of getting higher bids and more sales.</p>
  </div>

  <div class="tb-card tb-card-body">
    <h3 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:4px">Listing Optimization Recommendations</h3>
    <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:16px">Actionable suggestions to improve your listings and increase the likelihood of a successful sale.</p>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">

      <!-- 1. Add More Photos -->
      <div style="background:#e3f0ff;border-radius:var(--radius-lg);padding:16px">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
          <span class="material-symbols-outlined icon-md" style="color:var(--clr-text)">image</span>
          <?php if ($recPhotosCount > 0): ?>
          <span class="tb-badge tb-badge-coral" style="font-size:12px"><?= $recPhotosCount ?> listing<?= $recPhotosCount!==1?'s':'' ?></span>
          <?php else: ?>
          <span class="tb-badge tb-badge-green" style="font-size:12px">All good</span>
          <?php endif; ?>
        </div>
        <p style="font-weight:700;font-size:var(--fs-label-md)">Photo Quality Improvement</p>
        <p style="font-size:11px;color:var(--clr-tertiary);margin-top:4px;min-height:44px">
          <?php if ($recPhotosCount === 0): ?>
          Every listing already has 3 or more photos. Nice, that's one less thing buyers have to guess about.
          <?php elseif ($recPhotosCount === 1): ?>
          1 listing has fewer than 3 photos. Listings with 3+ high-quality photos get more views and higher bids.
          <?php else: ?>
          <?= $recPhotosCount ?> listings have fewer than 3 photos each. Listings with 3+ high-quality photos get more views and higher bids.
          <?php endif; ?>
        </p>
        <a href="optimization-review.php?issue=photos" class="btn btn-outline btn-sm btn-full" style="background:#fff;margin-top:8px">View Listings</a>
      </div>

      <!-- 2. Complete Item Details -->
      <div style="background:#e3f7e8;border-radius:var(--radius-lg);padding:16px">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
          <span class="material-symbols-outlined icon-md" style="color:var(--clr-text)">description</span>
          <?php if ($recDetailsCount > 0): ?>
          <span class="tb-badge tb-badge-coral" style="font-size:12px"><?= $recDetailsCount ?> listing<?= $recDetailsCount!==1?'s':'' ?></span>
          <?php else: ?>
          <span class="tb-badge tb-badge-green" style="font-size:12px">All good</span>
          <?php endif; ?>
        </div>
        <p style="font-weight:700;font-size:var(--fs-label-md)">Item Information Completion</p>
        <p style="font-size:11px;color:var(--clr-tertiary);margin-top:4px;min-height:44px">
          <?php if ($recDetailsCount === 0): ?>
          Color, material, gender, and made-in are filled in across every listing. That's the kind of detail that builds buyer trust.
          <?php elseif ($recDetailsCount === 1): ?>
          1 listing is missing color, gender, material, or made-in. These fields reduce buyer confidence and search visibility when left blank.
          <?php else: ?>
          <?= $recDetailsCount ?> listings are missing color, gender, material, or made-in. These fields reduce buyer confidence and search visibility when left blank.
          <?php endif; ?>
        </p>
        <a href="optimization-review.php?issue=details" class="btn btn-outline btn-sm btn-full" style="background:#fff;margin-top:8px">View Incomplete Listings</a>
      </div>

      <!-- 3. Pricing Info -->
      <div style="background:#fff6de;border-radius:var(--radius-lg);padding:16px">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
          <span class="material-symbols-outlined icon-md" style="color:var(--clr-text)">payments</span>
          <?php if ($recPricingCount > 0): ?>
          <span class="tb-badge tb-badge-coral" style="font-size:12px"><?= $recPricingCount ?> listing<?= $recPricingCount!==1?'s':'' ?></span>
          <?php else: ?>
          <span class="tb-badge tb-badge-green" style="font-size:12px">All good</span>
          <?php endif; ?>
        </div>
        <p style="font-weight:700;font-size:var(--fs-label-md)">Price Consistency Check</p>
        <p style="font-size:11px;color:var(--clr-tertiary);margin-top:4px;min-height:44px">
          <?php if ($recPricingCount === 0): ?>
          No product line in your shop has mismatched prices between listings — nothing here is likely to confuse a buyer comparing your items.
          <?php else: ?>
          <?= $recPricingCount ?> listing<?= $recPricingCount!==1?'s':'' ?> share<?= $recPricingCount===1?'s':'' ?> a product line with a different price than another listing of the same item in your shop. Align them so similar items don't look mispriced side by side.
          <?php endif; ?>
        </p>
        <a href="optimization-review.php?issue=pricing" class="btn btn-outline btn-sm btn-full" style="background:#fff;margin-top:8px">View Listings</a>
      </div>

    </div>
    <?php
      $totalRecIssues = $recPhotosCount + $recDetailsCount + $recPricingCount;
      if ($totalRecIssues === 0): ?>
    <p style="font-size:11px;color:var(--clr-success);font-weight:600;margin-top:16px">No open recommendations right now, your listings are in good shape across photos, details, and pricing.</p>
    <?php else: ?>
    <p style="font-size:11px;color:var(--clr-tertiary);margin-top:16px"><?= $totalRecIssues ?> listing issue<?= $totalRecIssues!==1?'s':'' ?> flagged above. Fixing these tends to have an outsized effect on views and bids relative to the effort involved.</p>
    <?php endif; ?>
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
    options:{responsive:true,maintainAspectRatio:false,cutout:'68%',plugins:{legend:{display:false}}}
  });
  <?php endif; ?>

<?php elseif ($tab === 'performance'): ?>
  new Chart(document.getElementById('perfChart'), {
    type:'bar',
    data:{
      labels:['Revenue (Period)','Listings Sold (Period)','Seller Rating','Penalty Count'],
      datasets:[{
        data:[
          Math.min(100, <?= (float)$perfRevenue ?> / 2000),
          Math.min(100, <?= (int)$perfListingsSold ?> * 2),
          <?= (float)$avgRating ?> * 20,
          Math.max(0, 100 - <?= (int)$penaltyCount ?> * 25)
        ],
        backgroundColor:'rgba(255,107,107,0.7)', borderColor:'#ff6b6b', borderWidth:2, borderRadius:6,
      }]
    },
    options:{indexAxis:'y',responsive:true,plugins:{legend:{display:false}},scales:{x:{beginAtZero:true,max:100,title:{display:true,text:'Score (0-100, higher is better)'}}}}
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
    options:{indexAxis:'y',responsive:true,maintainAspectRatio:false,plugins:{legend:{display:false}},scales:{x:{beginAtZero:true,title:{display:true,text:'Total Spending (₱)'},ticks:{callback:v=>'₱'+v.toLocaleString()}}}}
  });
  <?php endif; ?>
  <?php if (!empty($salesBias)): ?>
  new Chart(document.getElementById('salesBiasChart'), {
    type:'line',
    data:{
      labels:<?= json_encode(array_column($salesBias,'label')) ?>,
      datasets:[
        { label:'Orders', data:<?= json_encode(array_map(fn($r)=>(int)$r['orders'],$salesBias)) ?>, borderColor:'#ff6b6b', backgroundColor:'rgba(255,107,107,0.1)', tension:0.3, pointRadius:3, yAxisID:'yCount' },
        { label:'Customers', data:<?= json_encode(array_map(fn($r)=>(int)$r['customers'],$salesBias)) ?>, borderColor:'#4a7fc9', backgroundColor:'rgba(74,127,201,0.1)', tension:0.3, pointRadius:3, yAxisID:'yCount' },
        { label:'Conversion Rate (orders/customer)', data:<?= json_encode(array_map(fn($r)=>(float)$r['conversion_rate'],$salesBias)) ?>, borderColor:'#66bb6a', backgroundColor:'rgba(102,187,106,0.1)', tension:0.3, pointRadius:3, yAxisID:'yRate' },
      ]
    },
    options:{
      responsive:true,
      plugins:{legend:{position:'top'}},
      scales:{
        x:{title:{display:true,text:<?= json_encode(ucfirst($period) . ' Period') ?>}},
        /* Orders and Customers are both headcounts and share this axis;
           Conversion Rate is a ratio (orders per customer, e.g. 1.5), a
           completely different unit that would otherwise flatten to a
           near-flat line at the bottom of a shared 0-many axis. */
        yCount:{type:'linear',position:'left',beginAtZero:true,title:{display:true,text:'Orders / Customers (count)'}},
        yRate:{type:'linear',position:'right',beginAtZero:true,grid:{drawOnChartArea:false},title:{display:true,text:'Conversion Rate'}},
      }
    }
  });
  <?php endif; ?>
  <?php if (!empty($currencyLabels)): ?>
  new Chart(document.getElementById('currencyChart'), {
    type:'line',
    data:{
      labels:<?= json_encode($currencyLabels) ?>,
      datasets:[
        { label:'PHP → USD', data:<?= json_encode(array_map(fn($l)=>$currencyByCcy['USD'][$l] ?? null, $currencyLabels)) ?>, borderColor:'#4a7fc9', backgroundColor:'rgba(74,127,201,0.1)', tension:0.3, pointRadius:3, spanGaps:true, yAxisID:'yUsd' },
        { label:'PHP → KRW', data:<?= json_encode(array_map(fn($l)=>$currencyByCcy['KRW'][$l] ?? null, $currencyLabels)) ?>, borderColor:'#8e6bff', backgroundColor:'rgba(142,107,255,0.1)', tension:0.3, pointRadius:3, spanGaps:true, yAxisID:'yKrw' },
      ]
    },
    options:{
      responsive:true,
      plugins:{legend:{position:'top'}},
      scales:{
        /* USD (~0.0175) and KRW (~23.5) rates are two orders of magnitude
           apart — sharing one axis would flatten USD to an invisible
           near-zero line, so each currency gets its own axis. */
        x:{title:{display:true,text:'Period'}},
        yUsd:{type:'linear',position:'left',title:{display:true,text:'PHP → USD Rate'}},
        yKrw:{type:'linear',position:'right',title:{display:true,text:'PHP → KRW Rate'},grid:{drawOnChartArea:false}},
      }
    }
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
    options:{responsive:true,plugins:{legend:{display:false}},scales:{x:{title:{display:true,text:<?= json_encode($forecastPeriodLabel) ?>}},y:{beginAtZero:true,title:{display:true,text:'Projected Revenue (₱)'},ticks:{callback:v=>'₱'+v.toLocaleString()}}}}
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
    options:{
      responsive:true,
      plugins:{
        legend:{position:'top'},
        tooltip:{
          callbacks:{
            label:function(ctx){
              return ctx.dataset.label + ': Actual \u20b1' + ctx.parsed.x.toLocaleString() + ', Predicted \u20b1' + ctx.parsed.y.toLocaleString();
            }
          }
        }
      },
      scales:{
        /* Log scale, not linear: prices range from under P200 to over P70,000.
           On a linear axis every cheap listing would collapse into one
           unreadable cluster near zero. */
        x:{type:'logarithmic',title:{display:true,text:'Actual Price (\u20b1), log scale'},ticks:{callback:v=>{ const s=v.toString(); return (s[0]==='1'||s==='0')?'\u20b1'+v.toLocaleString():''; }}},
        y:{type:'logarithmic',title:{display:true,text:'Predicted Price (\u20b1), log scale'},ticks:{callback:v=>{ const s=v.toString(); return (s[0]==='1'||s==='0')?'\u20b1'+v.toLocaleString():''; }}}
      }
    }
  });
  <?php endif; ?>
<?php elseif ($tab === 'optimization'): ?>
  new Chart(document.getElementById('completenessGauge'), {
    type:'doughnut',
    data:{
      datasets:[{
        data:[<?= (float)$avgCompleteness ?>, <?= max(0, 100 - (float)$avgCompleteness) ?>],
        backgroundColor:['<?= $tier['hex'] ?>', '#f0f0f0'],
        borderWidth:0,
      }]
    },
    options:{responsive:true,maintainAspectRatio:false,cutout:'75%',plugins:{legend:{display:false},tooltip:{enabled:false}}}
  });
<?php endif; ?>
</script>
<?php endif; ?>

</body></html>