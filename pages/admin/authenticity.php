<?php
// pages/admin/authenticity.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole(['admin']);

$admin   = currentUser();
$adminId = $admin['admin_id'] ?? $admin['id'];

$successMsg = '';
$errorMsg   = '';

// ------------------------------------------------------------
// Handle approve / reject
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $authId = (int)($_POST['authentication_id'] ?? 0);
    $action = $_POST['action'] ?? '';
    $remarks = trim($_POST['remarks'] ?? '');

    $row = DB::fetch('SELECT * FROM AUTHENTICATION WHERE authentication_id=?', [$authId]);

    if (!$row) {
        $errorMsg = 'Authenticity request not found.';
    } elseif ($row['authentication_status'] !== 'Pending') {
        $errorMsg = 'This request has already been reviewed.';
    } elseif ($action === 'approve') {
        // The after_authentication_status_change trigger automatically activates the listing and notifies the seller.
        DB::query(
            'UPDATE AUTHENTICATION
             SET authentication_status="Verified", verified_by_admin_id=?, date_verified=NOW(), remarks=?
             WHERE authentication_id=?',
            [$adminId, $remarks ?: $row['remarks'], $authId]
        );
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Approved authenticity request', 'AUTHENTICATION', $authId, 'Pending', 'Verified']);
        $successMsg = 'Authenticity request #' . $authId . ' approved - listing is now live.';
    } elseif ($action === 'reject') {
        if (!$remarks) {
            $errorMsg = 'Please provide a reason for rejecting this authenticity request.';
        } else {
            
          // The after_authentication_status_change trigger automatically activates the listing and notifies the seller.
            DB::query(
                'UPDATE AUTHENTICATION
                 SET authentication_status="Rejected", verified_by_admin_id=?, date_verified=NOW(), remarks=?
                 WHERE authentication_id=?',
                [$adminId, $remarks, $authId]
            );
            DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
                [$adminId, 'Rejected authenticity request: ' . $remarks, 'AUTHENTICATION', $authId, 'Pending', 'Rejected']);
            $successMsg = 'Authenticity request #' . $authId . ' rejected. The seller has been notified.';
        }
    }
}

$filter = $_GET['status'] ?? 'Pending';
$validFilters = ['Pending','Verified','Rejected'];
if (!in_array($filter, $validFilters, true)) $filter = 'Pending';

$dateFrom = trim($_GET['from'] ?? '');
$dateTo   = trim($_GET['to'] ?? '');
$dateSql  = ''; $dateParams = [];
if ($dateFrom) { $dateSql .= ' AND l.created_at >= ?'; $dateParams[] = $dateFrom . ' 00:00:00'; }
if ($dateTo)   { $dateSql .= ' AND l.created_at <= ?'; $dateParams[] = $dateTo . ' 23:59:59'; }

$requests = DB::fetchAll(
    "SELECT au.*, l.title, l.price, l.condition_grade, l.listing_id, l.created_at AS submitted_at,
            b.brand_name, pl.tier, s.username AS seller_name, s.shop_name, s.email AS seller_email, s.seller_id,
            (SELECT COUNT(*) FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id) AS photo_count,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY image_id DESC LIMIT 1) AS last_image,
            admn.username AS reviewed_by
     FROM AUTHENTICATION au
     JOIN LISTINGS l ON au.listing_id=l.listing_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     JOIN BRANDS b ON pl.brand_id=b.brand_id
     JOIN SELLER s ON l.seller_id=s.seller_id
     LEFT JOIN ADMIN admn ON au.verified_by_admin_id=admn.admin_id
     WHERE au.authentication_status=?$dateSql
     ORDER BY l.created_at ASC",
    array_merge([$filter], $dateParams)
);

// Groups by the listing's submission date to sort the review queue oldest-first.
function groupByDateAsc(array $rows, string $dateField): array {
    $groups = [];
    foreach ($rows as $row) {
        $key = date('F j, Y', strtotime($row[$dateField]));
        $groups[$key][] = $row;
    }
    return $groups;
}
$requestsByDate = groupByDateAsc($requests, 'submitted_at');

$pendingCount = DB::fetch("SELECT COUNT(*) c FROM AUTHENTICATION WHERE authentication_status='Pending'")['c'] ?? 0;

