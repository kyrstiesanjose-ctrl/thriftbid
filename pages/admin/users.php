<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin();
requireRole('admin');

$admin   = currentUser();
$adminId = $admin['admin_id'] ?? $admin['id'];

$requestedTab = $_GET['tab'] ?? 'sellers';
$tab     = in_array($requestedTab, ['sellers','buyers'], true) ? $requestedTab : 'sellers';
$search  = trim($_GET['search'] ?? '');
$page    = max(1, (int)($_GET['page'] ?? 1));
$perPage = 20;
$offset  = ($page - 1) * $perPage;

$table    = $tab === 'sellers' ? 'SELLER' : 'BUYER';
$idCol    = $tab === 'sellers' ? 'seller_id' : 'buyer_id';
$statusCol= $tab === 'sellers' ? 'seller_status' : 'buyer_status';

// ------------------------------------------------------------
// Actions
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    $id     = (int)($_POST['id'] ?? 0);
    $actTable = $_POST['table'] === 'BUYER' ? 'BUYER' : 'SELLER';
    $actIdCol = $actTable === 'SELLER' ? 'seller_id' : 'buyer_id';
    $actStatusCol = $actTable === 'SELLER' ? 'seller_status' : 'buyer_status';

    if ($id && $action === 'verify') {
        DB::query("UPDATE $actTable SET is_verified=1 WHERE $actIdCol=?", [$id]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Verified account', $actTable, $id, '0', '1']);
    } elseif ($id && $action === 'unverify') {
        DB::query("UPDATE $actTable SET is_verified=0 WHERE $actIdCol=?", [$id]);
    } elseif ($id && $action === 'suspend') {
        DB::query("UPDATE $actTable SET $actStatusCol='Suspended' WHERE $actIdCol=?", [$id]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Suspended account', $actTable, $id, 'Active', 'Suspended']);
    } elseif ($id && $action === 'ban') {
        DB::query("UPDATE $actTable SET $actStatusCol='Banned' WHERE $actIdCol=?", [$id]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Banned account', $actTable, $id, null, 'Banned']);
    } elseif ($id && $action === 'reactivate') {
        DB::query("UPDATE $actTable SET $actStatusCol='Active' WHERE $actIdCol=?", [$id]);
        DB::query('INSERT INTO AUDIT_LOGS (admin_id, action_taken, table_affected, record_id, old_value, new_value) VALUES (?,?,?,?,?,?)',
            [$adminId, 'Reactivated account', $actTable, $id, null, 'Active']);
    }
    header('Location: ' . BASE_URL . '/pages/admin/users.php?tab=' . $tab . ($search ? '&search=' . urlencode($search) : ''));
    exit;
}

$where  = '1=1';
$params = [];
if ($search) {
    $where   .= ' AND (username LIKE ? OR email LIKE ?)';
    $params[] = "%$search%"; $params[] = "%$search%";
}

$total = DB::fetch("SELECT COUNT(*) c FROM $table WHERE $where", $params)['c'] ?? 0;
$extraCols = $tab === 'sellers' ? ', offense_count, wallet_frozen_until, ig_follower_count' : '';
$users = DB::fetchAll(
    "SELECT $idCol AS id, username, email, cellphone_number, is_verified, $statusCol AS status, created_at $extraCols
     FROM $table WHERE $where ORDER BY created_at DESC LIMIT $perPage OFFSET $offset",
    $params
);
$totalPages = max(1, ceil($total / $perPage));

$sellerCount = DB::fetch('SELECT COUNT(*) c FROM SELLER')['c'] ?? 0;
$buyerCount  = DB::fetch('SELECT COUNT(*) c FROM BUYER')['c'] ?? 0;

renderHead('User Management');
?>
<body class="flex flex-col h-screen overflow-hidden">
<?php renderNavbar('users'); ?>

<div class="flex flex-1 w-full overflow-hidden">
<?php renderAdminSidebar('users'); ?>

<main class="flex-1 overflow-auto bg-background">
  <div class="p-8 max-w-[1100px] mx-auto space-y-6">

    <header class="flex flex-col md:flex-row md:items-center justify-between gap-4 py-4">
      <div>
        <h1 class="text-3xl font-bold text-on-surface" style="font-family:'Hanken Grotesk',sans-serif">User Management</h1>
        <p class="text-tertiary text-sm mt-1"><?= number_format($sellerCount + $buyerCount) ?> total accounts</p>
      </div>
    </header>

    <div class="tb-tabs">
      <a href="?tab=sellers" class="tb-tab-link <?= $tab==='sellers'?'active':'' ?>">Sellers (<?= $sellerCount ?>)</a>
      <a href="?tab=buyers" class="tb-tab-link <?= $tab==='buyers'?'active':'' ?>">Buyers (<?= $buyerCount ?>)</a>
    </div>

    <div class="flex flex-wrap gap-3 items-center">
      <form method="GET" class="flex gap-2 flex-1 min-w-[260px]">
        <input type="hidden" name="tab" value="<?= $tab ?>">
        <div class="relative flex-1">
          <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-tertiary">search</span>
          <input class="w-full pl-10 pr-4 py-2.5 border border-outline-variant rounded-lg text-sm" type="text" name="search" placeholder="Search by name or email..." value="<?= htmlspecialchars($search) ?>">
        </div>
        <button type="submit" class="btn btn-primary px-5 py-2.5 rounded-lg text-sm font-bold">Search</button>
      </form>
    </div>

    <div class="bg-white border border-outline-variant rounded-xl overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-surface-container">
            <tr>
              <th class="px-5 py-3 text-left text-xs font-bold text-tertiary uppercase tracking-wider">User</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-tertiary uppercase tracking-wider">Status</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-tertiary uppercase tracking-wider">Verified</th>
              <?php if ($tab==='sellers'): ?><th class="px-5 py-3 text-left text-xs font-bold text-tertiary uppercase tracking-wider">Offenses</th><?php endif; ?>
              <th class="px-5 py-3 text-left text-xs font-bold text-tertiary uppercase tracking-wider">Phone</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-tertiary uppercase tracking-wider">Joined</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-tertiary uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-outline-variant">
            <?php if (empty($users)): ?>
            <tr><td colspan="7" class="px-5 py-12 text-center text-tertiary">No users found.</td></tr>
            <?php else: foreach ($users as $u): ?>
            <tr class="hover:bg-surface-container transition-colors">
              <td class="px-5 py-3">
                <p class="font-semibold text-on-surface"><?= htmlspecialchars($u['username']) ?></p>
                <p class="text-xs text-tertiary"><?= htmlspecialchars($u['email']) ?></p>
              </td>
              <td class="px-5 py-3">
                <span class="px-2 py-0.5 rounded text-xs font-bold <?= match($u['status']) {
                  'Banned' => 'bg-red-100 text-red-700',
                  'Suspended' => 'bg-yellow-50 text-yellow-700',
                  default => 'bg-green-50 text-green-700',
                } ?>"><?= $u['status'] ?></span>
                <?php if ($tab==='sellers' && $u['wallet_frozen_until'] && strtotime($u['wallet_frozen_until']) > time()): ?>
                <p class="text-xs text-thrift-coral mt-1">Wallet frozen till <?= date('M d', strtotime($u['wallet_frozen_until'])) ?></p>
                <?php endif; ?>
              </td>
              <td class="px-5 py-3">
                <?php if ($u['is_verified']): ?>
                <span class="inline-flex items-center gap-1 text-xs text-green-600 font-medium"><span class="material-symbols-outlined text-sm filled">check_circle</span>Verified</span>
                <?php else: ?>
                <span class="inline-flex items-center gap-1 text-xs text-thrift-coral font-medium"><span class="material-symbols-outlined text-sm">cancel</span>Unverified</span>
                <?php endif; ?>
              </td>
              <?php if ($tab==='sellers'): ?>
              <td class="px-5 py-3">
                <span class="px-2 py-0.5 rounded text-xs font-bold <?= $u['offense_count']>=2?'bg-red-100 text-red-700':($u['offense_count']==1?'bg-yellow-50 text-yellow-700':'bg-surface-container text-tertiary') ?>"><?= $u['offense_count'] ?></span>
              </td>
              <?php endif; ?>
              <td class="px-5 py-3 text-xs text-tertiary"><?= htmlspecialchars($u['cellphone_number'] ?? '—') ?></td>
              <td class="px-5 py-3 text-xs text-tertiary"><?= date('M d, Y', strtotime($u['created_at'])) ?></td>
              <td class="px-5 py-3">
                <div class="flex items-center gap-3 flex-wrap">
                  <?php $tbl = $tab==='sellers'?'SELLER':'BUYER'; ?>
                  <?php if (!$u['is_verified']): ?>
                  <form method="POST"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="verify"><input type="hidden" name="id" value="<?= $u['id'] ?>"><input type="hidden" name="table" value="<?= $tbl ?>">
                    <button type="submit" class="text-xs text-tertiary font-semibold hover:text-on-surface hover:underline">Verify</button>
                  </form>
                  <?php else: ?>
                  <form method="POST"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="unverify"><input type="hidden" name="id" value="<?= $u['id'] ?>"><input type="hidden" name="table" value="<?= $tbl ?>">
                    <button type="submit" class="text-xs text-tertiary font-semibold hover:text-on-surface hover:underline">Unverify</button>
                  </form>
                  <?php endif; ?>

                  <?php if ($u['status'] === 'Active'): ?>
                  <form method="POST" onsubmit="return confirm('Suspend this account?')"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="suspend"><input type="hidden" name="id" value="<?= $u['id'] ?>"><input type="hidden" name="table" value="<?= $tbl ?>">
                    <button type="submit" class="text-xs text-tertiary font-semibold hover:text-on-surface hover:underline">Suspend</button>
                  </form>
                  <form method="POST" onsubmit="return confirm('Permanently ban this account?')"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="ban"><input type="hidden" name="id" value="<?= $u['id'] ?>"><input type="hidden" name="table" value="<?= $tbl ?>">
                    <button type="submit" class="text-xs text-error font-semibold hover:underline">Ban</button>
                  </form>
                  <?php else: ?>
                  <form method="POST" onsubmit="return confirm('Reactivate this account?')"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="reactivate"><input type="hidden" name="id" value="<?= $u['id'] ?>"><input type="hidden" name="table" value="<?= $tbl ?>">
                    <button type="submit" class="text-xs text-tertiary font-semibold hover:text-on-surface hover:underline">Reactivate</button>
                  </form>
                  <?php endif; ?>
                </div>
              </td>
            </tr>
            <?php endforeach; endif; ?>
          </tbody>
        </table>
      </div>

      <?php if ($totalPages > 1): ?>
      <div class="px-5 py-4 border-t border-outline-variant flex items-center justify-between">
        <p class="text-xs text-tertiary">Page <?= $page ?> of <?= $totalPages ?></p>
        <div class="flex gap-2">
          <?php if ($page > 1): ?><a href="?tab=<?= $tab ?>&page=<?= $page-1 ?>&search=<?= urlencode($search) ?>" class="px-3 py-1.5 border border-outline-variant rounded text-xs hover:bg-surface-container">Previous</a><?php endif; ?>
          <?php if ($page < $totalPages): ?><a href="?tab=<?= $tab ?>&page=<?= $page+1 ?>&search=<?= urlencode($search) ?>" class="px-3 py-1.5 btn-primary rounded text-xs">Next</a><?php endif; ?>
        </div>
      </div>
      <?php endif; ?>
    </div>

    

  </div>
</main>
</div>
</body></html>