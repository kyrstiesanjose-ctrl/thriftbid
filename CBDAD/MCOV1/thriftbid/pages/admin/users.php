<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('/pages/login.php');
requireRole('admin', '/pages/login.php');

$search = trim($_GET['search'] ?? '');
$filter = $_GET['role'] ?? 'all';
$page   = max(1, (int)($_GET['page'] ?? 1));
$perPage = 20;
$offset  = ($page - 1) * $perPage;

// Handle actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $uid    = (int)($_POST['user_id'] ?? 0);

    if ($uid && $action === 'verify') {
        DB::query('UPDATE USERS SET is_verified=1 WHERE user_id=?', [$uid]);
    } elseif ($uid && $action === 'suspend') {
        DB::query('UPDATE USERS SET is_verified=0 WHERE user_id=?', [$uid]);
    } elseif ($uid && $action === 'promote_seller') {
        DB::query('UPDATE USERS SET role="seller" WHERE user_id=?', [$uid]);
        DB::query('INSERT IGNORE INTO SELLER (user_id) VALUES (?)', [$uid]);
    }
    header('Location: /pages/admin/users.php' . ($search ? '?search=' . urlencode($search) : ''));
    exit;
}

// Build query
$where  = '1=1';
$params = [];
if ($search) {
    $where  .= ' AND (username LIKE ? OR email LIKE ?)';
    $params  = array_merge($params, ["%$search%", "%$search%"]);
}
if ($filter !== 'all') {
    $where  .= ' AND role = ?';
    $params[] = $filter;
}

