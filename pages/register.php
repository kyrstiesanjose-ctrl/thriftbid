<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/otp.php';
require_once __DIR__ . '/../includes/layout.php';

if (isLoggedIn()) { header('Location: ./customer/home.php'); exit; }

$errors = []; $vals = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $vals = [
        'first'   => trim($_POST['first_name']??''), 'last' => trim($_POST['last_name']??''),
        'username'=> trim($_POST['username']??''),
        'email'   => trim($_POST['email']??''),      'phone'=> trim($_POST['phone']??''),
        'address' => trim($_POST['address']??''),    'city' => trim($_POST['city']??''),
        'province'=> trim($_POST['province']??''),   'zip'  => trim($_POST['zip']??''),
        'pass'    => $_POST['password']??'',
        'confirm' => $_POST['confirm_password']??'', 'role' => in_array($_POST['role']??'',['buyer','seller'])?$_POST['role']:'buyer',
        'terms'   => $_POST['terms']??'',
    ];
    if (!$vals['first'])                                   $errors[]='First name required.';
    if (!$vals['last'])                                    $errors[]='Last name required.';
    if (!preg_match('/^[a-zA-Z0-9_]{3,32}$/', $vals['username'])) $errors[]='Username must be 3-32 characters (letters, numbers, underscores only).';
    if (!filter_var($vals['email'],FILTER_VALIDATE_EMAIL)) $errors[]='Valid email required.';
    if (!preg_match('/^09\d{9}$/', $vals['phone']))        $errors[]='Enter a valid PH cellphone number (09XXXXXXXXX).';
    if (strlen($vals['pass'])<8)                           $errors[]='Password must be 8+ characters.';
    if ($vals['pass']!==$vals['confirm'])                  $errors[]='Passwords do not match.';
    if (!$vals['terms'])                                   $errors[]='You must agree to the Terms.';
    /* Required for buyers - an order can't ship without one. Optional for
       sellers, who don't receive shipments through this marketplace. */
    if ($vals['role'] !== 'seller' && (!$vals['address'] || !$vals['city'] || !$vals['province'] || !$vals['zip'])) {
        $errors[] = 'Please fill in your complete address - orders can\'t be delivered without one.';
    }

    if (empty($errors)) {
        $found = findAccountByEmail($vals['email']);
        /* Rule 8 - Account Verification: one account per verified contact
           number, enforced across BOTH Buyer and Seller tables (a DB-level
           UNIQUE constraint on cellphone_number only guards each table on
           its own - see UQ_BUYER_PHONE/UQ_SELLER_PHONE in schema.sql) */
        $foundPhone = findAccountByPhone($vals['phone']);
        /* Same cross-table gap as phone: username is NOT NULL UNIQUE per
           table, so it has to be checked across all three tables here too. */
        $foundUsername = findAccountByUsername($vals['username']);

        if ($found) {
            $errors[] = 'Email already registered.';
        } elseif ($foundPhone) {
            $errors[] = 'This cellphone number is already registered to another account. One account per verified phone number is allowed.';
        } elseif ($foundUsername) {
            $errors[] = 'That username is already taken.';
        } else {
            $hash  = hashPassword($vals['pass']);

            try {
                if ($vals['role'] === 'seller') {
                    /* Sellers have `username` (real name/login) plus an optional
                       `shop_name` buyers see instead, if set */
                    $newId = DB::insert(
                        'INSERT INTO SELLER (username,shop_name,password_hash,email,cellphone_number) VALUES (?,?,?,?,?)',
                        [$vals['username'], trim($_POST['shop_name'] ?? '') ?: null, $hash, $vals['email'], $vals['phone']]
                    );
                    $userType = 'Seller';
                } else {
                    $newId = DB::insert(
                        'INSERT INTO BUYER (username,first_name,last_name,password_hash,email,cellphone_number) VALUES (?,?,?,?,?,?)',
                        [$vals['username'], $vals['first'], $vals['last'], $hash, $vals['email'], $vals['phone']]
                    );
                    $userType = 'Buyer';
                }
            } catch (\PDOException $e) {
                /* Backstop for a race condition between the checks above and
                   this INSERT - a UNIQUE constraint (cellphone_number,
                   username, or email) catches a duplicate here if two
                   requests slipped through at the same instant */
                $errors[] = match(true) {
                    str_contains($e->getMessage(), 'cellphone_number') => 'This cellphone number is already registered to another account.',
                    str_contains($e->getMessage(), 'username')         => 'That username is already taken.',
                    default => 'Could not create your account (duplicate email, username, or phone). Please try again.',
                };
            }

            if (empty($errors)) {
                /* Optional address -> ADDRESSES table (user_id/user_type per updated schema) */
                if ($vals['address'] || $vals['city']) {
                    DB::query(
                        'INSERT INTO ADDRESSES (user_id, user_type, street_address, city, province, zip_code, is_default)
                         VALUES (?,?,?,?,?,?,1)',
                        [$newId, $userType, $vals['address'] ?: '-', $vals['city'] ?: '-', $vals['province'] ?: '-', $vals['zip'] ?: '0000']
                    );
                }

                $notifCol = $vals['role'] === 'seller' ? 'seller_id' : 'buyer_id';
                DB::query("INSERT INTO NOTIFICATIONS ($notifCol,title,message,notification_type) VALUES (?,?,?,?)",
                    [$newId,'Welcome to ThriftBid!','Your account has been created.','SYSTEM']);

                /* Communication / Account Verification: email OTP instead of
                   an immediate login. is_verified stays 0 until the buyer or
                   seller enters the 6-digit code just emailed to them via
                   generateAndSendOtp() (includes/otp.php) - verified on
                   verify-email.php, which is where the account actually
                   logs in for the first time. */
                generateAndSendOtp($userType, $newId, $vals['email'], $vals['first'] ?: $vals['username'], 'Registration');

                $_SESSION['pending_verification'] = [
                    'type'  => $userType,          /* 'Buyer' | 'Seller' */
                    'id'    => $newId,
                    'email' => $vals['email'],
                    'name'  => $vals['first'] ?: $vals['username'],
                ];

                header('Location: verify-email.php'); exit;
            }
        }
    }
}
renderHeadRoot('Create Account');
?>
<body class="tb-auth-page">
<header style="background:var(--clr-coral);padding:14px 40px">
  <span style="font-family:'Hanken Grotesk',sans-serif;font-size:20px;font-weight:800;color:#fff;letter-spacing:-0.02em">ThriftBid</span>
