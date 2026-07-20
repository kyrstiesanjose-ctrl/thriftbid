<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole('admin');

// ------------------------------------------------------------
// Dashboard overview showing urgent tasks and recent activity.
// Comprehensive metrics like revenue and trends live in reports.php.
// ------------------------------------------------------------


$totalSellers  = DB::fetch('SELECT COUNT(*) c FROM SELLER')['c'] ?? 0;
$totalBuyers   = DB::fetch('SELECT COUNT(*) c FROM BUYER')['c'] ?? 0;
$activeAuctions= DB::fetch('SELECT COUNT(*) c FROM AUCTIONS WHERE status="Active"')['c'] ?? 0;
$openDisputes  = DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE status="Open"')['c'] ?? 0;
$pendingFlags  = DB::fetch('SELECT COUNT(*) c FROM FRAUD_FLAGS WHERE status="Pending"')['c'] ?? 0;
$pendingAuth   = DB::fetch('SELECT COUNT(*) c FROM AUTHENTICATION WHERE authentication_status="Pending"')['c'] ?? 0;
$suspendedSellers = DB::fetch('SELECT COUNT(*) c FROM SELLER WHERE seller_status="Suspended"')['c'] ?? 0;
$needsAttention = $openDisputes + $pendingFlags + $pendingAuth;

$regTrend = DB::fetchAll(
    'SELECT day, SUM(cnt) cnt FROM (
        SELECT DATE(created_at) d, DATE_FORMAT(created_at,"%b %d") day, COUNT(*) cnt
        FROM SELLER WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) GROUP BY d, day
        UNION ALL
        SELECT DATE(created_at) d, DATE_FORMAT(created_at,"%b %d") day, COUNT(*) cnt
        FROM BUYER WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) GROUP BY d, day
     ) t GROUP BY day, t.d ORDER BY t.d'
);

$recentUsers = DB::fetchAll(
    "(SELECT seller_id AS id, username, email, 'seller' AS role, is_verified, created_at FROM SELLER)
     UNION ALL
     (SELECT buyer_id AS id, username, email, 'buyer' AS role, is_verified, created_at FROM BUYER)
     ORDER BY created_at DESC LIMIT 6"
);

renderHead('Admin Dashboard');
?>
<body style="height:100vh;overflow:hidden;display:flex;flex-direction:column;background:var(--clr-bg)">
<?php renderNavbar('home'); ?>
<div style="display:flex;flex:1;overflow:hidden">
<?php renderAdminSidebar('dashboard'); ?>
<main style="flex:1;overflow-y:auto;background:var(--clr-bg)">
<div style="max-width:1100px;margin:0 auto;padding:32px 40px 80px">

  <div style="margin-bottom:24px">
    <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:700;color:var(--clr-text)">Dashboard</h1>
    <p style="color:var(--clr-tertiary);margin-top:4px">Quick overview — for detailed numbers, see Platform Analytics.</p>
  </div>

  <?php if ($needsAttention > 0): ?>
  <a href="moderation.php" style="display:block;text-decoration:none;color:inherit;margin-bottom:24px">
    <div style="background:var(--clr-error-bg,#fdecea);border:1px solid var(--clr-error);border-radius:var(--radius-lg);padding:16px 20px;display:flex;align-items:center;gap:14px">
      <span class="material-symbols-outlined" style="color:var(--clr-error)">notification_important</span>
      <div>
        <p style="font-weight:700;color:var(--clr-error)"><?= $needsAttention ?> item<?= $needsAttention!==1?'s':'' ?> need your review</p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $openDisputes ?> open dispute<?= $openDisputes!=1?'s':'' ?>, <?= $pendingFlags ?> reported listing<?= $pendingFlags!=1?'s':'' ?>, <?= $pendingAuth ?> authenticity request<?= $pendingAuth!=1?'s':'' ?> pending.</p>
      </div>
    </div>
  </a>
  <?php endif; ?>

  <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-8">
    <?php $kpis = [
      ['label'=>'Total Users',        'value'=>$totalSellers+$totalBuyers, 'icon'=>'group'],
      ['label'=>'Active Sellers',     'value'=>$totalSellers,               'icon'=>'storefront'],
      ['label'=>'Active Auctions',    'value'=>$activeAuctions,             'icon'=>'gavel'],
      ['label'=>'Suspended Sellers',  'value'=>$suspendedSellers,           'icon'=>'pause_circle'],
      ['label'=>'Needs Review',       'value'=>$needsAttention,             'icon'=>'flag'],
    ]; foreach ($kpis as $k): ?>
    <div class="tb-stat-card">
      <div class="tb-stat-icon"><span class="material-symbols-outlined icon-sm"><?= $k['icon'] ?></span></div>
      <div>
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value" style="font-size:22px"><?= $k['value'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <div class="tb-card mb-6">
    <div class="tb-card-header"><span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">New Registrations (Last 7 Days)</span></div>
    <div style="padding:20px">
      <?php if (!empty($regTrend)): ?>
      <canvas id="regChart" height="100"></canvas>
      <?php else: ?>
      <div style="height:100px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary);font-size:var(--fs-label-md)">No registration data this week</div>
      <?php endif; ?>
    </div>
  </div>

  <div class="tb-card">
    <div class="tb-card-header">
      <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Recent Registrations</span>
      <a href="users.php" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View All Users</a>
    </div>
    <div style="overflow-x:auto">
      <table class="tb-table">
        <thead><tr><th>User</th><th>Role</th><th>Status</th><th>Joined</th></tr></thead>
        <tbody>
          <?php foreach ($recentUsers as $u): ?>
          <tr>
            <td>
              <p style="font-weight:600;color:var(--clr-text)"><?= htmlspecialchars($u['username']) ?></p>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($u['email']) ?></p>
            </td>
            <td><span class="tb-badge tb-badge-gray"><?= ucfirst($u['role']) ?></span></td>
            <td>
              <?php if ($u['is_verified']): ?>
              <span style="font-size:var(--fs-label-sm);color:var(--clr-success);font-weight:600">Verified</span>
              <?php else: ?>
              <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Unverified</span>
              <?php endif; ?>
            </td>
            <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($u['created_at'])) ?></td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>

</div>
</main>
</div>

<?php if (!empty($regTrend)): ?>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
new Chart(document.getElementById('regChart'), {
  type:'line',
  data:{
    labels:<?= json_encode(array_column($regTrend,'day')) ?>,
    datasets:[{
      label:'New Users',
      data:<?= json_encode(array_map(fn($r)=>(int)$r['cnt'],$regTrend)) ?>,
      borderColor:'#ff6b6b',backgroundColor:'rgba(255,107,107,0.08)',
      borderWidth:2,fill:true,tension:0.35,
      pointBackgroundColor:'#ff6b6b',pointRadius:4
    }]
  },
  options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{stepSize:1,precision:0}}}}
});
</script>
<?php endif; ?>
</body></html>