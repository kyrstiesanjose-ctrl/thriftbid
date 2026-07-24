<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole(['seller','admin'],'/pages/login.php');

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id']; // session row IS the seller row now

$tab     = $_GET['tab'] ?? 'active';
$created = isset($_GET['created']);

// ------------------------------------------------------------
// Close auction manually -> pick the winner -> create the ORDER.
// All of this now lives in sp_close_auction() so admin tools and
// the seller UI both get the exact same behavior, it still relies
// on after_order_insert_deactivate_listing (AFTER INSERT ON ORDERS)
// to deactivate the listing and notify the seller; the procedure
// only sends the two messages the trigger can't know about (who
// won, and the seller-facing "closed" summary).
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['close_auction']) && verifyCsrf($_POST['csrf'] ?? '')) {
    $aid   = (int)$_POST['auction_id'];
    $owns  = DB::fetch('SELECT a.auction_id FROM AUCTIONS a JOIN LISTINGS l ON a.listing_id=l.listing_id WHERE a.auction_id=? AND l.seller_id=?', [$aid, $sellerId]);
    if ($owns) {
        DB::callProc('sp_close_auction', [$aid]);
    }
    header('Location: active-auctions.php?tab=closed');
    exit;
}

$imgSub = '(SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image';

// ------------------------------------------------------------
// Filters, search by title, filter by category, luxury-only toggle.
// Applied across all three tabs so the view stays consistent no
// matter which one you're on.
// ------------------------------------------------------------
$q          = trim($_GET['q'] ?? '');
$catFilter  = (int)($_GET['cat'] ?? 0);
$luxuryOnly = isset($_GET['luxury']);
$statusFilter = in_array($_GET['status'] ?? '', ['active','inactive'], true) ? $_GET['status'] : '';

// Filters from analytics recommendations
$photoFilter   = $_GET['photo_filter']   ?? '';   // 'low'         -> listings with ≤1 photo
$detailsFilter = $_GET['details_filter'] ?? '';   // 'incomplete'  -> missing color/gender/material/made_in
$detailsIncompleteBy = $_GET['incomplete_by'] ?? ''; // color|gender|material|made_in
$pricingFilter = $_GET['pricing_filter'] ?? '';   // 'inconsistent'-> same product_line, different prices

$sellerCategories = DB::fetchAll(
    'SELECT DISTINCT c.category_id, c.name FROM CATEGORIES c
     JOIN LISTINGS l ON l.category_id=c.category_id
     WHERE l.seller_id=? ORDER BY c.name',
    [$sellerId]
);

$filterSql = ''; $filterParams = [];
if ($q)         { $filterSql .= ' AND l.title LIKE ?'; $filterParams[] = "%$q%"; }
if ($catFilter) { $filterSql .= ' AND l.category_id=?'; $filterParams[] = $catFilter; }
if ($luxuryOnly) { $filterSql .= ' AND pl.tier="High"'; }
if ($statusFilter === 'active')   { $filterSql .= ' AND l.is_active=1'; }
if ($statusFilter === 'inactive') { $filterSql .= ' AND l.is_active=0'; }

// Analytics recommendation filters
if ($photoFilter === 'low') {
    $filterSql .= ' AND (SELECT COUNT(*) FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id) <= 1';
}
if ($detailsFilter === 'incomplete') {
    if ($detailsIncompleteBy === 'color') {
        $filterSql .= " AND (l.color IS NULL OR l.color='')";
    } elseif ($detailsIncompleteBy === 'gender') {
        $filterSql .= " AND (l.target_gender IS NULL OR l.target_gender='')";
    } elseif ($detailsIncompleteBy === 'material') {
        $filterSql .= " AND (l.material IS NULL OR l.material='')";
    } elseif ($detailsIncompleteBy === 'made_in') {
        $filterSql .= " AND (l.made_in IS NULL OR l.made_in='')";
    } else {
        // No sub-filter: show all incomplete (any missing field)
        $filterSql .= " AND (l.color IS NULL OR l.color='' OR l.target_gender IS NULL OR l.target_gender=''
                             OR l.material IS NULL OR l.material='' OR l.made_in IS NULL OR l.made_in='')";
    }
}
if ($pricingFilter === 'inconsistent') {
    $filterSql .= ' AND l.product_line_id IN (
        SELECT product_line_id FROM LISTINGS
        WHERE seller_id=? AND deleted_at IS NULL
        GROUP BY product_line_id HAVING MIN(price) <> MAX(price)
    )';
    $filterParams[] = $sellerId;
}

