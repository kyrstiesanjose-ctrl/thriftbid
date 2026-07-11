<?php
// pages/admin/penalties.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole('admin', '/pages/login.php');

$successMsg = '';

// Handle actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $pid    = (int)($_POST['penalty_id'] ?? 0);
    $sid    = (int)($_POST['seller_id']  ?? 0);

    if ($action === 'expire' && $pid) {
        DB::query('UPDATE PENALTIES SET status="Expired" WHERE penalty_id=?', [$pid]);
        $successMsg = 'Penalty #'.$pid.' marked as expired.';
    } elseif ($action === 'award' && $sid) {
        $reason = trim($_POST['reason'] ?? 'Top Seller Recognition');
        DB::query('INSERT INTO AWARDS (seller_id,reason,status) VALUES (?,"'.$reason.'","Active")', [$sid]);
        $u = DB::fetch('SELECT u.user_id FROM SELLER s JOIN USERS u ON s.user_id=u.user_id WHERE s.seller_id=?',[$sid]);
        if ($u) DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$u['user_id'], 'You Received an Award!', 'Congratulations! You have been awarded: '.$reason, 'SYSTEM']);
        $successMsg = 'Award issued to seller #'.$sid.'.';
    } elseif ($action === 'issue_penalty' && $sid) {
        $reason    = trim($_POST['penalty_reason'] ?? 'Policy violation');
        $periodEnd = date('Y-m-d H:i:s', strtotime('+7 days'));
        DB::query('INSERT INTO PENALTIES (seller_id,reason,status,period_end) VALUES (?,?,"Active",?)', [$sid,$reason,$periodEnd]);
        DB::query('UPDATE SELLER SET offense_count=offense_count+1 WHERE seller_id=?', [$sid]);
        $u = DB::fetch('SELECT u.user_id FROM SELLER s JOIN USERS u ON s.user_id=u.user_id WHERE s.seller_id=?',[$sid]);
        if ($u) DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$u['user_id'], 'Penalty Issued', 'A penalty has been issued to your account: '.$reason.'. Please review platform policies.', 'SYSTEM']);
        $successMsg = 'Penalty issued.';
    }
    header('Location: /pages/admin/penalties.php' . ($successMsg ? '?ok=1' : ''));
    exit;
}
if (isset($_GET['ok'])) $successMsg = 'Action completed successfully.';

$penalties = DB::fetchAll(
    'SELECT p.*,u.username as seller_name,u.user_id,s.offense_count
     FROM PENALTIES p
     JOIN SELLER s ON p.seller_id=s.seller_id
     JOIN USERS u  ON s.user_id=u.user_id
     ORDER BY p.issued_at DESC'
);
$awards = DB::fetchAll(
    'SELECT a.*,u.username as seller_name
     FROM AWARDS a
     JOIN SELLER s ON a.seller_id=s.seller_id
     JOIN USERS u  ON s.user_id=u.user_id
     ORDER BY a.issued_at DESC LIMIT 30'
);
$sellers = DB::fetchAll(
    'SELECT s.seller_id,u.username,s.offense_count FROM SELLER s JOIN USERS u ON s.user_id=u.user_id ORDER BY u.username'
);

