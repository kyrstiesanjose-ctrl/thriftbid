<?php
// pages/admin/disputes.php
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
// Handle resolve / reject
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD']==='POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $did            = (int)($_POST['dispute_id'] ?? 0);
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
            [$d['buyer_id'], 'Dispute Resolved — ' . $resolutionType,
             'Your dispute #' . $did . ' has been resolved (' . strtolower($resolutionType) . '). Your refund will be processed within 24 hours.', 'ORDER']);

        if ($penalizeSeller) {
            // The after_penalty_insert_escalate trigger automatically increments offense counts and escalates to suspensions or bans.
            DB::query('INSERT INTO PENALTIES (seller_id, reason, penalty_type) VALUES (?,?,?)',
                [$d['seller_id'], 'Dispute #' . $did . ' resolved against seller: ' . $d['reason'], 'Selling Suspension']);
        }

        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Resolved dispute (' . $resolutionType . ($penalizeSeller?', seller penalized':'') . ')', 'DISPUTES', $did, $d['status'], 'Resolved']);

        $successMsg = 'Dispute #' . $did . ' resolved (' . $resolutionType . ').';
    } elseif ($action === 'reject') {
        DB::query('UPDATE DISPUTES SET status="Rejected", assigned_admin_id=?, resolved_at=NOW() WHERE dispute_id=?', [$adminId, $did]);

        DB::query('INSERT INTO NOTIFICATIONS (buyer_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$d['buyer_id'], 'Dispute Rejected', 'Your dispute #' . $did . ' was reviewed and rejected — no policy violation was found.', 'ORDER']);

        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Rejected dispute', 'DISPUTES', $did, $d['status'], 'Rejected']);

        $successMsg = 'Dispute #' . $did . ' rejected.';
    }
}

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

// Oldest-first review queue, grouped by the day the dispute was opened.
function groupDisputesByDate(array $rows): array {
    $groups = [];
    foreach ($rows as $row) {
        $key = date('F j, Y', strtotime($row['opened_at']));
        $groups[$key][] = $row;
    }
    return $groups;
}
$disputesByDate = groupDisputesByDate($disputes);

renderHead('Disputes');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('disputes'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('disputes'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Dispute Management</h1>
  <p class="tb-page-subtitle mb-6">Review buyer-seller disputes over orders and issue resolutions.</p>

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>
  <?php if ($errorMsg): ?><div class="tb-alert tb-alert-error show mb-6"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div><?php endif; ?>

  <!-- Filter tabs -->
  <div class="tb-tabs mb-6">
    <?php foreach($validFilters as $s): ?>
    <a href="?status=<?= urlencode($s) ?>&from=<?= htmlspecialchars($dateFrom) ?>&to=<?= htmlspecialchars($dateTo) ?>" class="tb-tab-link <?= $filter===$s?'active':'' ?>"><?= $s ?></a>
    <?php endforeach; ?>
  </div>

  <form method="GET" class="flex flex-wrap items-end gap-3 mb-6">
    <input type="hidden" name="status" value="<?= htmlspecialchars($filter) ?>">
    <div>
      <label class="tb-label">From</label>
      <input type="date" name="from" value="<?= htmlspecialchars($dateFrom) ?>" class="tb-input">
    </div>
    <div>
      <label class="tb-label">To</label>
      <input type="date" name="to" value="<?= htmlspecialchars($dateTo) ?>" class="tb-input">
    </div>
    <button type="submit" class="btn btn-primary btn-sm">Filter</button>
    <?php if ($dateFrom || $dateTo): ?><a href="?status=<?= urlencode($filter) ?>" class="btn btn-ghost btn-sm">Clear</a><?php endif; ?>
    <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-left:auto">Oldest disputes shown first</span>
  </form>

  <?php if (empty($disputes)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">gavel</span>
    No <?= strtolower($filter) ?> disputes.
  </div>
  <?php else: foreach ($disputesByDate as $dateLabel => $rows): ?>
  <h3 style="font-size:var(--fs-label-sm);font-weight:800;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin:18px 0 10px;padding-bottom:6px;border-bottom:1px solid var(--clr-outline)">
    <?= htmlspecialchars($dateLabel) ?> <span style="font-weight:500;text-transform:none;letter-spacing:normal">(<?= count($rows) ?>)</span>
  </h3>
  <div class="flex flex-col gap-5" style="margin-bottom:8px">
    <?php foreach ($rows as $d): ?>
    <div class="tb-card">
      <div class="tb-card-body">
        <div class="flex flex-wrap justify-between gap-4 mb-4">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="tb-badge <?= $d['status']==='Open'?'tb-badge-red':($d['status']==='Resolved'?'tb-badge-green':($d['status']==='Rejected'?'tb-badge-gray':'tb-badge-coral')) ?>"><?= $d['status'] ?></span>
              <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">#<?= $d['dispute_id'] ?> &bull; Order #<?= $d['order_id'] ?></span>
            </div>
            <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($d['title']) ?></h3>
            <?php if ($d['handled_by']): ?><p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Handled by @<?= htmlspecialchars($d['handled_by']) ?></p><?php endif; ?>
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
            <p style="font-weight:600">@<?= htmlspecialchars($d['buyer_name']) ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($d['buyer_email']) ?></p>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Seller</p>
            <p style="font-weight:600">@<?= htmlspecialchars($d['seller_name']) ?><?= $d['shop_name'] ? ' (' . htmlspecialchars($d['shop_name']) . ')' : '' ?></p>
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
          <button type="submit" name="action" value="resolve" class="btn btn-primary btn-sm" onclick="return confirm('Resolve in the buyer\'s favor and issue a refund?')">
            <span class="material-symbols-outlined icon-sm">check_circle</span>Approve &amp; Resolve
          </button>
          <button type="submit" name="action" value="reject" class="btn btn-ghost btn-sm" onclick="return confirm('Reject this dispute? No refund or penalty will be issued.')">
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