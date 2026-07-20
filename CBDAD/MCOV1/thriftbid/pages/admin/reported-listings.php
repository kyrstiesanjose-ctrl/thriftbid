<?php
// pages/admin/reported-listings.php
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
// Handle take-action / dismiss
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $flagId = (int)($_POST['fraud_flag_id'] ?? 0);
    $action = $_POST['action'] ?? '';

    $flag = DB::fetch('SELECT * FROM FRAUD_FLAGS WHERE fraud_flag_id=?', [$flagId]);

    if (!$flag) {
        $errorMsg = 'Report not found.';
    } elseif ($flag['status'] !== 'Pending') {
        $errorMsg = 'This report has already been reviewed.';
    } elseif ($action === 'takedown') {
        // Approve the report: the listing issue was valid/reasonable, take it down and penalize the seller.
        if ($flag['listing_id']) {
            DB::query('UPDATE LISTINGS SET is_active=0 WHERE listing_id=?', [$flag['listing_id']]);
        }
        if ($flag['seller_id']) {
            DB::query('INSERT INTO PENALTIES (seller_id, reason, penalty_type) VALUES (?,?,?)',
                [$flag['seller_id'], 'Reported listing upheld: ' . $flag['signals_detected'], 'Selling Suspension']);
        }
        DB::query('UPDATE FRAUD_FLAGS SET status="Resolved", reviewed_by_admin_id=? WHERE fraud_flag_id=?', [$adminId, $flagId]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Upheld listing report - listing taken down, seller penalized', 'FRAUD_FLAGS', $flagId, 'Pending', 'Resolved']);
        $successMsg = 'Report #' . $flagId . ' upheld - listing taken down and seller penalized.';
    } elseif ($action === 'dismiss') {
        DB::query('UPDATE FRAUD_FLAGS SET status="Reviewed", reviewed_by_admin_id=? WHERE fraud_flag_id=?', [$adminId, $flagId]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Dismissed listing report - no violation found', 'FRAUD_FLAGS', $flagId, 'Pending', 'Reviewed']);
        $successMsg = 'Report #' . $flagId . ' dismissed - no action taken.';
    }
}

$filter = $_GET['status'] ?? 'Pending';
$validFilters = ['Pending','Reviewed','Resolved'];
if (!in_array($filter, $validFilters, true)) $filter = 'Pending';

$reports = DB::fetchAll(
    'SELECT f.*, l.title, l.price, l.listing_id,
            se.username AS seller_name, se.shop_name, se.offense_count,
            bu.username AS reported_by,
            admn.username AS reviewed_by,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
     FROM FRAUD_FLAGS f
     LEFT JOIN LISTINGS l ON f.listing_id=l.listing_id
     LEFT JOIN SELLER se  ON f.seller_id=se.seller_id
     LEFT JOIN BUYER bu   ON f.buyer_id=bu.buyer_id
     LEFT JOIN ADMIN admn ON f.reviewed_by_admin_id=admn.admin_id
     WHERE f.status=?
     ORDER BY f.created_at DESC',
    [$filter]
);

$pendingCount = DB::fetch("SELECT COUNT(*) c FROM FRAUD_FLAGS WHERE status='Pending'")['c'] ?? 0;

renderHead('Reported Listings');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('reported-listings'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('reported-listings'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Reported Listings</h1>
  <p class="tb-page-subtitle mb-6">Review listings flagged by buyers or the system for suspected fraud, counterfeits, or policy violations.</p>

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>
  <?php if ($errorMsg): ?><div class="tb-alert tb-alert-error show mb-6"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div><?php endif; ?>

  <div class="tb-tabs mb-6">
    <?php foreach ($validFilters as $s): ?>
    <a href="?status=<?= $s ?>" class="tb-tab-link <?= $filter===$s?'active':'' ?>">
      <?= $s ?><?= $s==='Pending' && $pendingCount ? ' ('.$pendingCount.')' : '' ?>
    </a>
    <?php endforeach; ?>
  </div>

  <?php if (empty($reports)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">flag</span>
    No <?= strtolower($filter) ?> reports.
  </div>
  <?php else: ?>
  <div class="flex flex-col gap-5">
    <?php foreach ($reports as $r): ?>
    <div class="tb-card">
      <div class="tb-card-body">
        <div class="flex flex-wrap justify-between gap-4 mb-4">
          <div class="flex gap-3">
            <?php if ($r['cover_image']): ?>
            <img src="<?= htmlspecialchars($r['cover_image']) ?>" style="width:56px;height:56px;object-fit:cover;border-radius:8px">
            <?php endif; ?>
            <div>
              <div class="flex items-center gap-2 mb-1">
                <span class="tb-badge <?= $r['status']==='Pending'?'tb-badge-red':($r['status']==='Resolved'?'tb-badge-green':'tb-badge-gray') ?>"><?= $r['status'] ?></span>
                <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Report #<?= $r['fraud_flag_id'] ?></span>
              </div>
              <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($r['title'] ?? 'Listing removed') ?></h3>
              <?php if ($r['listing_id']): ?><a href="<?= BASE_URL ?>/pages/customer/listing.php?id=<?= $r['listing_id'] ?>" target="_blank" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View listing &rarr;</a><?php endif; ?>
            </div>
          </div>
          <div style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);text-align:right">
            <p>Filed: <?= date('M d, Y H:i', strtotime($r['created_at'])) ?></p>
            <?php if ($r['reported_by']): ?><p>By: @<?= htmlspecialchars($r['reported_by']) ?></p><?php endif; ?>
            <?php if ($r['reviewed_by']): ?><p>Reviewed by: @<?= htmlspecialchars($r['reviewed_by']) ?></p><?php endif; ?>
          </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Reason / Signals Detected</p>
            <p style="font-size:var(--fs-label-md)"><?= htmlspecialchars($r['signals_detected']) ?></p>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Seller</p>
            <p style="font-weight:600">@<?= htmlspecialchars($r['seller_name'] ?? 'N/A') ?><?= !empty($r['shop_name']) ? ' (' . htmlspecialchars($r['shop_name']) . ')' : '' ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $r['offense_count'] ?? 0 ?> prior offense<?= ($r['offense_count'] ?? 0)!=1?'s':'' ?></p>
          </div>
        </div>

        <?php if ($r['status'] === 'Pending'): ?>
        <form method="POST" class="flex flex-wrap gap-3">
          <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
          <input type="hidden" name="fraud_flag_id" value="<?= $r['fraud_flag_id'] ?>">
          <button type="submit" name="action" value="takedown" class="btn btn-primary btn-sm" onclick="return confirm('Uphold this report? The listing will be taken down and the seller penalized.')">
            <span class="material-symbols-outlined icon-sm">block</span>Uphold &amp; Take Down
          </button>
          <button type="submit" name="action" value="dismiss" class="btn btn-ghost btn-sm" onclick="return confirm('Dismiss this report? No action will be taken.')">
            <span class="material-symbols-outlined icon-sm">cancel</span>Dismiss
          </button>
        </form>
        <?php endif; ?>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>

</div>
</main>
</div>
</body></html>