renderHead('Penalties & Awards');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('home'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('penalties'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Penalties &amp; Awards</h1>
  <p class="tb-page-subtitle mb-8">Manage seller violations and recognize top performers.</p>

  <?php if ($successMsg): ?>
  <div class="tb-alert tb-alert-success show mb-6">
    <span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?>
  </div>
  <?php endif; ?>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

    <!-- Issue Penalty / Award -->
    <div class="lg:col-span-1 flex flex-col gap-5">

      <!-- Issue Penalty -->
      <div class="tb-card">
        <div class="tb-card-header">
          <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Issue Penalty</h3>
        </div>
        <div class="tb-card-body">
          <form method="POST" class="flex flex-col gap-3">
            <input type="hidden" name="action" value="issue_penalty">
            <div>
              <label class="tb-label">Seller</label>
              <select name="seller_id" class="tb-select" required>
                <option value="">Select seller...</option>
                <?php foreach ($sellers as $s): ?>
                <option value="<?= $s['seller_id'] ?>">@<?= htmlspecialchars($s['username']) ?> (<?= $s['offense_count'] ?> offenses)</option>
                <?php endforeach; ?>
              </select>
            </div>
            <div>
              <label class="tb-label">Reason</label>
              <input type="text" name="penalty_reason" class="tb-input" placeholder="e.g. Late shipment violation" required>
            </div>
            <button type="submit" class="btn btn-danger btn-sm">
              <span class="material-symbols-outlined icon-sm">block</span>Issue Penalty
            </button>
          </form>
        </div>
      </div>

      <!-- Issue Award -->
      <div class="tb-card">
        <div class="tb-card-header">
          <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Issue Award</h3>
        </div>
        <div class="tb-card-body">
          <form method="POST" class="flex flex-col gap-3">
            <input type="hidden" name="action" value="award">
            <div>
              <label class="tb-label">Seller</label>
              <select name="seller_id" class="tb-select" required>
                <option value="">Select seller...</option>
                <?php foreach ($sellers as $s): ?>
                <option value="<?= $s['seller_id'] ?>">@<?= htmlspecialchars($s['username']) ?></option>
                <?php endforeach; ?>
              </select>
            </div>
            <div>
              <label class="tb-label">Award Reason</label>
              <input type="text" name="reason" class="tb-input" placeholder="e.g. Top Seller of the Month" required>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">
              <span class="material-symbols-outlined icon-sm">star</span>Give Award
            </button>
          </form>
        </div>
      </div>

    </div>

    <!-- Penalties + Awards tables -->
    <div class="lg:col-span-2 flex flex-col gap-6">

      <!-- Penalties list -->
      <div class="tb-card">
        <div class="tb-card-header">
          <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Penalty Records</h3>
          <span class="tb-badge tb-badge-gray"><?= count($penalties) ?> total</span>
        </div>
        <?php if (empty($penalties)): ?>
        <div class="tb-card-body text-center" style="color:var(--clr-tertiary)">No penalties on record.</div>
        <?php else: ?>
        <div class="overflow-x-auto">
          <table class="tb-table">
            <thead><tr>
              <th>Seller</th><th>Offenses</th><th>Reason</th><th>Status</th><th>Issued</th><th>Expires</th><th>Action</th>
            </tr></thead>
            <tbody>
              <?php foreach ($penalties as $p): ?>
              <tr>
                <td style="font-weight:600">@<?= htmlspecialchars($p['seller_name']) ?></td>
                <td>
                  <span class="tb-badge <?= $p['offense_count']>=3?'tb-badge-red':($p['offense_count']>=2?'tb-badge-yellow':'tb-badge-gray') ?>">
                    <?= $p['offense_count'] ?> offense<?= $p['offense_count']!==1?'s':'' ?>
                  </span>
                </td>
                <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--clr-tertiary)"><?= htmlspecialchars($p['reason']) ?></td>
                <td>
                  <span class="tb-badge <?= $p['status']==='Active'?'tb-badge-red':($p['status']==='Served'?'tb-badge-green':'tb-badge-gray') ?>">
                    <?= $p['status'] ?>
                  </span>
                </td>
                <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($p['issued_at'])) ?></td>
                <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $p['period_end'] ? date('M d, Y', strtotime($p['period_end'])) : 'Indefinite' ?></td>
                <td>
                  <?php if ($p['status'] === 'Active'): ?>
                  <form method="POST">
                    <input type="hidden" name="action" value="expire">
                    <input type="hidden" name="penalty_id" value="<?= $p['penalty_id'] ?>">
                    <button type="submit" class="btn btn-ghost btn-sm">Mark Expired</button>
                  </form>
                  <?php endif; ?>
                </td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
        <?php endif; ?>
      </div>

      <!-- Awards list -->
      <div class="tb-card">
        <div class="tb-card-header">
          <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Award Records</h3>
          <span class="tb-badge tb-badge-yellow"><?= count($awards) ?> awards</span>
        </div>
        <?php if (empty($awards)): ?>
        <div class="tb-card-body text-center" style="color:var(--clr-tertiary)">No awards issued yet.</div>
        <?php else: ?>
        <div class="overflow-x-auto">
          <table class="tb-table">
            <thead><tr><th>Seller</th><th>Reason</th><th>Status</th><th>Issued</th><th>Expires</th></tr></thead>
            <tbody>
              <?php foreach ($awards as $a): ?>
              <tr>
                <td style="font-weight:600">@<?= htmlspecialchars($a['seller_name']) ?></td>
                <td style="color:var(--clr-tertiary)"><?= htmlspecialchars($a['reason']) ?></td>
                <td><span class="tb-badge <?= $a['status']==='Active'?'tb-badge-yellow':'tb-badge-gray' ?>"><?= $a['status'] ?></span></td>
                <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($a['issued_at'])) ?></td>
                <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $a['period_end'] ? date('M d, Y', strtotime($a['period_end'])) : '—' ?></td>
              </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
        <?php endif; ?>
      </div>

    </div>
  </div>

</div>
</main>
</div>
</body></html>
