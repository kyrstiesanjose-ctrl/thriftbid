<?php
// pages/admin/moderation.php
// Interface for managing order disputes and listing reports.
// Consolidates both workflows into a single page with toggled views to streamline admin review.
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole(['admin']);

$admin   = currentUser();
$adminId = $admin['admin_id'] ?? $admin['id'];

$view = in_array($_GET['view'] ?? 'disputes', ['disputes','reports'], true) ? ($_GET['view'] ?? 'disputes') : 'disputes';

$successMsg = $errorMsg = '';

// ------------------------------------------------------------
// Dispute actions
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD']==='POST' && verifyCsrf($_POST['csrf'] ?? '') && isset($_POST['dispute_id'])) {
    $did            = (int)$_POST['dispute_id'];
    $action         = $_POST['action'] ?? '';
    $resolutionType = $_POST['resolution_type'] ?? 'Full Refund';
    $penalizeSeller = isset($_POST['penalize_seller']);

    $d = DB::fetch(
        'SELECT d.*, o.seller_id, o.buyer_id, o.order_id
         FROM DISPUTES d JOIN ORDERS o ON d.order_id=o.order_id
         WHERE d.dispute_id=?', [$did]
    );

    if (!$d) {
        $errorMsg = 'Dispute not found.';
    } elseif ($d['status'] !== 'Open' && $d['status'] !== 'Under Review') {
        $errorMsg = 'This dispute has already been closed.';
    } elseif ($action === 'resolve') {
        DB::query(
            'UPDATE DISPUTES SET status="Resolved", resolution_type=?, assigned_admin_id=?, resolved_at=NOW() WHERE dispute_id=?',
            [$resolutionType, $adminId, $did]
        );
        DB::query('INSERT INTO NOTIFICATIONS (buyer_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$d['buyer_id'], 'Dispute Resolved - ' . $resolutionType,
             'Your dispute #' . $did . ' has been resolved (' . strtolower($resolutionType) . '). Your refund will be processed within 24 hours.', 'ORDER']);
        if ($penalizeSeller) {
            DB::query('INSERT INTO PENALTIES (seller_id, reason, penalty_type) VALUES (?,?,?)',
                [$d['seller_id'], 'Dispute #' . $did . ' resolved against seller: ' . $d['reason'], 'Selling Suspension']);
        }
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Resolved dispute (' . $resolutionType . ($penalizeSeller?', seller penalized':'') . ')', 'DISPUTES', $did, $d['status'], 'Resolved']);
        $successMsg = 'Dispute #' . $did . ' resolved (' . $resolutionType . ').';
    } elseif ($action === 'reject') {
        DB::query('UPDATE DISPUTES SET status="Rejected", assigned_admin_id=?, resolved_at=NOW() WHERE dispute_id=?', [$adminId, $did]);
        DB::query('INSERT INTO NOTIFICATIONS (buyer_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$d['buyer_id'], 'Dispute Rejected', 'Your dispute #' . $did . ' was reviewed and rejected - no policy violation was found.', 'ORDER']);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Rejected dispute', 'DISPUTES', $did, $d['status'], 'Rejected']);
        $successMsg = 'Dispute #' . $did . ' rejected.';
    }
}

