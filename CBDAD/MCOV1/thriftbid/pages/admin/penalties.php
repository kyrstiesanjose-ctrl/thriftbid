<?php
// pages/admin/penalties.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole('admin');

$admin   = currentUser();
$adminId = $admin['admin_id'] ?? $admin['id'];

$successMsg = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    $pid    = (int)($_POST['penalty_id'] ?? 0);
    $sid    = (int)($_POST['seller_id']  ?? 0);

    if ($action === 'expire' && $pid) {
        DB::query('UPDATE PENALTIES SET status="Expired" WHERE penalty_id=?', [$pid]);
        $successMsg = 'Penalty #'.$pid.' marked as expired.';

    } elseif ($action === 'expire_award' && (int)($_POST['award_id'] ?? 0)) {
        $aid = (int)$_POST['award_id'];
        DB::query('UPDATE SELLER_AWARDS SET status="Expired" WHERE award_id=?', [$aid]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Marked award as expired', 'SELLER_AWARDS', $aid, 'Active', 'Expired']);
        $successMsg = 'Award #'.$aid.' marked as expired.';

    } elseif ($action === 'award' && $sid) {
        $reason = trim($_POST['reason'] ?? 'Top Seller Recognition');
        $awardType = $_POST['award_type'] ?? 'Top Seller Badge';

        // after_seller_award_notify trigger sends the notification 
        DB::query('INSERT INTO SELLER_AWARDS (seller_id, reason, award_type, status) VALUES (?,?,?,"Active")',
            [$sid, $reason, $awardType]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Issued award: ' . $reason, 'SELLER_AWARDS', $sid, null, $awardType]);
        $successMsg = 'Award issued.';

    } elseif ($action === 'issue_penalty' && $sid) {
        $reason      = trim($_POST['penalty_reason'] ?? 'Policy violation');
        $penaltyType = $_POST['penalty_type'] ?? 'Selling Suspension';

        // after_penalty_insert_escalate trigger handles offense_count, suspension/ban escalation, and the seller notification 
    
        DB::query('INSERT INTO PENALTIES (seller_id, reason, penalty_type) VALUES (?,?,?)',
            [$sid, $reason, $penaltyType]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Issued penalty: ' . $reason, 'PENALTIES', $sid, null, $penaltyType]);
        $successMsg = 'Penalty issued.';
    }
    header('Location: ' . BASE_URL . '/pages/admin/penalties.php?tab=' . (in_array($_POST['action'], ['award','expire_award'], true)?'rewards':'penalties') . ($successMsg?'&ok=1':''));
    exit;
}
if (isset($_GET['ok'])) $successMsg = 'Action completed successfully.';

$requestedTab = $_GET['tab'] ?? 'penalties';
$tab = in_array($requestedTab, ['penalties','rewards'], true) ? $requestedTab : 'penalties';

$penalties = DB::fetchAll(
    'SELECT p.*, s.username AS seller_name, s.shop_name, s.seller_id, s.offense_count, s.seller_status
     FROM PENALTIES p JOIN SELLER s ON p.seller_id=s.seller_id
     ORDER BY p.issued_at DESC'
);
$awards = DB::fetchAll(
    'SELECT a.*, s.username AS seller_name, s.shop_name
     FROM SELLER_AWARDS a JOIN SELLER s ON a.seller_id=s.seller_id
     ORDER BY a.issued_at DESC LIMIT 30'
);
$sellers = DB::fetchAll('SELECT seller_id, username, offense_count, seller_status FROM SELLER ORDER BY username');

$activePenalties  = count(array_filter($penalties, fn($p)=>$p['status']==='Active'));
$suspendedSellers = count(array_filter($sellers, fn($s)=>$s['seller_status']==='Suspended'));
$bannedSellers    = count(array_filter($sellers, fn($s)=>$s['seller_status']==='Banned'));
$activeAwards     = count(array_filter($awards, fn($a)=>$a['status']==='Active'));

renderHead('Rewards & Penalties');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('home'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('penalties'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Rewards &amp; Penalties</h1>
  <p class="tb-page-subtitle mb-6">Two separate things: penalties enforce policy (offense escalation is automatic), rewards recognize good sellers.</p>

  <?php if ($successMsg): ?>
  <div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div>
  <?php endif; ?>

  <div class="tb-tabs mb-6">
    <a href="?tab=penalties" class="tb-tab-link <?= $tab==='penalties'?'active':'' ?>">Penalties</a>
    <a href="?tab=rewards"   class="tb-tab-link <?= $tab==='rewards'?'active':'' ?>">Rewards</a>
  </div>

  <?php if ($tab === 'penalties'): ?>

  <div class="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined">block</span></div>
      <div><div class="tb-stat-label">Active Penalties</div><div class="tb-stat-value"><?= $activePenalties ?></div></div>
    </div>
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined">pause_circle</span></div>
      <div><div class="tb-stat-label">Suspended Sellers</div><div class="tb-stat-value"><?= $suspendedSellers ?></div></div>
    </div>
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined">no_accounts</span></div>
      <div><div class="tb-stat-label">Banned Sellers</div><div class="tb-stat-value"><?= $bannedSellers ?></div></div>
    </div>
  </div>

  <details class="tb-card mb-6">
    <summary style="cursor:pointer;padding:16px 20px;font-weight:700;list-style:none;display:flex;align-items:center;gap:8px">
      <span class="material-symbols-outlined icon-sm">add_circle</span>Issue a New Penalty
    </summary>
    <div class="tb-card-body" style="border-top:1px solid var(--clr-outline)">
      <form method="POST" class="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
        <input type="hidden" name="action" value="issue_penalty">
        <div>
          <label class="tb-label">Seller</label>
          <select name="seller_id" class="tb-select" required>
            <option value="">Select seller...</option>
            <?php foreach ($sellers as $s): ?>
            <option value="<?= $s['seller_id'] ?>"><?= htmlspecialchars($s['username']) ?> (<?= $s['offense_count'] ?> offenses)</option>
            <?php endforeach; ?>
          </select>
        </div>
        <div>
          <label class="tb-label">Type</label>
          <select name="penalty_type" class="tb-select">
            <option value="Bidding Suspension">Bidding Suspension</option>
            <option value="Selling Suspension">Selling Suspension</option>
            <option value="Wallet Freeze">Wallet Freeze</option>
            <option value="Account Ban">Account Ban</option>
          </select>
        </div>
        <div>
          <label class="tb-label">Reason</label>
          <input type="text" name="penalty_reason" class="tb-input" placeholder="e.g. Late shipment violation" required>
        </div>
        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('This increments the seller\'s offense count and may auto-suspend or auto-ban them. Continue?')">Issue Penalty</button>
      </form>
    </div>
  </details>

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
        <thead><tr><th>Seller</th><th>Account Status</th><th>Offenses</th><th>Type</th><th>Reason</th><th>Penalty Status</th><th>Issued</th><th>Action</th></tr></thead>
        <tbody>
          <?php foreach ($penalties as $p): ?>
          <tr>
            <td style="font-weight:600"><?= htmlspecialchars($p['seller_name']) ?><?= $p['shop_name'] ? ' ('.htmlspecialchars($p['shop_name']).')' : '' ?></td>
            <td><span class="tb-badge <?= $p['seller_status']==='Active'?'tb-badge-green':'tb-badge-red' ?>"><?= $p['seller_status'] ?></span></td>
            <td style="color:var(--clr-tertiary)"><?= $p['offense_count'] ?></td>
            <td style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)"><?= htmlspecialchars($p['penalty_type']) ?></td>
            <td style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--clr-tertiary)"><?= htmlspecialchars($p['reason']) ?></td>
            <td><span class="tb-badge <?= $p['status']==='Active'?'tb-badge-red':'tb-badge-gray' ?>"><?= $p['status'] ?></span></td>
            <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($p['issued_at'])) ?></td>
            <td>
              <?php if ($p['status'] === 'Active'): ?>
              <form method="POST"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="expire"><input type="hidden" name="penalty_id" value="<?= $p['penalty_id'] ?>">
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

  <?php else: /* rewards */ ?>

  <div class="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined">star</span></div>
      <div><div class="tb-stat-label">Active Rewards</div><div class="tb-stat-value"><?= $activeAwards ?></div></div>
    </div>
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined">military_tech</span></div>
      <div><div class="tb-stat-label">Total Issued</div><div class="tb-stat-value"><?= count($awards) ?></div></div>
    </div>
  </div>

  <details class="tb-card mb-6">
    <summary style="cursor:pointer;padding:16px 20px;font-weight:700;list-style:none;display:flex;align-items:center;gap:8px">
      <span class="material-symbols-outlined icon-sm">add_circle</span>Give a New Reward
    </summary>
    <div class="tb-card-body" style="border-top:1px solid var(--clr-outline)">
      <form method="POST" class="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
        <input type="hidden" name="action" value="award">
        <div>
          <label class="tb-label">Seller</label>
          <select name="seller_id" class="tb-select" required>
            <option value="">Select seller...</option>
            <?php foreach ($sellers as $s): ?>
            <option value="<?= $s['seller_id'] ?>"><?= htmlspecialchars($s['username']) ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div>
          <label class="tb-label">Award Type</label>
          <select name="award_type" class="tb-select">
            <option value="Top Seller Badge">Top Seller Badge</option>
            <option value="Fee Discount">Fee Discount</option>
          </select>
        </div>
        <div>
          <label class="tb-label">Reason</label>
          <input type="text" name="reason" class="tb-input" placeholder="e.g. Top Seller of the Month" required>
        </div>
        <button type="submit" class="btn btn-primary btn-sm">Give Award</button>
      </form>
    </div>
  </details>

  <div class="tb-card">
    <div class="tb-card-header">
      <h3 class="font-headline" style="font-size:var(--fs-headline-sm)">Award Records</h3>
      <span class="tb-badge tb-badge-gray"><?= count($awards) ?> total</span>
    </div>
    <?php if (empty($awards)): ?>
    <div class="tb-card-body text-center" style="color:var(--clr-tertiary)">No awards issued yet.</div>
    <?php else: ?>
    <div class="overflow-x-auto">
      <table class="tb-table">
        <thead><tr><th>Seller</th><th>Type</th><th>Reason</th><th>Status</th><th>Issued</th><th>Action</th></tr></thead>
        <tbody>
          <?php foreach ($awards as $a): ?>
          <tr>
            <td style="font-weight:600"><?= htmlspecialchars($a['seller_name']) ?><?= $a['shop_name'] ? ' ('.htmlspecialchars($a['shop_name']).')' : '' ?></td>
            <td style="color:var(--clr-tertiary)"><?= htmlspecialchars($a['award_type']) ?></td>
            <td style="color:var(--clr-tertiary)"><?= htmlspecialchars($a['reason']) ?></td>
            <td><span class="tb-badge <?= $a['status']==='Active'?'tb-badge-green':'tb-badge-gray' ?>"><?= $a['status'] ?></span></td>
            <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($a['issued_at'])) ?></td>
            <td>
              <?php if ($a['status'] === 'Active'): ?>
              <form method="POST"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="expire_award"><input type="hidden" name="award_id" value="<?= $a['award_id'] ?>">
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

  <?php endif; ?>

</div>
</main>
</div>
</body></html>