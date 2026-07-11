<?php
// pages/admin/auctions.php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/CBDAD/MCOV1/thriftbid/pages/login.php');
requireRole('admin', '/CBDAD/MCOV1/thriftbid/pages/login.php');

if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['force_close'])) {
    $aid = (int)$_POST['auction_id'];
    DB::query('UPDATE AUCTIONS SET status="Closed" WHERE auction_id=?',[$aid]);
    header('Location: /CBDAD/MCOV1/thriftbid/pages/admin/auctions.php'); exit;
}

$tab      = $_GET['tab'] ?? 'active';
$active   = DB::fetchAll('SELECT a.*,l.title,u.username as seller_name,(SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id) bc FROM AUCTIONS a JOIN LISTINGS l ON a.listing_id=l.listing_id JOIN SELLER s ON l.seller_id=s.seller_id JOIN USERS u ON s.user_id=u.user_id WHERE a.status="Active" ORDER BY a.end_time ASC');
$closed   = DB::fetchAll('SELECT a.*,l.title,u.username as seller_name,(SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id) bc FROM AUCTIONS a JOIN LISTINGS l ON a.listing_id=l.listing_id JOIN SELLER s ON l.seller_id=s.seller_id JOIN USERS u ON s.user_id=u.user_id WHERE a.status="Closed" ORDER BY a.end_time DESC LIMIT 50');
$fraudFlags = DB::fetchAll('SELECT ff.*,l.title,ub.username as buyer_name,us.username as seller_name FROM FRAUD_FLAGS ff LEFT JOIN LISTINGS l ON ff.listing_id=l.listing_id LEFT JOIN BUYER by2 ON ff.buyer_id=by2.buyer_id LEFT JOIN USERS ub ON by2.user_id=ub.user_id LEFT JOIN SELLER s ON ff.seller_id=s.seller_id LEFT JOIN USERS us ON s.user_id=us.user_id ORDER BY ff.created_at DESC LIMIT 30');

renderHead('Admin Auctions');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('home'); ?>
<div class="tb-app-shell">
<?php renderAdminSidebar('auctions'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">
  <h1 class="tb-page-title mb-6">Auction Management</h1>
  <div class="tb-tabs mb-6">
    <a href="?tab=active"  class="tb-tab-link <?=$tab==='active'?'active':''?>">Active (<?=count($active)?>)</a>
    <a href="?tab=closed"  class="tb-tab-link <?=$tab==='closed'?'active':''?>">Closed (<?=count($closed)?>)</a>
    <a href="?tab=fraud"   class="tb-tab-link <?=$tab==='fraud'?'active':''?>">Fraud Flags (<?=count($fraudFlags)?>)</a>
  </div>

  <?php $list = $tab==='fraud'?$fraudFlags:($tab==='closed'?$closed:$active); ?>
  <?php if (empty($list)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">No records found.</div>
  <?php elseif ($tab==='fraud'): ?>
  <div class="tb-table-wrapper">
    <table class="tb-table">
      <thead><tr><th>ID</th><th>Item</th><th>Buyer</th><th>Seller</th><th>Reason</th><th>Status</th><th>Date</th></tr></thead>
      <tbody>
        <?php foreach ($fraudFlags as $f): ?>
        <tr>
          <td style="color:var(--clr-tertiary)">#<?=$f['fraud_flag_id']?></td>
          <td style="font-weight:600"><?= htmlspecialchars($f['title'] ?? '—') ?></td>
          <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($f['buyer_name'] ?? '—') ?></td>
          <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($f['seller_name'] ?? '—') ?></td>
          <td style="max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($f['reason']) ?></td>
          <td><span class="tb-badge <?=$f['status']==='Pending'?'tb-badge-yellow':($f['status']==='Resolved'?'tb-badge-green':'tb-badge-gray')?>"><?=$f['status']?></span></td>
          <td style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)"><?= date('M d, Y',strtotime($f['created_at'])) ?></td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php else: ?>
  <div class="tb-table-wrapper">
    <table class="tb-table">
      <thead><tr><th>ID</th><th>Item</th><th>Seller</th><th>Highest Bid</th><th>Bids</th><th><?=$tab==='active'?'Time Left':'Ended'?></th><?php if($tab==='active'): ?><th>Action</th><?php endif; ?></tr></thead>
      <tbody>
        <?php foreach ($list as $a): ?>
        <tr>
          <td style="color:var(--clr-tertiary)">#<?=$a['auction_id']?></td>
          <td style="font-weight:600"><?= htmlspecialchars($a['title']) ?></td>
          <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($a['seller_name']) ?></td>
          <td style="font-weight:700"><?= convertCurrency((float)$a['current_highest_bid']) ?></td>
          <td style="color:var(--clr-tertiary)"><?=$a['bc']?></td>
          <td style="<?=$tab==='active'&&(strtotime($a['end_time'])-time()<3600)?'color:var(--clr-error);font-weight:700':'' ?>">
            <?=$tab==='active'?formatTimeLeft($a['end_time']):date('M d, Y',strtotime($a['end_time']))?>
          </td>
          <?php if ($tab==='active'): ?>
          <td>
            <form method="POST" onsubmit="return confirm('Force close this auction?')">
              <input type="hidden" name="force_close" value="1">
              <input type="hidden" name="auction_id" value="<?=$a['auction_id']?>">
              <button type="submit" class="btn btn-ghost btn-sm">Force Close</button>
            </form>
          </td>
          <?php endif; ?>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
</div>
</main>
</div>
</body></html>