// Groups a flat list of rows (each with a 'created_at' key) into
// ['January 2026' => [...], 'December 2025' => [...], ...] ordered
// newest month first, for the "organize by month" view.
function groupByMonth(array $rows): array {
    $groups = [];
    foreach ($rows as $row) {
        $key = date('F Y', strtotime($row['created_at']));
        $groups[$key][] = $row;
    }
    return $groups;
}

$activeAuctions = DB::fetchAll(
    "SELECT a.*, l.title, l.condition_grade, l.listing_id, l.created_at, l.original_price, sz.size_value, c.name AS cat_name, pl.tier, $imgSub,
            (SELECT view_count FROM LISTING_ANALYTICS WHERE listing_id=l.listing_id) AS view_count,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id AND is_deleted=0) AS bid_count
     FROM AUCTIONS a
     JOIN LISTINGS l   ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     JOIN CATEGORY_SIZES sz ON l.size_id=sz.size_id
     WHERE l.seller_id=? AND a.status='Active'$filterSql
     ORDER BY l.created_at DESC",
    array_merge([$sellerId], $filterParams)
);
$closedAuctions = DB::fetchAll(
    "SELECT a.*, l.title, l.created_at, l.listing_id, l.original_price, l.price, sz.size_value, c.name AS cat_name, pl.tier, $imgSub,
            (SELECT view_count FROM LISTING_ANALYTICS WHERE listing_id=l.listing_id) AS view_count,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id AND is_deleted=0) AS bid_count
     FROM AUCTIONS a
     JOIN LISTINGS l   ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     JOIN CATEGORY_SIZES sz ON l.size_id=sz.size_id
     WHERE l.seller_id=? AND a.status='Closed'$filterSql
     ORDER BY a.end_time DESC LIMIT 60",
    array_merge([$sellerId], $filterParams)
);
$fixedListings = DB::fetchAll(
    "SELECT l.*, sz.size_value, c.name AS cat_name, pl.tier,
            au.authentication_status, $imgSub,
            (SELECT view_count FROM LISTING_ANALYTICS WHERE listing_id=l.listing_id) AS view_count
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     JOIN CATEGORY_SIZES sz ON l.size_id=sz.size_id
     LEFT JOIN AUTHENTICATION au ON au.listing_id=l.listing_id
     WHERE l.seller_id=? AND l.deleted_at IS NULL
       AND l.listing_id NOT IN (SELECT listing_id FROM AUCTIONS)$filterSql
     ORDER BY l.created_at DESC",
    array_merge([$sellerId], $filterParams)
);

$luxuryListings = DB::fetchAll(
    "SELECT l.*, sz.size_value, c.name AS cat_name, pl.tier, au.authentication_status, au.remarks, $imgSub,
            (SELECT view_count FROM LISTING_ANALYTICS WHERE listing_id=l.listing_id) AS view_count,
            (SELECT auction_id FROM AUCTIONS WHERE listing_id=l.listing_id AND status='Active') AS active_auction_id
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     JOIN CATEGORY_SIZES sz ON l.size_id=sz.size_id
     LEFT JOIN AUTHENTICATION au ON au.listing_id=l.listing_id
     WHERE l.seller_id=? AND pl.tier='High' AND l.deleted_at IS NULL$filterSql
     ORDER BY l.created_at DESC",
    array_merge([$sellerId], $filterParams)
);

$activeByMonth  = groupByMonth($activeAuctions);
$closedByMonth  = groupByMonth($closedAuctions);
$fixedByMonth   = groupByMonth($fixedListings);
$luxuryByMonth  = groupByMonth($luxuryListings);

