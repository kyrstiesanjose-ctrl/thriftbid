<?php
/**
 * ThriftBid - Optimization Review Hub
 * File: pages/seller/optimization-review.php
 * 
 * Purpose: Prescriptive Analytics & Quality Diagnostic Console
 * Aligns with Section 5.2 (Automated Insights Engine) and Section 4 (Business Rules)
 *
 * Diagnostic Capabilities:
 * 1. Photo Count Check: Identifies listings with < 3 photos to improve view-to-bid conversion
 * 2. Item Detail Completeness: Flags missing attributes (color, target gender, material, made_in).
 * 3. Pricing Consistency Check: Flags price discrepancies across listings in the same product line
 *
 * Persistence Architecture:
 * - Maintains filtered GET parameters across edits using $returnUrl
 * - Enforces seller and admin role authentication
 */

require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('../login.php');
requireRole(['seller', 'admin'], '../login.php');

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id'];

// Sanitize and validate filter inputs
$issue        = in_array($_GET['issue'] ?? '', ['photos', 'details', 'pricing'], true) ? $_GET['issue'] : 'photos';
$photoNeeded  = array_values(array_intersect((array)($_GET['needed']  ?? []), ['1', '2', '3']));
$missingField = array_values(array_intersect((array)($_GET['missing'] ?? []), ['color', 'gender', 'material', 'made_in']));

// Return URL parameter so edit-listing.php redirects directly back to this exact filtered view
$returnUrl = 'optimization-review.php?' . http_build_query($_GET);

// Base Query: Fetch non-deleted, active listings for current seller
$baseSql = "SELECT l.listing_id, l.title, l.price, l.target_gender, l.made_in,
                   c.name AS cat_name,
                   (SELECT COUNT(*) FROM LISTING_IMAGES li WHERE li.listing_id = l.listing_id) AS photo_count,
                   (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id = l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image,
                   a.auction_id, a.status AS auction_status,
                   (SELECT GROUP_CONCAT(c2.color_name) FROM LISTING_COLORS lc JOIN COLORS c2 ON lc.color_id = c2.color_id WHERE lc.listing_id = l.listing_id) AS color,
                   (SELECT GROUP_CONCAT(m.material_name) FROM LISTING_MATERIALS lm JOIN MATERIALS m ON lm.material_id = m.material_id WHERE lm.listing_id = l.listing_id) AS material
            FROM LISTINGS l
            JOIN CATEGORIES c ON l.category_id = c.category_id
            LEFT JOIN AUCTIONS a ON a.listing_id = l.listing_id AND a.status = 'Active'
            WHERE l.seller_id = ? AND l.deleted_at IS NULL AND l.is_active = 1";
$params = [$sellerId];

// Prescriptive Filter: Photos (< 3 photos threshold)
if ($issue === 'photos') {
    if (!empty($photoNeeded)) {
        $placeholders = implode(',', array_fill(0, count($photoNeeded), '?'));
        $baseSql .= " AND (3 - (SELECT COUNT(*) FROM LISTING_IMAGES li WHERE li.listing_id = l.listing_id)) IN ($placeholders)";
        foreach ($photoNeeded as $n) { $params[] = (int)$n; }
    } else {
        $baseSql .= " AND (SELECT COUNT(*) FROM LISTING_IMAGES li WHERE li.listing_id = l.listing_id) < 3";
    }
// Prescriptive Filter: Missing Attributes
} elseif ($issue === 'details') {
    $fieldMap = [
        'color'    => '(NOT EXISTS (SELECT 1 FROM LISTING_COLORS lc WHERE lc.listing_id = l.listing_id))', 
        'gender'   => "(l.target_gender IS NULL OR l.target_gender = '')", 
        'material' => '(NOT EXISTS (SELECT 1 FROM LISTING_MATERIALS lm WHERE lm.listing_id = l.listing_id))', 
        'made_in'  => "(l.made_in IS NULL OR l.made_in = '')"
    ];
    if (!empty($missingField)) {
        $conds = array_map(fn($f) => $fieldMap[$f], $missingField);
        $baseSql .= ' AND (' . implode(' OR ', $conds) . ')';
    } else {
        $baseSql .= " AND (" . implode(' OR ', $fieldMap) . ")";
    }
// Prescriptive Filter: Pricing Variance across Product Line
} else { 
    $baseSql .= " AND l.product_line_id IN (
                      SELECT product_line_id FROM LISTINGS
                      WHERE seller_id = ? AND deleted_at IS NULL
                      GROUP BY product_line_id HAVING MIN(price) <> MAX(price)
                  )";
    $params[] = $sellerId;
}

$baseSql .= " ORDER BY l.created_at DESC";
$listings = DB::fetchAll($baseSql, $params);

// Helper function: Summarize photo deficit status
function photosReason(array $l): string {
    $needed = max(0, 3 - (int)$l['photo_count']);
    return $needed > 0 ? "Needs $needed more photo" . ($needed !== 1 ? 's' : '') . " (has {$l['photo_count']})" : 'Photos OK';
}

// Helper function: Summarize missing listing attributes
function detailsReason(array $l): string {
    $missing = [];
    if (!$l['color'])         $missing[] = 'Color';
    if (!$l['target_gender']) $missing[] = 'Gender';
    if (!$l['material'])      $missing[] = 'Material';
    if (!$l['made_in'])       $missing[] = 'Made In';
    return $missing ? 'Missing: ' . implode(', ', $missing) : 'Details complete';
}