</header>
<div class="tb-auth-center" style="padding:32px 16px">
  <div class="tb-auth-card tb-auth-card-wide tb-fade-in">
    <div style="text-align:center;margin-bottom:24px">
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text)">Create Account</h1>
      <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-top:5px">Join ThriftBid as a buyer or seller.</p>
    </div>
    <?php if ($errors): ?>
    <div class="tb-alert tb-alert-error show" style="margin-bottom:16px">
      <div><span class="material-symbols-outlined icon-sm" style="margin-right:6px;flex-shrink:0">error</span>
        <?php foreach($errors as $e): ?><p><?= htmlspecialchars($e) ?></p><?php endforeach; ?>
      </div>
    </div>
    <?php endif; ?>
    <form method="POST" style="display:flex;flex-direction:column;gap:0">
      <!-- Role -->
      <div class="tb-form-group">
        <label class="tb-label">I want to</label>
        <div class="grid grid-cols-2 gap-3">
          <?php foreach(['buyer'=>['Buy & Bid','shopping_bag'],'seller'=>['Sell Items','storefront']] as $r=>[$lbl,$ico]): ?>
          <label style="cursor:pointer">
            <input type="radio" name="role" value="<?=$r?>" style="display:none" id="r_<?=$r?>" <?=($vals['role']??'buyer')===$r?'checked':''?> onchange="styleRoles()">
            <div id="rc_<?=$r?>" style="padding:12px;border:2px solid <?=($vals['role']??'buyer')===$r?'var(--clr-coral)':'var(--clr-outline)'?>;border-radius:var(--radius-sm);text-align:center;background:<?=($vals['role']??'buyer')===$r?'rgba(255,107,107,0.04)':''?>">
              <span class="material-symbols-outlined icon-md" style="color:var(--clr-tertiary);display:block;margin-bottom:4px"><?=$ico?></span>
              <p style="font-weight:700;font-size:var(--fs-label-md)"><?=$lbl?></p>
            </div>
          </label>
          <?php endforeach; ?>
        </div>
      </div>
      <!-- Names -->
      <div class="grid grid-cols-2 gap-4">
        <div class="tb-form-group"><label class="tb-label">First Name</label><input class="tb-input" name="first_name" type="text" placeholder="First" value="<?= htmlspecialchars($vals['first']??'') ?>" required></div>
        <div class="tb-form-group"><label class="tb-label">Last Name</label><input class="tb-input" name="last_name" type="text" placeholder="Last" value="<?= htmlspecialchars($vals['last']??'') ?>" required></div>
      </div>
      <div class="tb-form-group">
        <label class="tb-label">Username</label>
        <input class="tb-input" name="username" type="text" placeholder="e.g. ana_delacruz" pattern="[a-zA-Z0-9_]{3,32}" maxlength="32" value="<?= htmlspecialchars($vals['username']??'') ?>" required>
        <p class="opt" style="font-size:11px;color:var(--clr-tertiary);margin-top:4px">3-32 characters, letters/numbers/underscores only. Must be unique across all accounts.</p>
      </div>
      <div class="tb-form-group"><label class="tb-label">Email Address</label><input class="tb-input" name="email" type="email" placeholder="you@email.com" value="<?= htmlspecialchars($vals['email']??'') ?>" required></div>
      <div class="tb-form-group">
        <label class="tb-label">Cellphone Number</label>
        <input class="tb-input" name="phone" type="tel" placeholder="09XXXXXXXXX" pattern="09[0-9]{9}" value="<?= htmlspecialchars($vals['phone']??'') ?>" required>
        <p class="opt" style="font-size:11px;color:var(--clr-tertiary);margin-top:4px">One account per phone number. This can't be reused across a buyer and a seller account.</p>
      </div>

      <div class="tb-form-group" id="shopNameField" style="display:<?= ($vals['role']??'buyer')==='seller'?'block':'none' ?>">
        <label class="tb-label">Shop Name <span class="opt">(optional — shown to buyers instead of your name)</span></label>
        <input class="tb-input" name="shop_name" type="text" maxlength="100" placeholder="e.g. Leila's Closet" value="<?= htmlspecialchars($_POST['shop_name']??'') ?>">
      </div>

      <!-- Address, feeds the ADDRESSES table. Required for buyers - an
           order can't ship without one; optional for sellers, who don't
           receive shipments through this. -->
      <p class="tb-label" style="margin-top:4px">Address <span id="addressSectionNote" style="font-weight:400;color:var(--clr-tertiary);text-transform:none;letter-spacing:0"><?= ($vals['role']??'buyer')==='seller' ? 'Optional for sellers.' : ':' ?></span></p>
      <div class="grid grid-cols-2 gap-4">
        <div class="tb-form-group"><label class="tb-label">Street Address</label><input class="tb-input" id="addr_street" name="address" type="text" value="<?= htmlspecialchars($vals['address']??'') ?>" <?= ($vals['role']??'buyer')!=='seller'?'required':'' ?>></div>
        <div class="tb-form-group"><label class="tb-label">City</label><input class="tb-input" id="addr_city" name="city" type="text" value="<?= htmlspecialchars($vals['city']??'') ?>" <?= ($vals['role']??'buyer')!=='seller'?'required':'' ?>></div>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div class="tb-form-group"><label class="tb-label">Province</label><input class="tb-input" id="addr_province" name="province" type="text" value="<?= htmlspecialchars($vals['province']??'') ?>" <?= ($vals['role']??'buyer')!=='seller'?'required':'' ?>></div>
        <div class="tb-form-group"><label class="tb-label">ZIP Code</label><input class="tb-input" id="addr_zip" name="zip" type="text" value="<?= htmlspecialchars($vals['zip']??'') ?>" <?= ($vals['role']??'buyer')!=='seller'?'required':'' ?>></div>
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div class="tb-form-group">
          <label class="tb-label">Password</label>
          <div style="position:relative"><input class="tb-input" id="pw1" name="password" type="password" placeholder="Min. 8 chars" style="padding-right:42px" required>
          <button type="button" onclick="togglePw('pw1',this)" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:var(--clr-tertiary)"><span class="material-symbols-outlined icon-sm">visibility</span></button></div>
        </div>
        <div class="tb-form-group">
          <label class="tb-label">Confirm Password</label>
          <div style="position:relative"><input class="tb-input" id="pw2" name="confirm_password" type="password" placeholder="Repeat password" style="padding-right:42px" required>
          <button type="button" onclick="togglePw('pw2',this)" style="position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:var(--clr-tertiary)"><span class="material-symbols-outlined icon-sm">visibility</span></button></div>
        </div>
      </div>
      <div style="display:flex;align-items:flex-start;gap:8px;margin-bottom:16px">
        <input type="checkbox" name="terms" id="terms" value="1" <?= !empty($vals['terms'])?'checked':'' ?> style="margin-top:3px;accent-color:var(--clr-coral)">
        <label for="terms" style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">I agree to the <a href="#" style="color:var(--clr-coral)">Terms</a> and <a href="#" style="color:var(--clr-coral)">Privacy Policy</a></label>
      </div>
      <button type="submit" class="btn btn-primary btn-full" style="height:46px;font-size:var(--fs-body-md)">Create Account</button>
    </form>
    <p style="text-align:center;margin-top:20px;font-size:var(--fs-label-md);color:var(--clr-tertiary)">Already have an account? <a href="login.php" style="color:var(--clr-coral);font-weight:700">Sign in</a></p>
  </div>
</div>
<script>
function togglePw(id,btn){const i=document.getElementById(id);const ic=btn.querySelector('.material-symbols-outlined');i.type=i.type==='password'?'text':'password';ic.textContent=i.type==='password'?'visibility':'visibility_off';}
function styleRoles(){['buyer','seller'].forEach(r=>{const c=document.getElementById('r_'+r).checked;document.getElementById('rc_'+r).style.borderColor=c?'var(--clr-coral)':'var(--clr-outline)';document.getElementById('rc_'+r).style.background=c?'rgba(255,107,107,0.04)':''});document.getElementById('shopNameField').style.display=document.getElementById('r_seller').checked?'block':'none';
const isBuyer = document.getElementById('r_buyer').checked;
['addr_street','addr_city','addr_province','addr_zip'].forEach(id=>document.getElementById(id).required=isBuyer);
document.getElementById('addressSectionNote').textContent = isBuyer ? ':' : 'Optional for sellers.';
}
</script>
</body></html>