<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('/CBDAD/MCOV1/thriftbid/pages/login.php');
requireRole('admin', '/CBDAD/MCOV1/thriftbid/pages/login.php');

/
// Platform oversight KPIs only 
$totalUsers     = DB::fetch('SELECT COUNT(*) c FROM USERS')['c'] ?? 0;
$verifiedUsers  = DB::fetch('SELECT COUNT(*) c FROM USERS WHERE is_verified=1')['c'] ?? 0;
$totalSellers   = DB::fetch('SELECT COUNT(*) c FROM SELLER')['c'] ?? 0;
$totalBuyers    = DB::fetch('SELECT COUNT(*) c FROM BUYER')['c'] ?? 0;
$activeAuctions = DB::fetch('SELECT COUNT(*) c FROM AUCTIONS WHERE status="Active"')['c'] ?? 0;
$totalAuctions  = DB::fetch('SELECT COUNT(*) c FROM AUCTIONS')['c'] ?? 0;
$openDisputes   = DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE status="Open"')['c'] ?? 0;
$totalDisputes  = DB::fetch('SELECT COUNT(*) c FROM DISPUTES')['c'] ?? 0;
$resolvedDisp   = DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE status="Resolved"')['c'] ?? 0;
$pendingFlags   = DB::fetch('SELECT COUNT(*) c FROM FRAUD_FLAGS WHERE status="Pending"')['c'] ?? 0;
$activePenalties= DB::fetch('SELECT COUNT(*) c FROM PENALTIES WHERE status="Active"')['c'] ?? 0;
$newUsersToday  = DB::fetch('SELECT COUNT(*) c FROM USERS WHERE DATE(created_at)=CURDATE()')['c'] ?? 0;
$totalListings  = DB::fetch('SELECT COUNT(*) c FROM LISTINGS WHERE is_active=1')['c'] ?? 0;
$totalOrders    = DB::fetch('SELECT COUNT(*) c FROM ORDERS')['c'] ?? 0;
$deliveredOrders= DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE status="Delivered"')['c'] ?? 0;
$dispResRate    = $totalDisputes > 0 ? round($resolvedDisp / $totalDisputes * 100, 1) : 0;

// Registration trend (last 7 days)
$regTrend = DB::fetchAll(
    'SELECT DATE_FORMAT(created_at,"%b %d") as day, COUNT(*) as cnt
     FROM USERS
     WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
     GROUP BY DATE(created_at), DATE_FORMAT(created_at,"%b %d")
     ORDER BY DATE(created_at)'
);

// Recent users
$recentUsers = DB::fetchAll(
    'SELECT user_id,username,email,role,is_verified,created_at FROM USERS ORDER BY created_at DESC LIMIT 8'
);

// Open disputes
$disputes = DB::fetchAll(
    'SELECT d.dispute_id,d.reason,d.status,d.opened_at,
            o.order_id,l.title,
            ub.username as buyer_name,us.username as seller_name
     FROM DISPUTES d
     JOIN ORDERS o   ON d.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER b2   ON d.buyer_id=b2.buyer_id
     JOIN USERS ub   ON b2.user_id=ub.user_id
     JOIN SELLER s2  ON d.seller_id=s2.seller_id
     JOIN USERS us   ON s2.user_id=us.user_id
     WHERE d.status="Open"
     ORDER BY d.opened_at DESC LIMIT 6'
);

renderHead('Admin Dashboard');
?>
<body style="height:100vh;overflow:hidden;display:flex;flex-direction:column;background:var(--clr-bg)">
<?php renderNavbar('home'); ?>

<div style="display:flex;flex:1;overflow:hidden">
<?php renderAdminSidebar('dashboard'); ?>