$issueLabels = [
    'photos'  => ['title' => 'Photo Count Check', 'icon' => 'image', 'desc' => 'Listings with fewer than 3 photos. Add more to improve visibility and bids.'],
    'details' => ['title' => 'Item Detail Completeness', 'icon' => 'description', 'desc' => 'Listings missing color, gender, material, or made-in. Complete listings look more trustworthy.'],
    'pricing' => ['title' => 'Price Consistency Check', 'icon' => 'payments', 'desc' => 'Listings sharing a product line with a different price than another listing of the same item in your shop.'],
];
$current = $issueLabels[$issue];

renderHead($current['title'] . ' — Optimization Review');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('analytics', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('analytics'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <a href="analytics.php?tab=optimization" style="display:inline-flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:16px;text-decoration:none">
    <span class="material-symbols-outlined icon-sm">arrow_back</span>Back to Analytics
  </a>

  <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:700;color:var(--clr-text);display:flex;align-items:center;gap:10px">
    <span class="material-symbols-outlined" style="color:var(--clr-coral)"><?= $current['icon'] ?></span><?= $current['title'] ?>
  </h1>
  <p style="color:var(--clr-tertiary);margin-top:4px;margin-bottom:20px"><?= $current['desc'] ?></p>

  <!-- Diagnostic Category Switcher -->
  <div class="tb-tabs" style="margin-bottom:16px">
    <?php foreach (['photos'=>'Photos','details'=>'Item Details','pricing'=>'Pricing'] as $key => $label): ?>
    <a href="?issue=<?= $key ?>" class="tb-tab-link <?= $issue===$key?'active':'' ?>"><?= $label ?></a>
    <?php endforeach; ?>
  </div>

  <!-- Persistent Sub-Filter Toolbar -->
  <?php if ($issue === 'photos' || $issue === 'details'): ?>
  <form method="GET" style="display:inline-flex;align-items:center;gap:14px;flex-wrap:wrap;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:12px 16px;margin-bottom:20px;width:fit-content;max-width:100%">
    <input type="hidden" name="issue" value="<?= $issue ?>">
    <span style="font-size:var(--fs-label-sm);font-weight:700;color:var(--clr-tertiary);white-space:nowrap">Filter:</span>
    <?php if ($issue === 'photos'): ?>
      <?php foreach (['1'=>'Needs 1 more','2'=>'Needs 2 more','3'=>'Needs 3 more (none yet)'] as $val => $label): ?>
      <label style="display:flex;align-items:center;gap:6px;font-size:var(--fs-label-sm);color:var(--clr-text);white-space:nowrap;cursor:pointer">
        <input type="checkbox" name="needed[]" value="<?= $val ?>" <?= in_array($val, $photoNeeded, true)?'checked':'' ?> onchange="this.form.submit()" style="accent-color:var(--clr-coral)">
        <?= $label ?>
      </label>
      <?php endforeach; ?>
    <?php else: ?>
      <?php foreach (['color'=>'Color','gender'=>'Gender','material'=>'Material','made_in'=>'Made In'] as $val => $label): ?>
      <label style="display:flex;align-items:center;gap:6px;font-size:var(--fs-label-sm);color:var(--clr-text);white-space:nowrap;cursor:pointer">
        <input type="checkbox" name="missing[]" value="<?= $val ?>" <?= in_array($val, $missingField, true)?'checked':'' ?> onchange="this.form.submit()" style="accent-color:var(--clr-coral)">
        <?= $label ?>
      </label>
      <?php endforeach; ?>
    <?php endif; ?>
    <?php if (!empty($photoNeeded) || !empty($missingField)): ?><a href="?issue=<?= $issue ?>" style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);white-space:nowrap">Clear</a><?php endif; ?>
  </form>
  <?php endif; ?>

  <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:12px"><?= count($listings) ?> listing<?= count($listings)!==1?'s':'' ?> found</p>

  <?php if (empty($listings)): ?>
  <div style="text-align:center;padding:56px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl" style="color:var(--clr-success)">check_circle</span>
    <p style="margin-top:10px;font-weight:600">Nothing here, you're all caught up on this issue.</p>
  </div>
  <?php else: ?>
  <div style="display:flex;flex-direction:column;gap:10px">
    <?php foreach ($listings as $l):
      $reason = $issue === 'photos' ? photosReason($l) : ($issue === 'details' ? detailsReason($l) : null);
      if ($issue === 'pricing') {
          $reason = 'Priced at ' . convertCurrency((float)$l['price']) . ': other listings of this item in your shop are priced differently';
      }
    ?>
    <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:14px 18px;display:flex;align-items:center;gap:14px;flex-wrap:wrap">
      <div style="width:56px;height:56px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
        <?php if ($l['cover_image']): ?><img src="<?= htmlspecialchars($l['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
      </div>
      <div style="flex:1;min-width:220px">
        <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
          <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($l['title']) ?></p>
          <span class="tb-badge <?= $l['auction_id']?'tb-badge-blue':'tb-badge-gray' ?>"><?= $l['auction_id']?'Auction':'Fixed Price' ?></span>
        </div>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= convertCurrency((float)$l['price']) ?></p>
      </div>
      <div style="max-width:280px;text-align:right">
        <p style="font-size:var(--fs-label-sm);font-weight:600;color:var(--clr-warn, #8a5c00)"><?= htmlspecialchars($reason) ?></p>
      </div>
      <a href="edit-listing.php?id=<?= $l['listing_id'] ?>&return=<?= urlencode($returnUrl) ?>" class="btn btn-primary btn-sm">Edit</a>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>

</div>
</main>
</div>
</body></html>