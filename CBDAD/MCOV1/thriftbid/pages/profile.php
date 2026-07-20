<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/currency.php';
require_once __DIR__ . '/../includes/layout.php';
requireLogin('./login.php');

$user  = currentUser();
$role  = $user['role'];               // admin | seller | buyer
$table = ['admin'=>'ADMIN','seller'=>'SELLER','buyer'=>'BUYER'][$role];
$idCol = ['admin'=>'admin_id','seller'=>'seller_id','buyer'=>'buyer_id'][$role];
$id    = $user['id'];

$profile = DB::fetch("SELECT * FROM $table WHERE $idCol=?", [$id]);
$address = DB::fetch('SELECT * FROM ADDRESSES WHERE user_id=? AND user_type=? AND is_default=1', [$id, ucfirst($role)]);

$stats = ['bids'=>0,'orders'=>0,'spent'=>0,'cart'=>0];
$spendTrend = [];
if ($role === 'buyer') {
    $stats['bids']   = DB::fetch('SELECT COUNT(*) c FROM BIDDINGS b JOIN AUCTIONS a ON b.auction_id=a.auction_id WHERE b.buyer_id=? AND a.status="Active"', [$id])['c']??0;
    $stats['orders'] = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE buyer_id=?', [$id])['c']??0;
    $stats['spent']  = DB::fetch('SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.buyer_id=? AND p.payment_status="Completed"', [$id])['s']??0;
    $stats['cart']   = DB::fetch('SELECT COUNT(*) c FROM CART_ITEMS WHERE buyer_id=?', [$id])['c']??0;
    $spendTrend = DB::fetchAll('SELECT DATE_FORMAT(p.payment_date,"%b") mo,SUM(p.amount_paid) total FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.buyer_id=? AND p.payment_status="Completed" AND p.payment_date>=DATE_SUB(NOW(),INTERVAL 6 MONTH) GROUP BY MONTH(p.payment_date),DATE_FORMAT(p.payment_date,"%b") ORDER BY MONTH(p.payment_date)', [$id]);
} elseif ($role === 'seller') {
    $stats['orders'] = DB::fetch('SELECT COUNT(*) c FROM ORDERS WHERE seller_id=?', [$id])['c']??0;
    $stats['spent']  = DB::fetch('SELECT COALESCE(SUM(p.amount_paid),0) s FROM PAYMENTS p JOIN ORDERS o ON p.order_id=o.order_id WHERE o.seller_id=? AND p.payment_status="Completed"', [$id])['s']??0; // revenue, not spend
}

$successMsg = $errorMsg = '';

// ------------------------------------------------------------
// Profile details form
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_profile'])) {
    $username = trim($_POST['username'] ?? '');
    $phone    = trim($_POST['phone'] ?? '');
    $street   = trim($_POST['address'] ?? '');
    $city     = trim($_POST['city'] ?? '');
    $province = trim($_POST['province'] ?? '');
    $zip      = trim($_POST['zip'] ?? '');
    $firstName= trim($_POST['first_name'] ?? '');
    $lastName = trim($_POST['last_name'] ?? '');

    $taken = DB::fetch("SELECT $idCol FROM $table WHERE username=? AND $idCol!=?", [$username, $id]);

    if (!$username) {
        $errorMsg = 'Username cannot be empty.';
    } elseif ($taken) {
        $errorMsg = 'Username already taken.';
    } else {
        if ($role === 'seller') {
            // Sellers have a `username` (their real name/login) and an
            // optional `shop_name` (what buyers see instead, if set).
            DB::query('UPDATE SELLER SET username=?, shop_name=?, cellphone_number=? WHERE seller_id=?',
                [$username, trim($_POST['shop_name'] ?? '') ?: null, $phone ?: $profile['cellphone_number'], $id]);
        } elseif ($role === 'buyer') {
            if (!$firstName || !$lastName) { $errorMsg = 'First and last name are required.'; }
            else DB::query('UPDATE BUYER SET username=?, first_name=?, last_name=?, cellphone_number=? WHERE buyer_id=?',
                [$username, $firstName, $lastName, $phone ?: $profile['cellphone_number'], $id]);
        } else { // admin
            if (!$firstName || !$lastName) { $errorMsg = 'First and last name are required.'; }
            else DB::query('UPDATE ADMIN SET username=?, first_name=?, last_name=? WHERE admin_id=?', [$username, $firstName, $lastName, $id]);
        }

        if (!$errorMsg) {
            if ($role !== 'admin' && ($street || $city)) {
                if ($address) {
                    DB::query('UPDATE ADDRESSES SET street_address=?, city=?, province=?, zip_code=? WHERE address_id=?',
                        [$street ?: '-', $city ?: '-', $province ?: '-', $zip ?: '0000', $address['address_id']]);
                } else {
                    DB::query('INSERT INTO ADDRESSES (user_id, user_type, street_address, city, province, zip_code, is_default) VALUES (?,?,?,?,?,?,1)',
                        [$id, ucfirst($role), $street ?: '-', $city ?: '-', $province ?: '-', $zip ?: '0000']);
                }
            }
            // Refresh the session copy so the navbar/greeting update immediately
            $_SESSION['auth']['username'] = $username;
            if (isset($_SESSION['auth']['first_name'])) $_SESSION['auth']['first_name'] = $firstName;
            flash('profile_success', 'Profile updated.');
            header('Location: profile.php'); exit;
        }
    }
}