// ------------------------------------------------------------
// Listing report actions
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '') && isset($_POST['fraud_flag_id'])) {
    $flagId = (int)$_POST['fraud_flag_id'];
    $action = $_POST['action'] ?? '';
    $flag = DB::fetch('SELECT * FROM FRAUD_FLAGS WHERE fraud_flag_id=?', [$flagId]);

    if (!$flag) {
        $errorMsg = 'Report not found.';
    } elseif ($flag['status'] !== 'Pending') {
        $errorMsg = 'This report has already been reviewed.';
    } elseif ($action === 'takedown') {
        if ($flag['listing_id']) DB::query('UPDATE LISTINGS SET is_active=0 WHERE listing_id=?', [$flag['listing_id']]);
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

// ------------------------------------------------------------
// Data for whichever view is active
// ------------------------------------------------------------
$openDisputesCount = DB::fetch("SELECT COUNT(*) c FROM DISPUTES WHERE status='Open'")['c'] ?? 0;
$pendingReportsCount = DB::fetch("SELECT COUNT(*) c FROM FRAUD_FLAGS WHERE status='Pending'")['c'] ?? 0;

if ($view === 'disputes') {
    $filter = $_GET['status'] ?? 'Open';
    $validFilters = ['Open','Under Review','Resolved','Rejected'];
    if (!in_array($filter, $validFilters, true)) $filter = 'Open';

    $dateFrom = trim($_GET['from'] ?? '');
    $dateTo   = trim($_GET['to'] ?? '');
    $dateSql  = ''; $dateParams = [];
    if ($dateFrom) { $dateSql .= ' AND d.opened_at >= ?'; $dateParams[] = $dateFrom . ' 00:00:00'; }
    if ($dateTo)   { $dateSql .= ' AND d.opened_at <= ?'; $dateParams[] = $dateTo . ' 23:59:59'; }

    $disputes = DB::fetchAll(
        "SELECT d.*, o.order_id, l.title, l.listing_id,
                bu.username AS buyer_name, bu.email AS buyer_email,
                se.username AS seller_name, se.shop_name, se.offense_count,
                admn.username AS handled_by
         FROM DISPUTES d
         JOIN ORDERS o    ON d.order_id=o.order_id
         JOIN LISTINGS l  ON o.listing_id=l.listing_id
         JOIN BUYER bu    ON d.buyer_id=bu.buyer_id
         JOIN SELLER se   ON d.seller_id=se.seller_id
         LEFT JOIN ADMIN admn ON d.assigned_admin_id=admn.admin_id
         WHERE d.status=?$dateSql
         ORDER BY d.opened_at ASC",
        array_merge([$filter], $dateParams)
    );

    function groupByDayAsc(array $rows, string $field): array {
        $groups = [];
        foreach ($rows as $row) { $groups[date('F j, Y', strtotime($row[$field]))][] = $row; }
        return $groups;
    }
    $disputesByDate = groupByDayAsc($disputes, 'opened_at');
} else {
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
         ORDER BY f.created_at ASC',
        [$filter]
    );
}

renderHead('Moderation');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('moderation'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('moderation'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Moderation</h1>
  <p class="tb-page-subtitle mb-6">Review buyer-reported problems and take action - order disputes and listing reports, in one place.</p>

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>
  <?php if ($errorMsg): ?><div class="tb-alert tb-alert-error show mb-6"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div><?php endif; ?>

<!-- View toggle distinguishing between order disputes (completed purchases/refunds) and listing reports (fraud/policy flags). -->
  <div style="display:flex;gap:12px;margin-bottom:24px">
    <a href="?view=disputes" style="flex:1;padding:16px 18px;border-radius:var(--radius-lg);border:1px solid var(--clr-outline);text-decoration:none;color:inherit;background:<?= $view==='disputes'?'var(--clr-surface-low)':'var(--clr-white)' ?>;border-color:<?= $view==='disputes'?'var(--clr-coral)':'var(--clr-outline)' ?>">
      <div style="display:flex;align-items:center;gap:10px">
        <span class="material-symbols-outlined" style="color:var(--clr-coral)">gavel</span>
        <div>
          <p style="font-weight:700">Order Disputes<?= $openDisputesCount ? ' ('.$openDisputesCount.' open)' : '' ?></p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Buyer vs. seller conflicts over a completed order - refund decisions.</p>
        </div>
      </div>
    </a>
    <a href="?view=reports" style="flex:1;padding:16px 18px;border-radius:var(--radius-lg);border:1px solid var(--clr-outline);text-decoration:none;color:inherit;background:<?= $view==='reports'?'var(--clr-surface-low)':'var(--clr-white)' ?>;border-color:<?= $view==='reports'?'var(--clr-coral)':'var(--clr-outline)' ?>">
      <div style="display:flex;align-items:center;gap:10px">
        <span class="material-symbols-outlined" style="color:var(--clr-coral)">flag</span>
        <div>
          <p style="font-weight:700">Listing Reports<?= $pendingReportsCount ? ' ('.$pendingReportsCount.' pending)' : '' ?></p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Flags on a listing itself - fraud, counterfeits, policy violations.</p>
        </div>
      </div>
    </a>
  </div>

  <?php if ($view === 'disputes'): ?>

  <div class="tb-tabs mb-6">
    <?php foreach($validFilters as $s): ?>
    <a href="?view=disputes&status=<?= urlencode($s) ?>" class="tb-tab-link <?= $filter===$s?'active':'' ?>"><?= $s ?></a>
    <?php endforeach; ?>
  </div>

  <?php if (empty($disputes)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">gavel</span>
    No <?= strtolower($filter) ?> disputes.
  </div>
  <?php else: foreach ($disputesByDate as $dateLabel => $rows): ?>
  <h3 style="font-size:var(--fs-label-sm);font-weight:800;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin:18px 0 10px;padding-bottom:6px;border-bottom:1px solid var(--clr-outline)">
    <?= htmlspecialchars($dateLabel) ?> <span style="font-weight:500;text-transform:none;letter-spacing:normal">(<?= count($rows) ?>)</span>
  </h3>
  <div class="flex flex-col gap-4" style="margin-bottom:8px">
    <?php foreach ($rows as $d): ?>
    <div class="tb-card">
      <div class="tb-card-body">
        <div class="flex flex-wrap justify-between gap-4 mb-4">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="tb-badge <?= $d['status']==='Open'?'tb-badge-red':($d['status']==='Resolved'?'tb-badge-green':'tb-badge-gray') ?>"><?= $d['status'] ?></span>
              <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">#<?= $d['dispute_id'] ?> &bull; Order #<?= $d['order_id'] ?></span>
            </div>
            <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($d['title']) ?></h3>
            <?php if ($d['handled_by']): ?><p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Handled by <?= htmlspecialchars($d['handled_by']) ?></p><?php endif; ?>
          </div>
          <div style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);text-align:right">
            <p>Opened: <?= date('M d, Y H:i', strtotime($d['opened_at'])) ?></p>
            <?php if ($d['resolved_at']): ?><p>Closed: <?= date('M d, Y', strtotime($d['resolved_at'])) ?></p><?php endif; ?>
            <?php if ($d['resolution_type']): ?><p>Resolution: <strong><?= htmlspecialchars($d['resolution_type']) ?></strong></p><?php endif; ?>
          </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Buyer</p>
            <p style="font-weight:600"><?= htmlspecialchars($d['buyer_name']) ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($d['buyer_email']) ?></p>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Seller</p>
            <p style="font-weight:600"><?= htmlspecialchars($d['seller_name']) ?><?= $d['shop_name'] ? ' ('.htmlspecialchars($d['shop_name']).')' : '' ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $d['offense_count'] ?> prior offense<?= $d['offense_count']!=1?'s':'' ?></p>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Reason</p>
            <p style="font-size:var(--fs-label-md)"><?= htmlspecialchars($d['reason']) ?></p>
            <a href="<?= BASE_URL ?>/pages/customer/listing.php?id=<?= $d['listing_id'] ?>" target="_blank" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View listing &rarr;</a>
          </div>
        </div>
        <?php if (in_array($d['status'], ['Open','Under Review'], true)): ?>
        <form method="POST" class="flex flex-wrap items-end gap-3">
          <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
          <input type="hidden" name="dispute_id" value="<?= $d['dispute_id'] ?>">
          <div>
            <label style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">If resolving in buyer's favor</label>
            <select name="resolution_type" class="tb-input" style="width:auto">
              <option value="Full Refund">Full Refund</option>
              <option value="Partial Refund">Partial Refund</option>
            </select>
          </div>
          <label class="flex items-center gap-2" style="font-size:var(--fs-label-sm)">
            <input type="checkbox" name="penalize_seller" value="1"> Issue penalty to seller
          </label>
          <button type="submit" name="action" value="resolve" class="btn btn-primary btn-sm" onclick="return confirm('Resolve in the buyer\'s favor and issue a refund?')">Approve &amp; Resolve</button>
          <button type="submit" name="action" value="reject" class="btn btn-ghost btn-sm" onclick="return confirm('Reject this dispute?')">Reject</button>
        </form>
        <?php endif; ?>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endforeach; endif; ?>

  <?php else: /* view === reports */ ?>

  <div class="tb-tabs mb-6">
    <?php foreach ($validFilters as $s): ?>
    <a href="?view=reports&status=<?= $s ?>" class="tb-tab-link <?= $filter===$s?'active':'' ?>"><?= $s ?></a>
    <?php endforeach; ?>
  </div>

  <?php if (empty($reports)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">flag</span>
    No <?= strtolower($filter) ?> reports.
  </div>
  <?php else: ?>
  <div class="flex flex-col gap-4">
    <?php foreach ($reports as $r): ?>
    <div class="tb-card">
      <div class="tb-card-body">
        <div class="flex flex-wrap justify-between gap-4 mb-4">
          <div class="flex gap-3">
            <?php if ($r['cover_image']): ?><img src="<?= htmlspecialchars($r['cover_image']) ?>" style="width:52px;height:52px;object-fit:cover;border-radius:8px"><?php endif; ?>
            <div>
              <div class="flex items-center gap-2 mb-1">
                <span class="tb-badge <?= $r['status']==='Pending'?'tb-badge-red':'tb-badge-gray' ?>"><?= $r['status'] ?></span>
                <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Report #<?= $r['fraud_flag_id'] ?></span>
              </div>
              <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($r['title'] ?? 'Listing removed') ?></h3>
              <?php if ($r['listing_id']): ?><a href="<?= BASE_URL ?>/pages/customer/listing.php?id=<?= $r['listing_id'] ?>" target="_blank" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View listing &rarr;</a><?php endif; ?>
            </div>
          </div>
          <div style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);text-align:right">
            <p>Filed: <?= date('M d, Y H:i', strtotime($r['created_at'])) ?></p>
            <?php if ($r['reported_by']): ?><p>By: <?= htmlspecialchars($r['reported_by']) ?></p><?php endif; ?>
            <?php if ($r['reviewed_by']): ?><p>Reviewed by: <?= htmlspecialchars($r['reviewed_by']) ?></p><?php endif; ?>
          </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Reason / Signals Detected</p>
            <p style="font-size:var(--fs-label-md)"><?= htmlspecialchars($r['signals_detected']) ?></p>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Seller</p>
            <p style="font-weight:600"><?= htmlspecialchars($r['seller_name'] ?? 'N/A') ?><?= !empty($r['shop_name']) ? ' ('.htmlspecialchars($r['shop_name']).')' : '' ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $r['offense_count'] ?? 0 ?> prior offense<?= ($r['offense_count'] ?? 0)!=1?'s':'' ?></p>
          </div>
        </div>
        <?php if ($r['status'] === 'Pending'): ?>
        <form method="POST" class="flex flex-wrap gap-3">
          <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
          <input type="hidden" name="fraud_flag_id" value="<?= $r['fraud_flag_id'] ?>">
          <button type="submit" name="action" value="takedown" class="btn btn-primary btn-sm" onclick="return confirm('Uphold this report? The listing will be taken down and the seller penalized.')">Uphold &amp; Take Down</button>
          <button type="submit" name="action" value="dismiss" class="btn btn-ghost btn-sm" onclick="return confirm('Dismiss this report?')">Dismiss</button>
        </form>
        <?php endif; ?>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>

  <?php endif; ?>

</div>
</main>
</div>
</body></html>