$total = DB::fetch("SELECT COUNT(*) c FROM USERS WHERE $where", $params)['c'] ?? 0;
$users = DB::fetchAll("SELECT * FROM USERS WHERE $where ORDER BY created_at DESC LIMIT $perPage OFFSET $offset", $params);
$totalPages = max(1, ceil($total / $perPage));

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
        <p class="text-on-surface-variant text-sm mt-1"><?= number_format($total) ?> total accounts</p>
      </div>
    </header>

    <!-- Filters -->
    <div class="flex flex-wrap gap-3 items-center">
      <form method="GET" class="flex gap-2 flex-1 min-w-[260px]">
        <div class="relative flex-1">
          <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input class="w-full pl-10 pr-4 py-2.5 border border-outline-variant rounded-lg text-sm" type="text" name="search" placeholder="Search by name or email..." value="<?= htmlspecialchars($search) ?>">
        </div>
        <select class="border border-outline-variant rounded-lg px-3 py-2.5 text-sm" name="role" onchange="this.form.submit()">
          <option value="all" <?= $filter==='all'?'selected':'' ?>>All Roles</option>
          <option value="buyer"     <?= $filter==='buyer'?'selected':'' ?>>Buyers</option>
          <option value="seller"    <?= $filter==='seller'?'selected':'' ?>>Sellers</option>
          <option value="moderator" <?= $filter==='moderator'?'selected':'' ?>>Moderators</option>
          <option value="admin"     <?= $filter==='admin'?'selected':'' ?>>Admins</option>
        </select>
        <button type="submit" class="btn btn-primary px-5 py-2.5 rounded-lg text-sm font-bold">Search</button>
      </form>
    </div>

    <!-- Table -->
    <div class="bg-white border border-outline-variant rounded-xl overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-surface-container-low">
            <tr>
              <th class="px-5 py-3 text-left text-xs font-bold text-on-surface-variant uppercase tracking-wider">User</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-on-surface-variant uppercase tracking-wider">Role</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-on-surface-variant uppercase tracking-wider">Status</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-on-surface-variant uppercase tracking-wider">Phone</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-on-surface-variant uppercase tracking-wider">Joined</th>
              <th class="px-5 py-3 text-left text-xs font-bold text-on-surface-variant uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-outline-variant">
            <?php if (empty($users)): ?>
            <tr><td colspan="6" class="px-5 py-12 text-center text-on-surface-variant">No users found.</td></tr>
            <?php else: foreach ($users as $u): ?>
            <tr class="hover:bg-surface-container-lowest transition-colors">
              <td class="px-5 py-3">
                <div>
                  <p class="font-semibold text-on-surface"><?= htmlspecialchars($u['username']) ?></p>
                  <p class="text-xs text-on-surface-variant"><?= htmlspecialchars($u['email']) ?></p>
                </div>
              </td>
              <td class="px-5 py-3">
                <span class="px-2 py-0.5 rounded text-xs font-bold
                  <?= match($u['role']) {
                    'admin'     => 'bg-purple-100 text-purple-700',
                    'seller'    => 'bg-blue-50 text-blue-600',
                    'moderator' => 'bg-yellow-50 text-yellow-700',
                    default     => 'bg-surface-container text-on-surface-variant'
                  } ?>"><?= ucfirst($u['role']) ?></span>
              </td>
              <td class="px-5 py-3">
                <?php if ($u['is_verified']): ?>
                <span class="inline-flex items-center gap-1 text-xs text-green-600 font-medium"><span class="material-symbols-outlined text-sm filled">check_circle</span>Verified</span>
                <?php else: ?>
                <span class="inline-flex items-center gap-1 text-xs text-thrift-coral font-medium"><span class="material-symbols-outlined text-sm">cancel</span>Unverified</span>
                <?php endif; ?>
              </td>
              <td class="px-5 py-3 text-xs text-on-surface-variant"><?= htmlspecialchars($u['phone_number'] ?? '—') ?></td>
              <td class="px-5 py-3 text-xs text-on-surface-variant"><?= date('M d, Y', strtotime($u['created_at'])) ?></td>
              <td class="px-5 py-3">
                <div class="flex items-center gap-2">
                  <?php if (!$u['is_verified']): ?>
                  <form method="POST">
                    <input type="hidden" name="action" value="verify">
                    <input type="hidden" name="user_id" value="<?= $u['user_id'] ?>">
                    <button type="submit" class="text-xs text-green-600 font-bold hover:underline">Verify</button>
                  </form>
                  <?php else: ?>
                  <form method="POST" onsubmit="return confirm('Suspend this account?')">
                    <input type="hidden" name="action" value="suspend">
                    <input type="hidden" name="user_id" value="<?= $u['user_id'] ?>">
                    <button type="submit" class="text-xs text-thrift-coral font-bold hover:underline">Suspend</button>
                  </form>
                  <?php endif; ?>
                  <?php if ($u['role'] === 'buyer'): ?>
                  <form method="POST" onsubmit="return confirm('Promote to Seller?')">
                    <input type="hidden" name="action" value="promote_seller">
                    <input type="hidden" name="user_id" value="<?= $u['user_id'] ?>">
                    <button type="submit" class="text-xs text-blue-600 font-bold hover:underline">Make Seller</button>
                  </form>
                  <?php endif; ?>
                </div>
              </td>
            </tr>
            <?php endforeach; endif; ?>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <?php if ($totalPages > 1): ?>
      <div class="px-5 py-4 border-t border-outline-variant flex items-center justify-between">
        <p class="text-xs text-on-surface-variant">Page <?= $page ?> of <?= $totalPages ?></p>
        <div class="flex gap-2">
          <?php if ($page > 1): ?><a href="?page=<?= $page-1 ?>&search=<?= urlencode($search) ?>&role=<?= $filter ?>" class="px-3 py-1.5 border border-outline-variant rounded text-xs hover:bg-surface-container">Previous</a><?php endif; ?>
          <?php if ($page < $totalPages): ?><a href="?page=<?= $page+1 ?>&search=<?= urlencode($search) ?>&role=<?= $filter ?>" class="px-3 py-1.5 btn-coral rounded text-xs">Next</a><?php endif; ?>
        </div>
      </div>
      <?php endif; ?>
    </div>

  </div>
</main>
</div>
</body></html>