renderHead('Authenticity Review');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('authenticity'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('authenticity'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Authenticity Review</h1>
  <p class="tb-page-subtitle mb-6">Approve or reject luxury-tagged listings submitted for authenticity verification. Approved items auto-post immediately.</p>

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>
  <?php if ($errorMsg): ?><div class="tb-alert tb-alert-error show mb-6"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div><?php endif; ?>

  <div class="tb-tabs mb-6">
    <?php foreach ($validFilters as $s): ?>
    <a href="?status=<?= $s ?>&from=<?= htmlspecialchars($dateFrom) ?>&to=<?= htmlspecialchars($dateTo) ?>" class="tb-tab-link <?= $filter===$s?'active':'' ?>">
      <?= $s ?><?= $s==='Pending' && $pendingCount ? ' ('.$pendingCount.')' : '' ?>
    </a>
    <?php endforeach; ?>
  </div>

  <form method="GET" class="flex flex-wrap items-end gap-3 mb-6">
    <input type="hidden" name="status" value="<?= $filter ?>">
    <div>
      <label class="tb-label">From</label>
      <input type="date" name="from" value="<?= htmlspecialchars($dateFrom) ?>" class="tb-input">
    </div>
    <div>
      <label class="tb-label">To</label>
      <input type="date" name="to" value="<?= htmlspecialchars($dateTo) ?>" class="tb-input">
    </div>
    <button type="submit" class="btn btn-primary btn-sm">Filter</button>
    <?php if ($dateFrom || $dateTo): ?><a href="?status=<?= $filter ?>" class="btn btn-ghost btn-sm">Clear</a><?php endif; ?>
    <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-left:auto">Oldest submissions shown first</span>
  </form>

  <?php if (empty($requests)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">verified</span>
    No <?= strtolower($filter) ?> authenticity requests.
  </div>
  <?php else: foreach ($requestsByDate as $dateLabel => $rows): ?>
  <h3 style="font-size:var(--fs-label-sm);font-weight:800;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin:18px 0 10px;padding-bottom:6px;border-bottom:1px solid var(--clr-outline)">
    <?= htmlspecialchars($dateLabel) ?> <span style="font-weight:500;text-transform:none;letter-spacing:normal">(<?= count($rows) ?>)</span>
  </h3>
  <div class="flex flex-col gap-5" style="margin-bottom:8px">
    <?php foreach ($rows as $r): ?>
    <div class="tb-card">
      <div class="tb-card-body">
        <div class="flex flex-wrap justify-between gap-4 mb-4">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="tb-badge <?= $r['authentication_status']==='Pending'?'tb-badge-coral':($r['authentication_status']==='Verified'?'tb-badge-green':'tb-badge-red') ?>"><?= $r['authentication_status'] ?></span>
              <span class="tb-badge" style="background:#1a1a1a;color:#fff">Luxury &bull; <?= htmlspecialchars($r['tier']) ?></span>
              <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Request #<?= $r['authentication_id'] ?></span>
            </div>
            <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($r['title']) ?></h3>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($r['brand_name']) ?> &bull; <?= htmlspecialchars($r['condition_grade']) ?> &bull; <?= convertCurrency((float)$r['price']) ?></p>
          </div>
          <div style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);text-align:right">
            <p>Seller: @<?= htmlspecialchars($r['seller_name']) ?><?= $r['shop_name'] ? ' (' . htmlspecialchars($r['shop_name']) . ')' : '' ?></p>
            <p><?= htmlspecialchars($r['seller_email']) ?></p>
            <?php if ($r['reviewed_by']): ?><p>Reviewed by: @<?= htmlspecialchars($r['reviewed_by']) ?></p><?php endif; ?>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Cover Photo</p>
            <?php if ($r['cover_image']): ?>
            <img src="<?= htmlspecialchars($r['cover_image']) ?>" alt="cover" style="width:100%;max-width:160px;border-radius:8px;margin-top:6px">
            <?php else: ?>
            <p style="color:var(--clr-tertiary)">No photo</p>
            <?php endif; ?>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Certificate / Box Photo</p>
            <?php if ($r['photo_count'] > 1 && $r['last_image']): ?>
            <img src="<?= htmlspecialchars($r['last_image']) ?>" alt="certificate or box" style="width:100%;max-width:160px;border-radius:8px;margin-top:6px">
            <?php else: ?>
            <p style="color:var(--clr-tertiary)">Only 1 photo submitted</p>
            <?php endif; ?>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Seller's Submission Note</p>
            <p style="font-size:var(--fs-label-md)"><?= htmlspecialchars($r['remarks'] ?? '') ?></p>
            <a href="<?= BASE_URL ?>/pages/customer/listing.php?id=<?= $r['listing_id'] ?>" target="_blank" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View full listing &rarr;</a>
          </div>
        </div>

        <?php if ($r['authentication_status'] === 'Pending'): ?>
        <form method="POST" class="flex flex-wrap items-end gap-3">
          <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
          <input type="hidden" name="authentication_id" value="<?= $r['authentication_id'] ?>">
          <div class="flex-1" style="min-width:220px">
            <label style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Reviewer note (required to reject)</label>
            <input type="text" name="remarks" class="tb-input" placeholder="e.g. Box mismatch — serial number doesn't match certificate">
          </div>
          <button type="submit" name="action" value="approve" class="btn btn-primary btn-sm" onclick="return confirm('Approve and auto-post this listing?')">
            <span class="material-symbols-outlined icon-sm">check_circle</span>Approve &amp; Post
          </button>
          <button type="submit" name="action" value="reject" class="btn btn-ghost btn-sm" onclick="return confirm('Reject this authenticity request?')">
            <span class="material-symbols-outlined icon-sm">cancel</span>Reject
          </button>
        </form>
        <?php endif; ?>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endforeach; endif; ?>

</div>
</main>
</div>
</body></html>