renderHead('My Listings &amp; Auctions');
?>
<body style="height:100vh;overflow:hidden;display:flex;flex-direction:column">
<?php renderNavbar('auctions', true); ?>
<div style="display:flex;flex:1;overflow:hidden">
<?php renderSellerSidebar('auctions'); ?>
<main style="flex:1;overflow-y:auto;background:var(--clr-bg)">
<div style="max-width:1200px;margin:0 auto;padding:32px 40px 80px">

  <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:20px;flex-wrap:wrap;gap:12px">
    <div>
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:700;color:var(--clr-text)">My Listings &amp; Auctions</h1>
      <p style="color:var(--clr-tertiary);margin-top:4px">Everything you're selling, organized by month.</p>
    </div>
    <a href="create-listing.php" class="btn btn-primary">
      <span class="material-symbols-outlined icon-sm">add</span>New Listing
    </a>
  </div>

  <?php if ($created): ?>
  <div class="tb-alert tb-alert-success show" style="margin-bottom:16px">
    <span class="material-symbols-outlined icon-sm">check_circle</span>Listing published successfully!
  </div>
  <?php endif; ?>

  <div class="tb-tabs" style="margin-bottom:20px">
    <a href="?tab=active&q=<?= urlencode($q) ?>&cat=<?= $catFilter ?><?= $luxuryOnly?'&luxury=1':'' ?>"  class="tb-tab-link <?= $tab==='active'?'active':'' ?>">Active Auctions (<?= count($activeAuctions) ?>)</a>
    <a href="?tab=fixed&q=<?= urlencode($q) ?>&cat=<?= $catFilter ?><?= $luxuryOnly?'&luxury=1':'' ?>"   class="tb-tab-link <?= $tab==='fixed'?'active':'' ?>">Fixed Price (<?= count($fixedListings) ?>)</a>
    <a href="?tab=luxury&q=<?= urlencode($q) ?>&cat=<?= $catFilter ?><?= $luxuryOnly?'&luxury=1':'' ?>"  class="tb-tab-link <?= $tab==='luxury'?'active':'' ?>">Luxury (<?= count($luxuryListings) ?>)</a>
    <a href="?tab=closed&q=<?= urlencode($q) ?>&cat=<?= $catFilter ?><?= $luxuryOnly?'&luxury=1':'' ?>"  class="tb-tab-link <?= $tab==='closed'?'active':'' ?>">Closed (<?= count($closedAuctions) ?>)</a>
  </div>

  <?php
  // Show a contextual banner when arriving from an analytics recommendation
  if ($photoFilter === 'low'): ?>
  <div class="tb-alert tb-alert-warning show" style="margin-bottom:16px">
    <span class="material-symbols-outlined icon-sm">image</span>
    Showing listings with <strong>only 1 photo</strong>. Add more photos to improve visibility and bids.
    <a href="?tab=<?= $tab ?>" style="margin-left:8px;font-weight:700">Clear filter &times;</a>
  </div>
  <?php elseif ($detailsFilter === 'incomplete'): ?>
  <div class="tb-alert tb-alert-warning show" style="margin-bottom:16px">
    <span class="material-symbols-outlined icon-sm">description</span>
    Showing listings with <strong>incomplete item details</strong>. Fill in missing fields to boost buyer confidence.
    <a href="?tab=<?= $tab ?>" style="margin-left:8px;font-weight:700">Clear filter &times;</a>
  </div>
  <?php elseif ($pricingFilter === 'inconsistent'): ?>
  <div class="tb-alert tb-alert-warning show" style="margin-bottom:16px">
    <span class="material-symbols-outlined icon-sm">payments</span>
    Showing listings with <strong>inconsistent pricing</strong> across the same product line. Review and align your prices.
    <a href="?tab=<?= $tab ?>" style="margin-left:8px;font-weight:700">Clear filter &times;</a>
  </div>
  <?php endif; ?>

  <!-- Filters -->
  <form method="GET" class="tb-filter-bar" style="margin-bottom:28px">
    <input type="hidden" name="tab" value="<?= htmlspecialchars($tab) ?>">
    <?php if ($photoFilter):   ?><input type="hidden" name="photo_filter"   value="<?= htmlspecialchars($photoFilter) ?>"><?php endif; ?>
    <?php if ($pricingFilter): ?><input type="hidden" name="pricing_filter" value="<?= htmlspecialchars($pricingFilter) ?>"><?php endif; ?>
    <?php if ($detailsFilter): ?><input type="hidden" name="details_filter" value="<?= htmlspecialchars($detailsFilter) ?>"><?php endif; ?>
    <div style="position:relative;flex:1;min-width:200px;max-width:280px">
      <span class="material-symbols-outlined icon-sm" style="position:absolute;left:9px;top:50%;transform:translateY(-50%);color:var(--clr-tertiary)">search</span>
      <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Search your listings..." class="tb-input" style="padding-left:32px;font-size:var(--fs-label-md)">
    </div>
    <select name="cat" class="tb-input" style="width:auto" onchange="this.form.submit()">
      <option value="">All Categories</option>
      <?php foreach ($sellerCategories as $c): ?>
      <option value="<?= $c['category_id'] ?>" <?= $catFilter==$c['category_id']?'selected':'' ?>><?= htmlspecialchars($c['name']) ?></option>
      <?php endforeach; ?>
    </select>
    <select name="status" class="tb-input" style="width:auto" onchange="this.form.submit()">
      <option value="">All Statuses</option>
      <option value="active" <?= $statusFilter==='active'?'selected':'' ?>>Active</option>
      <option value="inactive" <?= $statusFilter==='inactive'?'selected':'' ?>>Inactive</option>
    </select>
    <?php if ($detailsFilter === 'incomplete'): ?>
    <select name="incomplete_by" class="tb-input" style="width:auto" onchange="this.form.submit()">
      <option value="" <?= $detailsIncompleteBy===''?'selected':'' ?>>Incomplete by (All)</option>
      <option value="color"    <?= $detailsIncompleteBy==='color'   ?'selected':'' ?>>Color</option>
      <option value="gender"   <?= $detailsIncompleteBy==='gender'  ?'selected':'' ?>>Gender</option>
      <option value="material" <?= $detailsIncompleteBy==='material'?'selected':'' ?>>Material</option>
      <option value="made_in"  <?= $detailsIncompleteBy==='made_in' ?'selected':'' ?>>Made In</option>
    </select>
    <?php endif; ?>
    <label style="display:flex;align-items:center;gap:6px;padding:0 10px;border:1px solid var(--clr-outline);border-radius:var(--radius-sm);height:38px;cursor:pointer;background:<?= $luxuryOnly ? '#1a1a1a' : 'var(--clr-white)' ?>;color:<?= $luxuryOnly ? '#fff' : 'var(--clr-text)' ?>">
      <input type="checkbox" name="luxury" value="1" <?= $luxuryOnly?'checked':'' ?> onchange="this.form.submit()" style="accent-color:var(--clr-coral)">
      <span class="material-symbols-outlined icon-sm">verified</span>
      <span style="font-size:var(--fs-label-sm);font-weight:600">Luxury Only</span>
    </label>
    <button type="submit" class="btn btn-primary btn-sm">Apply</button>
    <?php if ($q || $catFilter || $luxuryOnly || $statusFilter || $photoFilter || $detailsFilter || $pricingFilter): ?>
    <a href="?tab=<?= $tab ?>" class="btn btn-ghost btn-sm">Clear All</a>
    <?php endif; ?>
  </form>

  <?php
  // ------------------------------------------------------------
  // One shared card component for every tab. $stats is a list of
  // [label, value] column pairs (Highest Bid / Bids / Ends In / Views,
  // or just Price / Views depending on tab) laid out like a mini table,
  // plus one primary action and a compact "⋮" menu for the rest.
  // ------------------------------------------------------------
  $cardIndex = 0;
  function renderListingCard(?string $image, string $badgesHtml, string $title, string $itemDetailsHtml,
                              array $stats, string $primaryHtml, array $menuItems, ?string $clickHref = null): void {
      global $cardIndex; $cardIndex++;
      $menuId = 'menu' . $cardIndex;
      ?>
      <div class="tb-listing-row" <?= $clickHref ? 'style="cursor:pointer" onclick="window.location.href=\''.htmlspecialchars($clickHref).'\'"' : '' ?>>
        <div class="tb-listing-row-thumb">
          <?php if ($image): ?><img src="<?= htmlspecialchars($image) ?>" alt=""><?php else: ?><span class="material-symbols-outlined" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
        </div>
        <div class="tb-listing-row-body">
          <div class="tb-listing-row-badges"><?= $badgesHtml ?></div>
          <h3 class="tb-listing-row-title"><?= htmlspecialchars($title) ?></h3>
          <p class="tb-listing-row-meta"><?= $itemDetailsHtml ?></p>
        </div>
        <div class="tb-listing-row-stats">
          <?php foreach ($stats as $s): ?>
          <div class="tb-listing-row-stat">
            <span class="tb-listing-row-stat-label"><?= htmlspecialchars($s['label']) ?></span>
            <span class="tb-listing-row-stat-value"><?= $s['value'] ?></span>
          </div>
          <?php endforeach; ?>
        </div>
        <div class="tb-listing-row-actions" onclick="event.stopPropagation()">
          <?= $primaryHtml ?>
          <?php if (!empty($menuItems)): ?>
          <div class="tb-kebab" data-menu="<?= $menuId ?>">
            <button type="button" class="tb-kebab-btn" aria-label="More actions">
              <span class="material-symbols-outlined icon-sm">more_vert</span>
            </button>
            <div class="tb-kebab-menu" id="<?= $menuId ?>">
              <?php foreach ($menuItems as $item): ?>
              <?= $item ?>
              <?php endforeach; ?>
            </div>
          </div>
          <?php endif; ?>
        </div>
      </div>
      <?php
  }

  function monthHeader(string $month, int $count): void { ?>
  <div class="tb-month-heading">
    <?= htmlspecialchars($month) ?>
    <span class="tb-month-count"><?= $count ?></span>
  </div>
  <?php }

  // Item ID / Size / Original Price / Selling Price, the same detail
  // line used under every listing's title, regardless of tab.
  function itemDetailsLine(array $l, string $priceLabel = 'Selling', ?float $priceOverride = null): string {
      $parts = [
          'ID #' . $l['listing_id'],
          'Size ' . htmlspecialchars($l['size_value']),
      ];
      if (!empty($l['original_price'])) $parts[] = 'Retail ' . convertCurrency((float)$l['original_price']);
      $parts[] = $priceLabel . ' ' . convertCurrency($priceOverride ?? (float)($l['price'] ?? 0));
      return implode(' &bull; ', $parts);
  }
  ?>

  <?php if ($tab === 'active'): ?>
  <?php if (empty($activeAuctions)): ?>
  <div class="tb-empty-state">
    <span class="material-symbols-outlined icon-xl">gavel</span>
    <p>No active auctions found</p>
    <p class="tb-empty-sub">Try clearing your filters, or create a new listing.</p>
    <a href="create-listing.php" class="btn btn-primary">Create Listing</a>
  </div>
  <?php else: foreach ($activeByMonth as $month => $rows): ?>
  <?php monthHeader($month, count($rows)); ?>
  <div class="tb-listing-list">
    <?php foreach ($rows as $a):
      $isUrgent = (strtotime($a['end_time']) - time()) < 3600;
      $badges = '<span class="tb-badge '.($isUrgent?'tb-badge-red':'tb-badge-active').'">'.($isUrgent?'Ending Soon':'Active').'</span>'
              . '<span class="tb-badge tb-badge-gray">'.htmlspecialchars($a['cat_name']).'</span>'
              . ((int)$a['extension_count'] > 0 ? '<span class="tb-badge tb-badge-coral">Extended '.$a['extension_count'].'&times;</span>' : '');
      $details = itemDetailsLine($a, 'Starting Bid', (float)($a['start_bid'] ?? 0));
      $stats = [
        ['label'=>'Highest Bid', 'value'=>convertCurrency((float)$a['current_highest_bid'])],
        ['label'=>'Bids',        'value'=>$a['bid_count']],
        ['label'=>'Ends In',     'value'=>'<span'.($isUrgent?' style="color:var(--clr-error)"':'').'>'.formatTimeLeft($a['end_time']).'</span>'],
        ['label'=>'Views',       'value'=>number_format((int)($a['view_count'] ?? 0))],
      ];
      $primary = '<a href="../customer/auction_room.php?id='.$a['auction_id'].'" class="btn btn-primary btn-sm">Manage Live</a>';
      $menu = [
        '<a href="edit-listing.php?id='.$a['listing_id'].'" class="tb-kebab-item"><span class="material-symbols-outlined icon-sm">edit</span>Edit Details</a>',
        '<form method="POST" onsubmit="return confirm(\'Close this auction and declare a winner?\')"><input type="hidden" name="csrf" value="'.csrfToken().'"><input type="hidden" name="close_auction" value="1"><input type="hidden" name="auction_id" value="'.$a['auction_id'].'"><button type="submit" class="tb-kebab-item"><span class="material-symbols-outlined icon-sm">stop_circle</span>Close Now</button></form>',
      ];
      renderListingCard($a['cover_image'], $badges, $a['title'], $details, $stats, $primary, $menu);
    ?>
    <?php endforeach; ?>
  </div>
  <?php endforeach; endif; ?>

  <?php elseif ($tab === 'fixed'): ?>
  <?php if (empty($fixedListings)): ?>
  <div class="tb-empty-state">
    <span class="material-symbols-outlined icon-xl">sell</span>
    <p>No fixed-price listings found</p>
    <a href="create-listing.php" class="btn btn-primary">Create Listing</a>
  </div>
  <?php else: foreach ($fixedByMonth as $month => $rows): ?>
  <?php monthHeader($month, count($rows)); ?>
  <div class="tb-listing-list">
    <?php foreach ($rows as $l):
      $badges = '<span class="tb-badge '.($l['is_active']?'tb-badge-active':'tb-badge-gray').'">'.($l['is_active']?'Active':'Inactive').'</span>'
              . '<span class="tb-badge tb-badge-gray">'.htmlspecialchars($l['cat_name']).'</span>';
      $details = itemDetailsLine($l);
      $stats = [
        ['label'=>'Condition', 'value'=>htmlspecialchars($l['condition_grade'])],
        ['label'=>'Listed',    'value'=>date('M d', strtotime($l['created_at']))],
        ['label'=>'Views',     'value'=>number_format((int)($l['view_count'] ?? 0))],
      ];
      $primary = '<a href="edit-listing.php?id='.$l['listing_id'].'" class="btn btn-primary btn-sm" onclick="event.stopPropagation()">Edit Listing</a>';
      $menu = [];
      renderListingCard($l['cover_image'], $badges, $l['title'], $details, $stats, $primary, $menu, '../customer/listing.php?id='.$l['listing_id']);
    ?>
    <?php endforeach; ?>
  </div>
  <?php endforeach; endif; ?>

  <?php elseif ($tab === 'luxury'): ?>
  <?php if (empty($luxuryListings)): ?>
  <div class="tb-empty-state">
    <span class="material-symbols-outlined icon-xl">verified</span>
    <p>No luxury listings found</p>
    <p class="tb-empty-sub">Tag an item as Luxury when creating a listing to see its authenticity status here.</p>
  </div>
  <?php else: foreach ($luxuryByMonth as $month => $rows): ?>
  <?php monthHeader($month, count($rows)); ?>
  <div class="tb-listing-list">
    <?php foreach ($rows as $l):
      if ($l['authentication_status'] === 'Verified') { $badge = '<span class="tb-badge" style="background:#1a1a1a;color:#fff">Approved'.($l['active_auction_id']?' &bull; Auction':'').'</span>'; }
      elseif ($l['authentication_status'] === 'Rejected') { $badge = '<span class="tb-badge tb-badge-red">Rejected</span>'; }
      else { $badge = '<span class="tb-badge tb-badge-coral">Pending Review</span>'; }
      $badges = $badge.'<span class="tb-badge tb-badge-gray">'.htmlspecialchars($l['cat_name']).'</span>';
      $details = itemDetailsLine($l);
      $stats = [
        ['label'=>'Listed', 'value'=>date('M d, Y', strtotime($l['created_at']))],
        ['label'=>'Views',  'value'=>number_format((int)($l['view_count'] ?? 0))],
      ];
      if ($l['authentication_status']==='Rejected' && $l['remarks']) {
        $stats[] = ['label'=>'Admin Note', 'value'=>htmlspecialchars($l['remarks'])];
      }
      $primary = '<a href="edit-listing.php?id='.$l['listing_id'].'" class="btn btn-primary btn-sm" onclick="event.stopPropagation()">Edit Listing</a>';
      renderListingCard($l['cover_image'], $badges, $l['title'], $details, $stats, $primary, [], '../customer/listing.php?id='.$l['listing_id']);
    ?>
    <?php endforeach; ?>
  </div>
  <?php endforeach; endif; ?>

  <?php elseif ($tab === 'closed'): ?>
  <?php if (empty($closedAuctions)): ?>
  <div class="tb-empty-state">
    <span class="material-symbols-outlined icon-xl">inventory_2</span>
    <p>No closed auctions found</p>
  </div>
  <?php else: foreach ($closedByMonth as $month => $rows): ?>
  <?php monthHeader($month, count($rows)); ?>
  <div class="tb-listing-list">
    <?php foreach ($rows as $a):
      $badges = '<span class="tb-badge tb-badge-gray">Closed</span><span class="tb-badge tb-badge-gray">'.htmlspecialchars($a['cat_name']).'</span>';
      $details = itemDetailsLine($a, 'Starting Bid', (float)($a['start_bid'] ?? 0));
      $stats = [
        ['label'=>'Final Bid', 'value'=>convertCurrency((float)$a['current_highest_bid'])],
        ['label'=>'Bids',      'value'=>$a['bid_count']],
        ['label'=>'Ended',     'value'=>date('M d, Y', strtotime($a['end_time']))],
        ['label'=>'Views',     'value'=>number_format((int)($a['view_count'] ?? 0))],
      ];
      renderListingCard($a['cover_image'], $badges, $a['title'], $details, $stats, '', [], '../customer/listing.php?id='.$a['listing_id']);
    ?>
    <?php endforeach; ?>
  </div>
  <?php endforeach; endif; ?>
  <?php endif; ?>

