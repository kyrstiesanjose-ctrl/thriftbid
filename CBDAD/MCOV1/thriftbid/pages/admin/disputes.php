<?php
// pages/admin/disputes.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole(['admin','moderator'],'/pages/login.php');

$successMsg = '';
// Handle resolve/reject
if ($_SERVER['REQUEST_METHOD']==='POST') {
    $did    = (int)$_POST['dispute_id'];
    $action = $_POST['action'] ?? '';
    if ($did && in_array($action,['resolve','reject'])) {
        $status = $action==='resolve' ? 'Resolved' : 'Rejected';
        DB::query('UPDATE DISPUTES SET status=?,resolved_at=NOW() WHERE dispute_id=?',[$status,$did]);
        if ($action==='resolve') {
            // Trigger refund notification to buyer
            $d = DB::fetch('SELECT d.*,b.user_id as buyer_uid,o.seller_id FROM DISPUTES d JOIN BUYER by2 ON d.buyer_id=by2.buyer_id JOIN USERS b ON by2.user_id=b.user_id JOIN ORDERS o ON d.order_id=o.order_id WHERE d.dispute_id=?',[$did]);
            if ($d) {
                DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
                    [$d['buyer_uid'],'Dispute Resolved — Refund Issued','Your dispute #'.$did.' has been resolved. A refund will be processed within 24 hours.','ORDER']);
                // Wallet refund record
                DB::query('INSERT INTO WALLET_TRANSACTIONS (user_id,amount,transaction_type,status) SELECT buyer_uid_col,0,"Refund","Pending" FROM (SELECT ? as buyer_uid_col) t',[$d['buyer_uid']]);
                // Penalise seller (offense tracking)
                DB::query('UPDATE SELLER SET offense_count=offense_count+1 WHERE seller_id=(SELECT seller_id FROM ORDERS WHERE order_id=?)',[$d['order_id']]);
                DB::query('INSERT INTO PENALTIES (seller_id,reason,status) SELECT seller_id,"Dispute resolved against seller: Refund issued","Active" FROM ORDERS WHERE order_id=?',[$d['order_id']]);
            }
        }
        $successMsg = 'Dispute #'.$did.' marked as '.$status.'.';
    }
}

$filter = $_GET['status'] ?? 'Open';
$disputes = DB::fetchAll(
    'SELECT d.*,o.order_id,l.title,
            ub.username as buyer_name,ub.email as buyer_email,
            us.username as seller_name
     FROM DISPUTES d
     JOIN ORDERS o   ON d.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER b2   ON d.buyer_id=b2.buyer_id
     JOIN USERS ub   ON b2.user_id=ub.user_id
     JOIN SELLER s2  ON d.seller_id=s2.seller_id
     JOIN USERS us   ON s2.user_id=us.user_id
     WHERE d.status=?
     ORDER BY d.opened_at DESC',
    [$filter]
);

renderHead('Disputes');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('disputes'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('disputes'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Dispute Management</h1>
  <p class="tb-page-subtitle mb-6">Review buyer-seller disputes and issue resolutions.</p>

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>

  <!-- Filter tabs -->
  <div class="tb-tabs mb-6">
    <?php foreach(['Open','Resolved','Rejected'] as $s): ?>
    <a href="?status=<?= $s ?>" class="tb-tab-link <?= $filter===$s?'active':'' ?>"><?= $s ?></a>
    <?php endforeach; ?>
  </div>

  <?php if (empty($disputes)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">gavel</span>
    No <?= strtolower($filter) ?> disputes.
  </div>
  <?php else: ?>
  <div class="flex flex-col gap-5">
    <?php foreach ($disputes as $d): ?>
    <div class="tb-card">
      <div class="tb-card-body">
        <div class="flex flex-wrap justify-between gap-4 mb-4">
          <div>
            <div class="flex items-center gap-2 mb-1">
              <span class="tb-badge <?= $d['status']==='Open'?'tb-badge-red':($d['status']==='Resolved'?'tb-badge-green':'tb-badge-gray') ?>"><?= $d['status'] ?></span>
              <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">#<?= $d['dispute_id'] ?> &bull; Order #<?= $d['order_id'] ?></span>
            </div>
            <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($d['title']) ?></h3>
          </div>
          <div style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);text-align:right">
            <p>Opened: <?= date('M d, Y H:i', strtotime($d['opened_at'])) ?></p>
            <?php if ($d['resolved_at']): ?><p>Resolved: <?= date('M d, Y', strtotime($d['resolved_at'])) ?></p><?php endif; ?>
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
            <p style="font-weight:600">@<?= htmlspecialchars($d['seller_name']) ?></p>
          </div>
          <div style="padding:12px;background:var(--clr-surface-low);border-radius:var(--radius-lg)">
            <p class="tb-section-label" style="font-size:10px">Reason</p>
            <p style="font-size:var(--fs-label-md)"><?= htmlspecialchars($d['reason']) ?></p>
          </div>
        </div>
        <?php if ($d['status']==='Open'): ?>
        <div class="flex gap-3">
          <form method="POST">
            <input type="hidden" name="dispute_id" value="<?= $d['dispute_id'] ?>">
            <input type="hidden" name="action" value="resolve">
            <button type="submit" class="btn btn-primary btn-sm" onclick="return confirm('Resolve and issue refund to buyer?')">
              <span class="material-symbols-outlined icon-sm">check_circle</span>Resolve (Refund Buyer)
            </button>
          </form>
          <form method="POST">
            <input type="hidden" name="dispute_id" value="<?= $d['dispute_id'] ?>">
            <input type="hidden" name="action" value="reject">
            <button type="submit" class="btn btn-ghost btn-sm" onclick="return confirm('Reject this dispute?')">
              <span class="material-symbols-outlined icon-sm">cancel</span>Reject
            </button>
          </form>
        </div>
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
