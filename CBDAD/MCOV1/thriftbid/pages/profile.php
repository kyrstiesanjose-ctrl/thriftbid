<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/layout.php';
requireLogin('./login.php');

$user    = currentUser();
$profile = DB::fetch('SELECT * FROM USERS WHERE user_id=?', [$user['user_id']]);
$buyer   = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$user['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;

$stats = ['bids'=>0,'orders'=>0,'spent'=>0,'cart'=>0];
if ($buyerId) {
    $stats['bids']   = DB::fetch('SELECT COUNT(*) c FROM BIDDINGS b JOIN AUCTIONS a ON b.auction_id=a.auction_id WHERE b.buyer_id=? AND a.status="Active"', [$buyerId])['c']??0;
    $stats['orders'] = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE buyer_id=?', [$buyerId])['c']??0;
    $stats['spent']  = DB::fetch('SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.buyer_id=? AND p.payment_status="Completed"', [$buyerId])['s']??0;
    try { $stats['cart'] = DB::fetch('SELECT COUNT(*) c FROM CART_ITEMS WHERE user_id=?', [$user['user_id']])['c']??0; } catch(\Exception $e){}
    $spendTrend = DB::fetchAll('SELECT DATE_FORMAT(p.payment_date,"%b") mo,SUM(p.amount_paid) total FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.buyer_id=? AND p.payment_status="Completed" AND p.payment_date>=DATE_SUB(NOW(),INTERVAL 6 MONTH) GROUP BY MONTH(p.payment_date),DATE_FORMAT(p.payment_date,"%b") ORDER BY MONTH(p.payment_date)', [$buyerId]);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username'] ?? '');
    $phone    = trim($_POST['phone'] ?? '');
    $address  = trim($_POST['address'] ?? '');
    if (!$username) { flash('profile_error','Username cannot be empty.'); }
    elseif (DB::fetch('SELECT user_id FROM USERS WHERE username=? AND user_id!=?',[$username,$user['user_id']])) { flash('profile_error','Username already taken.'); }
    else {
        DB::query('UPDATE USERS SET username=?,phone_number=?,address=? WHERE user_id=?',[$username,$phone?:null,$address?:null,$user['user_id']]);
        $_SESSION['user']['username'] = $username;
        flash('profile_success','Profile updated.');
    }
    header('Location: profile.php'); exit;
}

$successMsg = flash('profile_success'); $errorMsg = flash('profile_error');
renderHeadRoot('My Profile');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar(''); ?>

<main style="flex:1;max-width:var(--sp-container);margin:0 auto;padding:32px var(--sp-margin-desktop) 80px;width:100%">

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show" style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>
  <?php if ($errorMsg):   ?><div class="tb-alert tb-alert-error show"   style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div><?php endif; ?>

  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    <!-- Left -->
    <div style="display:flex;flex-direction:column;gap:14px">
      <!-- Profile card -->
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden">
        <div style="background:var(--clr-coral);padding:28px 20px;text-align:center">
          <div style="width:72px;height:72px;border-radius:50%;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;margin:0 auto 12px">
            <span class="material-symbols-outlined filled" style="font-size:44px;color:#fff">account_circle</span>
          </div>
          <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:800;color:#fff"><?= htmlspecialchars($profile['username']) ?></h2>
          <p style="color:rgba(255,255,255,0.8);font-size:var(--fs-label-sm);margin-top:3px"><?= htmlspecialchars($profile['email']) ?></p>
          <span style="display:inline-block;margin-top:8px;padding:2px 12px;background:rgba(255,255,255,0.2);border-radius:999px;font-size:11px;font-weight:700;color:#fff;text-transform:uppercase;letter-spacing:0.06em"><?= ucfirst($profile['role']) ?></span>
        </div>
        <div style="padding:16px 20px">
          <?php $fields=[['icon'=>'mail','label'=>'Email','val'=>$profile['email']],['icon'=>'phone','label'=>'Phone','val'=>$profile['phone_number']??'Not set'],['icon'=>'location_on','label'=>'Address','val'=>$profile['address']??'Not set']];
          foreach ($fields as $f): ?>
          <div style="display:flex;align-items:flex-start;gap:10px;padding:10px 0;border-bottom:1px solid var(--clr-outline)">
            <span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral);flex-shrink:0;margin-top:1px"><?= $f['icon'] ?></span>
            <div>
              <p style="font-size:10px;font-weight:700;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em"><?= $f['label'] ?></p>
              <p style="font-size:var(--fs-label-md);font-weight:600;color:var(--clr-text)"><?= htmlspecialchars($f['val']) ?></p>
            </div>
          </div>
          <?php endforeach; ?>
          <a href="../api/logout.php" onclick="return confirm('Log out?')" class="btn btn-danger btn-full" style="margin-top:16px">
            <span class="material-symbols-outlined icon-sm">logout</span>Log Out
          </a>
        </div>
      </div>

      <!-- Stats -->
      <?php if ($buyerId): ?>
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px">
        <p class="tb-section-label" style="margin-bottom:14px">Activity Summary</p>
        <?php $kpis=[['icon'=>'gavel','label'=>'Active Bids','val'=>$stats['bids']],['icon'=>'shopping_cart','label'=>'Cart Items','val'=>$stats['cart']],['icon'=>'package_2','label'=>'Total Orders','val'=>$stats['orders']],['icon'=>'payments','label'=>'Total Spent','val'=>convertCurrency((float)$stats['spent'])]];
        foreach ($kpis as $k): ?>
        <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--clr-outline)">
          <span style="display:flex;align-items:center;gap:8px;font-size:var(--fs-label-md);color:var(--clr-tertiary)">
            <span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)"><?= $k['icon'] ?></span><?= $k['label'] ?>
          </span>
          <strong style="color:var(--clr-text)"><?= $k['val'] ?></strong>
        </div>
        <?php endforeach; ?>
      </div>
      <?php endif; ?>
    </div>

    <!-- Right -->
    <div class="lg:col-span-2" style="display:flex;flex-direction:column;gap:16px">

      <!-- Edit form -->
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden">
        <div class="tb-card-header"><h3 style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Edit Profile</h3></div>
        <div style="padding:20px">
          <form method="POST" class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="tb-form-group">
              <label class="tb-label">Username</label>
              <input class="tb-input" name="username" type="text" value="<?= htmlspecialchars($profile['username']) ?>" required maxlength="40">
            </div>
            <div class="tb-form-group">
              <label class="tb-label">Email <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">(cannot change)</span></label>
              <input class="tb-input" type="email" value="<?= htmlspecialchars($profile['email']) ?>" disabled style="background:var(--clr-surface-low);color:var(--clr-tertiary)">
            </div>
            <div class="tb-form-group">
              <label class="tb-label">Phone Number</label>
              <input class="tb-input" name="phone" type="tel" placeholder="09XXXXXXXXX" value="<?= htmlspecialchars($profile['phone_number']??'') ?>" maxlength="15">
            </div>
            <div class="tb-form-group md:col-span-2">
              <label class="tb-label">Shipping Address</label>
              <input class="tb-input" name="address" type="text" placeholder="Street, Barangay, City, Province" value="<?= htmlspecialchars($profile['address']??'') ?>">
            </div>
            <div class="md:col-span-2">
              <button type="submit" class="btn btn-primary">
                <span class="material-symbols-outlined icon-sm">save</span>Save Changes
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Quick links -->
      <div class="grid grid-cols-2 gap-4">
        <?php $links=[
          ['href'=>'./customer/orders.php','icon'=>'package_2','label'=>'My Orders'],
          ['href'=>'./customer/orders.php?tab=cart','icon'=>'shopping_cart','label'=>'My Cart'],
          ['href'=>'./notifications.php','icon'=>'notifications','label'=>'Notifications'],
          ['href'=>'./customer/live-bids.php','icon'=>'gavel','label'=>'Live Auctions'],
        ]; foreach ($links as $l): ?>
        <a href="<?= $l['href'] ?>" style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 18px;display:flex;align-items:center;gap:12px;text-decoration:none;color:var(--clr-text);transition:box-shadow var(--transition)" onmouseover="this.style.boxShadow='var(--shadow-md)'" onmouseout="this.style.boxShadow=''">
          <span class="material-symbols-outlined icon-md" style="color:var(--clr-coral)"><?= $l['icon'] ?></span>
          <span style="font-weight:600;font-size:var(--fs-label-md)"><?= $l['label'] ?></span>
          <span class="material-symbols-outlined icon-sm" style="color:var(--clr-tertiary);margin-left:auto">chevron_right</span>
        </a>
        <?php endforeach; ?>
      </div>

      <!-- Spend chart -->
      <?php if ($buyerId && !empty($spendTrend)): ?>
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:20px">
        <h3 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:16px">Spending Trend</h3>
        <canvas id="spendChart" height="100"></canvas>
      </div>
      <?php endif; ?>

    </div>
  </div>
</main>
<?php renderFooter(); ?>
<?php if (!empty($spendTrend)): ?>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
new Chart(document.getElementById('spendChart'),{
  type:'bar',
  data:{labels:<?= json_encode(array_column($spendTrend,'mo')) ?>,datasets:[{label:'Spent (₱)',data:<?= json_encode(array_map(fn($r)=>(float)$r['total'],$spendTrend)) ?>,backgroundColor:'rgba(255,107,107,0.65)',borderColor:'#ff6b6b',borderWidth:1,borderRadius:2}]},
  options:{responsive:true,plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,ticks:{callback:v=>'₱'+v.toLocaleString()}}}}
});
</script>
<?php endif; ?>
</body></html>