</div>
</main>
</div>

<style>
.tb-month-heading{font-size:13px;font-weight:800;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:.06em;margin:26px 0 12px;padding-bottom:8px;border-bottom:1px solid var(--clr-outline)}
.tb-month-heading:first-child{margin-top:0}
.tb-month-count{font-weight:500;text-transform:none;letter-spacing:normal;color:var(--clr-outline);margin-left:2px}

.tb-listing-list{display:flex;flex-direction:column;gap:10px;margin-bottom:8px}
.tb-listing-row{display:flex;align-items:center;gap:16px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:14px 18px;transition:box-shadow .15s ease,transform .15s ease}
.tb-listing-row:hover{box-shadow:0 4px 14px rgba(0,0,0,0.06);transform:translateY(-1px)}
.tb-listing-row-thumb{width:56px;height:56px;border-radius:10px;overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center}
.tb-listing-row-thumb img{width:100%;height:100%;object-fit:cover}
.tb-listing-row-body{flex:1;min-width:0}
.tb-listing-row-badges{display:flex;gap:6px;margin-bottom:4px;flex-wrap:wrap}
.tb-listing-row-title{font-weight:700;font-size:var(--fs-body-md);color:var(--clr-text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.tb-listing-row-meta{font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px}
.tb-listing-row-stats{display:flex;gap:26px;flex-shrink:0}
.tb-listing-row-stat{display:flex;flex-direction:column;align-items:flex-start;min-width:70px}
.tb-listing-row-stat-label{font-size:11px;font-weight:600;color:var(--clr-tertiary)}
.tb-listing-row-stat-value{font-weight:700;font-size:var(--fs-label-md);color:var(--clr-text);margin-top:2px}
.tb-listing-row-actions{display:flex;align-items:center;gap:6px;flex-shrink:0;position:relative}

.tb-kebab{position:relative}
.tb-kebab-btn{width:34px;height:34px;border-radius:8px;border:1px solid var(--clr-outline);background:var(--clr-white);display:flex;align-items:center;justify-content:center;cursor:pointer;color:var(--clr-tertiary)}
.tb-kebab-btn:hover{background:var(--clr-surface-low)}
.tb-kebab-menu{display:none;position:absolute;top:calc(100% + 6px);right:0;min-width:180px;background:#fff;border:1px solid var(--clr-outline);border-radius:10px;box-shadow:0 10px 28px rgba(0,0,0,0.12);z-index:40;overflow:hidden}
.tb-kebab-menu.open{display:block}
.tb-kebab-item{display:flex;align-items:center;gap:8px;width:100%;padding:10px 14px;font-size:13px;color:var(--clr-text);background:none;border:none;text-align:left;cursor:pointer;text-decoration:none}
.tb-kebab-item:hover{background:var(--clr-surface-low)}

.tb-empty-state{text-align:center;padding:64px 20px;color:var(--clr-tertiary);background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm)}
.tb-empty-state .material-symbols-outlined{color:var(--clr-outline);display:block;margin-bottom:12px}
.tb-empty-state p{font-weight:700;font-size:var(--fs-headline-sm);margin:0}
.tb-empty-state .tb-empty-sub{font-weight:400;font-size:var(--fs-label-md);margin-top:6px;margin-bottom:16px}
</style>
<script>
document.querySelectorAll('.tb-kebab-btn').forEach(btn => {
  btn.addEventListener('click', e => {
    e.stopPropagation();
    const menu = btn.nextElementSibling;
    document.querySelectorAll('.tb-kebab-menu.open').forEach(m => { if (m !== menu) m.classList.remove('open'); });
    menu.classList.toggle('open');
  });
});
document.addEventListener('click', () => document.querySelectorAll('.tb-kebab-menu.open').forEach(m => m.classList.remove('open')));
</script>
</body></html>