// ------------------------------------------------------------
// Password change
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['change_password'])) {
    $current = $_POST['current_password'] ?? '';
    $new     = $_POST['new_password'] ?? '';
    $confirm = $_POST['confirm_password'] ?? '';

    if (!verifyPassword($current, $profile['password_hash'])) {
        $errorMsg = 'Current password is incorrect.';
    } elseif (strlen($new) < 8) {
        $errorMsg = 'New password must be at least 8 characters.';
    } elseif ($new !== $confirm) {
        $errorMsg = 'New passwords do not match.';
    } else {
        DB::query("UPDATE $table SET password_hash=? WHERE $idCol=?", [hashPassword($new), $id]);
        flash('profile_success', 'Password changed successfully.');
        header('Location: profile.php'); exit;
    }
}

$successMsg = $successMsg ?: flash('profile_success');
$errorMsg   = $errorMsg   ?: flash('profile_error');

$displayName = match($role) {
    'seller' => $profile['shop_name'] ?: $profile['username'],
    default  => trim(($profile['first_name'] ?? '') . ' ' . ($profile['last_name'] ?? '')) ?: $profile['username'],
};

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
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden">
        <div style="background:var(--clr-coral);padding:28px 20px;text-align:center">
          <div style="width:72px;height:72px;border-radius:50%;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;margin:0 auto 12px">
            <span class="material-symbols-outlined filled" style="font-size:44px;color:#fff">account_circle</span>
          </div>
          <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:800;color:#fff"><?= htmlspecialchars($displayName) ?></h2>
          <?php if ($role !== 'seller' || $profile['shop_name']): ?><p style="color:rgba(255,255,255,0.75);font-size:11px">@<?= htmlspecialchars($profile['username']) ?></p><?php endif; ?>
          <p style="color:rgba(255,255,255,0.8);font-size:var(--fs-label-sm);margin-top:3px"><?= htmlspecialchars($profile['email']) ?></p>
          <span style="display:inline-block;margin-top:8px;padding:2px 12px;background:rgba(255,255,255,0.2);border-radius:999px;font-size:11px;font-weight:700;color:#fff;text-transform:uppercase;letter-spacing:0.06em">
            <?= ucfirst($role) ?>
          </span>
        </div>
        <div style="padding:16px 20px">
          <?php $fields=[['icon'=>'mail','label'=>'Email','val'=>$profile['email']]];
          if ($role !== 'admin') $fields[] = ['icon'=>'phone','label'=>'Phone','val'=>$profile['cellphone_number']??'Not set'];
          if ($address) $fields[] = ['icon'=>'location_on','label'=>'Address','val'=>"{$address['street_address']}, {$address['city']}"];
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

      <?php if ($role !== 'admin'): ?>
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px">
        <p class="tb-section-label" style="margin-bottom:14px"><?= $role==='buyer' ? 'Activity Summary' : 'Seller Summary' ?></p>
        <?php $kpis = $role==='buyer'
          ? [['icon'=>'gavel','label'=>'Active Bids','val'=>$stats['bids']],['icon'=>'shopping_cart','label'=>'Cart Items','val'=>$stats['cart']],['icon'=>'package_2','label'=>'Total Orders','val'=>$stats['orders']],['icon'=>'payments','label'=>'Total Spent','val'=>convertCurrency((float)$stats['spent'])]]
          : [['icon'=>'package_2','label'=>'Total Orders','val'=>$stats['orders']],['icon'=>'payments','label'=>'Total Revenue','val'=>convertCurrency((float)$stats['spent'])],['icon'=>'group','label'=>'IG Followers','val'=>number_format($profile['ig_follower_count']??0)],['icon'=>'block','label'=>'Offenses','val'=>$profile['offense_count']??0]];
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

      <!-- Edit profile -->
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden">
        <div class="tb-card-header"><h3 style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Edit Profile</h3></div>
        <div style="padding:20px">
          <form method="POST" class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input type="hidden" name="save_profile" value="1">

            <?php if ($role !== 'seller'): ?>
            <div class="tb-form-group">
              <label class="tb-label">First Name</label>
              <input class="tb-input" name="first_name" type="text" value="<?= htmlspecialchars($profile['first_name'] ?? '') ?>" required maxlength="50">
            </div>
            <div class="tb-form-group">
              <label class="tb-label">Last Name</label>
              <input class="tb-input" name="last_name" type="text" value="<?= htmlspecialchars($profile['last_name'] ?? '') ?>" required maxlength="50">
            </div>
            <?php endif; ?>

            <div class="tb-form-group">
              <label class="tb-label">Username</label>
              <input class="tb-input" name="username" type="text" value="<?= htmlspecialchars($profile['username']) ?>" required maxlength="40">
            </div>
            <?php if ($role === 'seller'): ?>
            <div class="tb-form-group">
              <label class="tb-label">Shop Name <span class="opt">(optional — shown to buyers instead of your username)</span></label>
              <input class="tb-input" name="shop_name" type="text" value="<?= htmlspecialchars($profile['shop_name'] ?? '') ?>" maxlength="100" placeholder="e.g. Leila's Closet">
            </div>
            <?php endif; ?>
            <div class="tb-form-group">
              <label class="tb-label">Email <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">(cannot change)</span></label>
              <input class="tb-input" type="email" value="<?= htmlspecialchars($profile['email']) ?>" disabled style="background:var(--clr-surface-low);color:var(--clr-tertiary)">
            </div>

            <?php if ($role !== 'admin'): ?>
            <div class="tb-form-group">
              <label class="tb-label">Phone Number</label>
              <input class="tb-input" name="phone" type="tel" placeholder="09XXXXXXXXX" value="<?= htmlspecialchars($profile['cellphone_number']??'') ?>" maxlength="15">
            </div>
            <div class="tb-form-group">
              <label class="tb-label">City</label>
              <input class="tb-input" name="city" type="text" value="<?= htmlspecialchars($address['city'] ?? '') ?>">
            </div>
            <div class="tb-form-group md:col-span-2">
              <label class="tb-label">Street Address</label>
              <input class="tb-input" name="address" type="text" placeholder="Street, Barangay" value="<?= htmlspecialchars($address['street_address'] ?? '') ?>">
            </div>
            <div class="tb-form-group">
              <label class="tb-label">Province</label>
              <input class="tb-input" name="province" type="text" value="<?= htmlspecialchars($address['province'] ?? '') ?>">
            </div>
            <div class="tb-form-group">
              <label class="tb-label">ZIP Code</label>
              <input class="tb-input" name="zip" type="text" value="<?= htmlspecialchars($address['zip_code'] ?? '') ?>">
            </div>
            <?php endif; ?>

            <div class="md:col-span-2">
              <button type="submit" class="btn btn-primary">
                <span class="material-symbols-outlined icon-sm">save</span>Save Changes
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Change password -->
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden">
        <div class="tb-card-header"><h3 style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Change Password</h3></div>
        <div style="padding:20px">
          <form method="POST" class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <input type="hidden" name="change_password" value="1">
            <div class="tb-form-group"><label class="tb-label">Current Password</label><input class="tb-input" name="current_password" type="password" required></div>
            <div class="tb-form-group"><label class="tb-label">New Password</label><input class="tb-input" name="new_password" type="password" minlength="8" required></div>
            <div class="tb-form-group"><label class="tb-label">Confirm New Password</label><input class="tb-input" name="confirm_password" type="password" minlength="8" required></div>
            <div class="md:col-span-3">
              <button type="submit" class="btn btn-outline">
                <span class="material-symbols-outlined icon-sm">lock_reset</span>Update Password
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Quick links -->
      <div class="grid grid-cols-2 gap-4">
        <?php
        $links = match($role) {
          'buyer' => [
            ['href'=>'./customer/orders.php','icon'=>'package_2','label'=>'My Orders'],
            ['href'=>'./customer/orders.php?tab=cart','icon'=>'shopping_cart','label'=>'My Cart'],
            ['href'=>'./notifications.php','icon'=>'notifications','label'=>'Notifications'],
            ['href'=>'./customer/live-bids.php','icon'=>'gavel','label'=>'Live Auctions'],
          ],
          'seller' => [
            ['href'=>'./seller/active-auctions.php','icon'=>'storefront','label'=>'My Listings'],
            ['href'=>'./seller/to-ship.php','icon'=>'local_shipping','label'=>'To Ship'],
            ['href'=>'./seller/analytics.php','icon'=>'bar_chart','label'=>'Analytics'],
            ['href'=>'./notifications.php','icon'=>'notifications','label'=>'Notifications'],
          ],
          default => [
            ['href'=>'./admin/dashboard.php','icon'=>'dashboard','label'=>'Dashboard'],
            ['href'=>'./admin/authenticity.php','icon'=>'verified','label'=>'Authenticity Queue'],
            ['href'=>'./admin/disputes.php','icon'=>'gavel','label'=>'Disputes'],
            ['href'=>'./admin/users.php','icon'=>'group','label'=>'Users'],
          ],
        };
        foreach ($links as $l): ?>
        <a href="<?= $l['href'] ?>" style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 18px;display:flex;align-items:center;gap:12px;text-decoration:none;color:var(--clr-text)">
          <span class="material-symbols-outlined icon-md" style="color:var(--clr-coral)"><?= $l['icon'] ?></span>
          <span style="font-weight:600;font-size:var(--fs-label-md)"><?= $l['label'] ?></span>
          <span class="material-symbols-outlined icon-sm" style="color:var(--clr-tertiary);margin-left:auto">chevron_right</span>
        </a>
        <?php endforeach; ?>
      </div>

      <?php if ($role === 'buyer' && !empty($spendTrend)): ?>
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