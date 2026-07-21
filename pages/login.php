<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/layout.php';

if (isLoggedIn()) {
    $role = $_SESSION['auth']['role'] ?? 'buyer';
    header('Location: ' . match($role) { 'admin'=>'./admin/dashboard.php','seller'=>'./seller/dashboard.php',default=>'./customer/home.php' }); exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email']??''); $password = $_POST['password']??'';
    if (!$email || !$password) { $error = 'Please fill in all fields.'; }
    else {
        $found = findAccountByEmail($email);
        if (!$found || !verifyPassword($password, $found['row']['password_hash'])) {
            $error = 'Invalid email or password.';
        } else {
            $role = $found['role'];
            $row  = $found['row'];

            // Account status checks (per updated schema's seller_status /
            // buyer_status ENUMs). Suspended/Banned accounts can't log in.
            $statusCol = $role === 'seller' ? 'seller_status' : ($role === 'buyer' ? 'buyer_status' : null);
            if ($statusCol && in_array($row[$statusCol] ?? 'Active', ['Suspended','Banned'], true)) {
                $error = 'Your account is currently ' . strtolower($row[$statusCol]) . '. Please contact support.';
            } else {
                loginUser($row, $role);

                if ($role === 'seller') {
                    DB::query('INSERT INTO NOTIFICATIONS (seller_id,title,message,notification_type) VALUES (?,?,?,?)',
                        [$row['seller_id'],'Welcome back!','You have logged in to ThriftBid.','SYSTEM']);
                } elseif ($role === 'buyer') {
                    DB::query('INSERT INTO NOTIFICATIONS (buyer_id,title,message,notification_type) VALUES (?,?,?,?)',
                        [$row['buyer_id'],'Welcome back!','You have logged in to ThriftBid.','SYSTEM']);
                }

                header('Location: '.match($role){'admin'=>'./admin/dashboard.php','seller'=>'./seller/dashboard.php',default=>'./customer/home.php'}); exit;
            }
        }
    }
}
renderHeadRoot('Login');
?>
<body class="tb-auth-page">
<header style="background:var(--clr-coral);padding:14px 40px">
  <span style="font-family:'Hanken Grotesk',sans-serif;font-size:20px;font-weight:800;color:#fff;letter-spacing:-0.02em">ThriftBid</span>
</header>
<div class="tb-auth-center">
  <!-- Dot deco -->
  <div style="position:absolute;top:0;right:0;width:28%;height:40%;background-image:radial-gradient(var(--clr-outline) 1px,transparent 1px);background-size:20px 20px;opacity:.5;pointer-events:none"></div>

  <div class="tb-auth-card tb-fade-in">
    <div style="text-align:center;margin-bottom:28px">
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text)">Sign In</h1>
      <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-top:6px">Log in to start bidding on curated thrift finds.</p>
    </div>

    <?php if ($error): ?><div class="tb-alert tb-alert-error show"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($error) ?></div><?php endif; ?>
    <?php $s=flash('success'); if($s): ?><div class="tb-alert tb-alert-success show"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($s) ?></div><?php endif; ?>

    <form method="POST" style="display:flex;flex-direction:column;gap:16px">
      <div class="tb-form-group">
        <label class="tb-label">Email Address</label>
        <input class="tb-input" name="email" type="email" placeholder="you@email.com" value="<?= htmlspecialchars($_POST['email']??'') ?>" required>
      </div>
      <div class="tb-form-group">
        <label class="tb-label">Password</label>
        <div style="position:relative">
          <input class="tb-input" id="pw" name="password" type="password" placeholder="Your password" style="padding-right:42px" required>
          <button type="button" onclick="togglePw('pw',this)" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:var(--clr-tertiary)">
            <span class="material-symbols-outlined icon-sm">visibility</span>
          </button>
        </div>
      </div>
      <button type="submit" class="btn btn-primary btn-full" style="height:46px;font-size:var(--fs-body-md)">Sign In</button>
    </form>

    <div class="tb-divider" style="margin:20px 0">Quick Demo</div>
    <div class="grid grid-cols-3 gap-2 mb-5">
      <button onclick="ql('ana@email.com')"                    class="btn btn-ghost btn-sm">Buyer</button>
      <button onclick="ql('seller_leila@thriftbid.com')"       class="btn btn-ghost btn-sm">Seller</button>
      <button onclick="ql('admin@thriftbid.com')"             class="btn btn-ghost btn-sm">Admin</button>
    </div>

    <p style="text-align:center;font-size:var(--fs-label-md);color:var(--clr-tertiary)">
      No account? <a href="register.php" style="color:var(--clr-coral);font-weight:700">Create one</a>
    </p>
  </div>
</div>
<script>
function togglePw(id,btn){const i=document.getElementById(id);const ic=btn.querySelector('.material-symbols-outlined');i.type=i.type==='password'?'text':'password';ic.textContent=i.type==='password'?'visibility':'visibility_off';}
function ql(e){document.querySelector('[name=email]').value=e;document.querySelector('[name=password]').value='Password123!';}
</script>
</body></html>