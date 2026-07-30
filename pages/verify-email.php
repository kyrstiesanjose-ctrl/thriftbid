<?php
/* ThriftBid - pages/verify-email.php (place alongside register.php / login.php)
   Step 2 of registration: enter the 6-digit code emailed by
   generateAndSendOtp() during register.php. On success, flips
   is_verified=1 on the account and logs the person in. */
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/otp.php';
require_once __DIR__ . '/../includes/layout.php';

if (isLoggedIn()) { header('Location: ./customer/home.php'); exit; }

$pending = $_SESSION['pending_verification'] ?? null;
if (!$pending) { header('Location: register.php'); exit; }

$error = ''; $resent = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['resend'])) {
        generateAndSendOtp($pending['type'], $pending['id'], $pending['email'], $pending['name'], 'Registration');
        $resent = true;
    } else {
        $code = trim($_POST['otp'] ?? '');
        if (!preg_match('/^\d{6}$/', $code)) {
            $error = 'Enter the 6-digit code from your email.';
        } elseif (!verifyOtp($pending['type'], $pending['id'], 'Registration', $code)) {
            $error = 'That code is incorrect or has expired. Please try again or resend a new one.';
        } else {
            $table = strtoupper($pending['type']); /* BUYER | SELLER */
            $idCol = $pending['type'] === 'Seller' ? 'seller_id' : 'buyer_id';
            DB::query("UPDATE $table SET is_verified=1 WHERE $idCol=?", [$pending['id']]);

            $row = DB::fetch("SELECT * FROM $table WHERE $idCol=?", [$pending['id']]);
            unset($_SESSION['pending_verification']);
            loginUser($row, strtolower($pending['type']));

            header('Location: ' . ($pending['type'] === 'Seller' ? './seller/dashboard.php' : './customer/home.php'));
            exit;
        }
    }
}
renderHeadRoot('Verify your email');

/* DEV MODE: pull the actual current code so it can be shown on-screen.
   See DEV_SHOW_OTP in config.php for why this exists and how to turn it
   off. Queried fresh here (not passed from register.php) so it's
   correct whether this is the first load or after a Resend. */
$devOtpCode = null;
if (defined('DEV_SHOW_OTP') && DEV_SHOW_OTP) {
    $devRow = DB::fetch(
        'SELECT otp_code FROM EMAIL_OTPS WHERE owner_type=? AND owner_id=? AND purpose="Registration" AND is_used=0 ORDER BY otp_id DESC LIMIT 1',
        [$pending['type'], $pending['id']]
    );
    $devOtpCode = $devRow['otp_code'] ?? null;
}
?>
<body class="tb-auth-page">
<header style="background:var(--clr-coral);padding:14px 40px">
  <span style="font-family:'Hanken Grotesk',sans-serif;font-size:20px;font-weight:800;color:#fff;letter-spacing:-0.02em">ThriftBid</span>
</header>
<div class="tb-auth-center">
  <div class="tb-auth-card tb-fade-in">
    <div style="text-align:center;margin-bottom:24px">
      <span class="material-symbols-outlined" style="font-size:44px;color:var(--clr-coral)">mark_email_read</span>
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text);margin-top:8px">Verify your email</h1>
      <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-top:6px">
        We sent a 6-digit code to <strong><?= htmlspecialchars($pending['email']) ?></strong>. It expires in 5 minutes.
      </p>
    </div>

    <?php if ($devOtpCode): ?>
    <div style="background:#fff8e1;border:1px dashed #d4a017;border-radius:8px;padding:10px 14px;margin-bottom:16px;text-align:center">
      <p style="font-size:10px;font-weight:800;letter-spacing:0.06em;color:#8a6d00;text-transform:uppercase;margin-bottom:4px">Dev Mode — Real Email Not Configured</p>
      <p style="font-size:24px;font-weight:800;letter-spacing:4px;color:#1a1a1a">Code: <?= htmlspecialchars($devOtpCode) ?></p>
    </div>
    <?php endif; ?>

    <?php if ($error):  ?><div class="tb-alert tb-alert-error show" style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($error) ?></div><?php endif; ?>
    <?php if ($resent): ?><div class="tb-alert tb-alert-success show" style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">check_circle</span>A new code has been sent.</div><?php endif; ?>

    <form method="POST" style="display:flex;flex-direction:column;gap:16px">
      <div class="tb-form-group">
        <label class="tb-label">Verification Code</label>
        <input class="tb-input" name="otp" type="text" inputmode="numeric" pattern="\d{6}" maxlength="6" placeholder="000000" style="letter-spacing:8px;font-size:22px;text-align:center;font-weight:700" required autofocus>
      </div>
      <button type="submit" class="btn btn-primary btn-full" style="height:46px;font-size:var(--fs-body-md)">Verify & Continue</button>
    </form>
    <form method="POST" style="margin-top:12px">
      <input type="hidden" name="resend" value="1">
      <button type="submit" class="btn btn-ghost btn-full btn-sm">Resend Code</button>
    </form>
  </div>
</div>
</body></html>