<main style="flex:1;overflow-y:auto;background:var(--clr-bg)">
<div style="max-width:1100px;margin:0 auto;padding:32px 40px 80px">

  <div style="margin-bottom:28px">
    <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:700;color:var(--clr-text)">Platform Overview</h1>
    <p style="color:var(--clr-tertiary);margin-top:4px">User activity, disputes, listings, and auction monitoring.</p>
  </div>

  <!-- KPI Grid  platform oversight  -->
  <div class="grid grid-cols-2 md:grid-cols-4 gap-4" style="margin-bottom:28px">
    <?php $kpis = [
      ['label'=>'Total Users',         'value'=>$totalUsers,        'sub'=>$verifiedUsers.' verified',   'icon'=>'group',          'color'=>'var(--clr-coral)'],
      ['label'=>'Total Sellers',       'value'=>$totalSellers,      'sub'=>'Registered',                 'icon'=>'storefront',     'color'=>'var(--clr-coral)'],
      ['label'=>'Total Buyers',        'value'=>$totalBuyers,       'sub'=>'Registered',                 'icon'=>'shopping_cart',  'color'=>'var(--clr-coral)'],
      ['label'=>'New Today',           'value'=>$newUsersToday,     'sub'=>'Registrations',              'icon'=>'person_add',     'color'=>'var(--clr-coral)'],
      ['label'=>'Total Listings',      'value'=>$totalListings,     'sub'=>'Active listings',            'icon'=>'inventory_2',    'color'=>'var(--clr-coral)'],
      ['label'=>'Active Auctions',     'value'=>$activeAuctions,    'sub'=>$totalAuctions.' total',      'icon'=>'gavel',          'color'=>'var(--clr-coral)'],
      ['label'=>'Total Orders',        'value'=>$totalOrders,       'sub'=>$deliveredOrders.' delivered','icon'=>'package_2',      'color'=>'var(--clr-coral)'],
      ['label'=>'Open Disputes',       'value'=>$openDisputes,      'sub'=>$dispResRate.'% resolved',    'icon'=>'report_problem', 'color'=>'var(--clr-error)'],
      ['label'=>'Fraud Flags',         'value'=>$pendingFlags,      'sub'=>'Pending review',             'icon'=>'flag',           'color'=>'var(--clr-error)'],
      ['label'=>'Active Penalties',    'value'=>$activePenalties,   'sub'=>'Platform issued',            'icon'=>'block',          'color'=>'var(--clr-error)'],
      ['label'=>'Dispute Resolution',  'value'=>$dispResRate.'%',   'sub'=>$resolvedDisp.' resolved',    'icon'=>'verified',       'color'=>'var(--clr-success)'],
      ['label'=>'Total Auctions',      'value'=>$totalAuctions,     'sub'=>$activeAuctions.' active',    'icon'=>'timer',          'color'=>'var(--clr-tertiary)'],
    ]; foreach ($kpis as $k): ?>
    <div class="tb-stat-card">
      <div class="tb-stat-icon" style="background:rgba(255,107,107,0.08);color:<?= $k['color'] ?>">
        <span class="material-symbols-outlined icon-sm"><?= $k['icon'] ?></span>
      </div>
      <div style="min-width:0">
        <div class="tb-stat-label"><?= $k['label'] ?></div>
        <div class="tb-stat-value" style="font-size:22px"><?= $k['value'] ?></div>
        <div style="font-size:11px;color:var(--clr-tertiary);margin-top:1px"><?= $k['sub'] ?></div>
      </div>
    </div>
    <?php endforeach; ?>
  </div>

  <!-- Registration trend + Dispute summary -->
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-5" style="margin-bottom:28px">

    <div class="tb-card lg:col-span-2">
      <div class="tb-card-header">
        <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">New Registrations (Last 7 Days)</span>
      </div>
      <div style="padding:20px">
        <?php if (!empty($regTrend)): ?>
        <canvas id="regChart" height="130"></canvas>
        <?php else: ?>
        <div style="height:130px;display:flex;align-items:center;justify-content:center;color:var(--clr-tertiary);font-size:var(--fs-label-md)">No registration data this week</div>
        <?php endif; ?>
      </div>
    </div>

    <div class="tb-card">
      <div class="tb-card-header"><span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Dispute Summary</span></div>
      <div style="padding:20px;display:flex;flex-direction:column;gap:14px">
        <div>
          <div style="display:flex;justify-content:space-between;font-size:var(--fs-label-sm);margin-bottom:5px">
            <span style="font-weight:600">Resolution Rate</span>
            <span style="color:var(--clr-coral);font-weight:700"><?= $dispResRate ?>%</span>
          </div>
          <div class="tb-progress-bar"><div class="tb-progress-fill" style="width:<?= $dispResRate ?>%"></div></div>
        </div>
        <?php foreach ([
          ['Open',     $openDisputes, 'tb-badge-red'],
          ['Resolved', $resolvedDisp, 'tb-badge-active'],
          ['Rejected', DB::fetch('SELECT COUNT(*) c FROM DISPUTES WHERE status="Rejected"')['c']??0, 'tb-badge-gray'],
        ] as [$label, $count, $badge]): ?>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span class="tb-badge <?= $badge ?>"><?= $label ?></span>
          <span style="font-weight:700;font-size:var(--fs-label-md);color:var(--clr-text)"><?= $count ?></span>
        </div>
        <?php endforeach; ?>
        <a href="disputes.php" class="btn btn-ghost btn-sm" style="margin-top:4px">Manage Disputes</a>
      </div>
    </div>
  </div>

  <!-- Open Disputes Table -->
  <?php if (!empty($disputes)): ?>
  <div class="tb-card" style="margin-bottom:28px">
    <div class="tb-card-header">
      <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Open Disputes</span>
      <a href="disputes.php" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">Manage All</a>
    </div>
    <div style="overflow-x:auto">
      <table class="tb-table">
        <thead><tr>
          <th>ID</th><th>Item</th><th>Buyer</th><th>Seller</th><th>Reason</th><th>Opened</th><th>Action</th>
        </tr></thead>
        <tbody>
          <?php foreach ($disputes as $d): ?>
          <tr>
            <td style="color:var(--clr-tertiary)">#<?= $d['dispute_id'] ?></td>
            <td style="font-weight:600;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($d['title']) ?></td>
            <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($d['buyer_name']) ?></td>
            <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($d['seller_name']) ?></td>
            <td style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--clr-tertiary)"><?= htmlspecialchars($d['reason']) ?></td>
            <td style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)"><?= date('M d, Y', strtotime($d['opened_at'])) ?></td>
            <td><a href="disputes.php?id=<?= $d['dispute_id'] ?>" style="color:var(--clr-coral);font-size:var(--fs-label-sm);font-weight:700">Review</a></td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>
  <?php endif; ?>

  <!-- Recent Users -->
  <div class="tb-card">
    <div class="tb-card-header">
      <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Recent Registrations</span>
      <a href="users.php" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View All Users</a>
    </div>
    <div style="overflow-x:auto">
      <table class="tb-table">
        <thead><tr><th>User</th><th>Role</th><th>Status</th><th>Joined</th><th>Action</th></tr></thead>
        <tbody>
          <?php foreach ($recentUsers as $u): ?>
          <tr>
            <td>
              <p style="font-weight:600;color:var(--clr-text)"><?= htmlspecialchars($u['username']) ?></p>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($u['email']) ?></p>
            </td>
            <td>
              <span class="tb-badge <?= match($u['role']) { 'admin'=>'tb-badge-red','seller'=>'tb-badge-blue',default=>'tb-badge-gray' } ?>">
                <?= ucfirst($u['role']) ?>
              </span>
            </td>
            <td>
              <?php if ($u['is_verified']): ?>
              <span style="display:flex;align-items:center;gap:4px;font-size:var(--fs-label-sm);color:var(--clr-success);font-weight:600"><span class="material-symbols-outlined icon-sm filled">check_circle</span>Verified</span>
              <?php else: ?>
              <span style="display:flex;align-items:center;gap:4px;font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><span class="material-symbols-outlined icon-sm">pending</span>Unverified</span>
              <?php endif; ?>
            </td>
            <td style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($u['created_at'])) ?></td>
            <td><a href="users.php?id=<?= $u['user_id'] ?>" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:700">View</a></td>
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
  options:{
    responsive:true,
    plugins:{legend:{display:false}},
    scales:{y:{beginAtZero:true,ticks:{stepSize:1,precision:0}}}
  }
});
</script>
<?php endif; ?>
</body></html>