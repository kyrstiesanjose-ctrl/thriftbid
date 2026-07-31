<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/otp.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? $user['id']; /* session row IS the buyer row */

/* Delivery address is required before payment - not at registration,
   since forcing an address on someone who's just browsing/bidding is bad
   UX, but by the time real money is about to move there has to be
   somewhere to ship to. Snapshotted onto the order at payment time (see
   after_payment_insert_create_transaction, schema.sql), not re-read live
   from ADDRESSES later - a buyer editing their address afterward must
   not retroactively change what a past order says it shipped to. */
$defaultAddress = DB::fetch('SELECT * FROM ADDRESSES WHERE user_id=? AND user_type="Buyer" AND is_default=1', [$buyerId]);
$addressErrors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_address'])) {
    $street   = trim($_POST['street'] ?? '');
    $city     = trim($_POST['city'] ?? '');
    $province = trim($_POST['province'] ?? '');
    $zip      = trim($_POST['zip'] ?? '');
    if (!$street || !$city || !$province || !$zip) {
        $addressErrors[] = 'Please fill in every address field.';
    } else {
        DB::query('UPDATE ADDRESSES SET is_default=0 WHERE user_id=? AND user_type="Buyer"', [$buyerId]);
        DB::query(
            'INSERT INTO ADDRESSES (user_id, user_type, street_address, city, province, zip_code, is_default) VALUES (?,?,?,?,?,?,1)',
            [$buyerId, 'Buyer', $street, $city, $province, $zip]
        );
        $defaultAddress = DB::fetch('SELECT * FROM ADDRESSES WHERE user_id=? AND user_type="Buyer" AND is_default=1', [$buyerId]);
    }
}

$orderId    = (int)($_GET['order'] ?? 0);
$itemsParam = trim($_GET['items'] ?? '');
$mode       = $orderId ? 'single' : 'cart';

$errorMsg = '';
$rows = []; /* normalized: ['listing_id','seller_id','seller_name','title','cover_image','price','order_id' (if already created)] */

if ($mode === 'single') {
    $order = DB::fetch(
        "SELECT o.*, l.title, l.price, l.listing_id, COALESCE(se.shop_name, se.username) AS seller_name,
                (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER se  ON o.seller_id=se.seller_id
         WHERE o.order_id=? AND o.buyer_id=?",
        [$orderId, $buyerId]
    );
    if (!$order) { header('Location: orders.php?tab=topay'); exit; }

    /* Amount owed is the winning bid if this order came from an auction,
       otherwise the listing's fixed price */
    $winBid = DB::fetch(
        'SELECT MAX(b.bid_amount) as max_bid FROM BIDDINGS b
         JOIN AUCTIONS a ON b.auction_id=a.auction_id
         WHERE a.listing_id=? AND b.buyer_id=? AND b.is_deleted=0',
        [$order['listing_id'], $buyerId]
    );
    $amount = (float)($winBid['max_bid'] ?? $order['price'] ?? 0);
    $rows[] = [
        'order_id' => $orderId, 'listing_id' => $order['listing_id'], 'seller_id' => $order['seller_id'],
        'seller_name' => $order['seller_name'], 'title' => $order['title'],
        'cover_image' => $order['cover_image'], 'price' => $amount,
    ];
} else {
    $listingIds = array_filter(array_map('intval', explode(',', $itemsParam)));
    if (empty($listingIds)) { header('Location: orders.php?tab=cart'); exit; }

    $placeholders = implode(',', array_fill(0, count($listingIds), '?'));
    $cartRows = DB::fetchAll(
        "SELECT l.listing_id, l.title, l.price, l.is_active, l.seller_id, COALESCE(se.shop_name, se.username) AS seller_name,
                (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
         FROM CART_ITEMS ci
         JOIN LISTINGS l ON ci.listing_id=l.listing_id
         JOIN SELLER se ON l.seller_id=se.seller_id
         WHERE ci.buyer_id=? AND ci.listing_id IN ($placeholders)",
        array_merge([$buyerId], $listingIds)
    );

    /* Sold-out or deactivated cart items are silently dropped rather than
       erroring out, so checkout can still proceed with whatever's left */
    $cartRows = array_filter($cartRows, fn($r) => (int)$r['is_active'] === 1);
    if (empty($cartRows)) { header('Location: orders.php?tab=cart&sold=1'); exit; }

    foreach ($cartRows as $r) {
        $rows[] = [
            'order_id' => null, 'listing_id' => $r['listing_id'], 'seller_id' => $r['seller_id'],
            'seller_name' => $r['seller_name'], 'title' => $r['title'],
            'cover_image' => $r['cover_image'], 'price' => (float)$r['price'],
        ];
    }
    $amount = array_sum(array_column($rows, 'price'));
}

/* Grouped by seller for display, so a multi-shop cart shows one block per store */
$bySeller = [];
foreach ($rows as $r) { $bySeller[$r['seller_id']]['seller_name'] = $r['seller_name']; $bySeller[$r['seller_id']]['items'][] = $r; }

/* Simulated GCash / Bank Transfer checkout with Email OTP authorization.
   Step 1 (request_otp) - validate the chosen payment method, email a
     6-digit code, stash the method/number in session, and show the
     "Enter OTP" screen instead of charging anything yet.
   Step 2 (confirm_otp) - verify the code; ONLY on success does the
     explicit DB transaction below run. */
$otpStage  = false; /* true = render the "enter OTP" screen instead of the payment form */
$otpCtx    = $_SESSION['checkout_otp'] ?? null;
$sameCtx   = $otpCtx && $otpCtx['buyer_id'] === $buyerId && $otpCtx['mode'] === $mode
             && $otpCtx['order_id'] === $orderId && $otpCtx['items'] === $itemsParam;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['request_otp'])) {
    $method   = $_POST['payment_method'] ?? 'GCash';
    $gcashNum = trim($_POST['gcash_number'] ?? '');
    $errors   = [];

    if (!$defaultAddress) {
        $errors[] = 'Add a delivery address before paying.';
    }
    if ($method === 'GCash' && (!$gcashNum || !preg_match('/^09\d{9}$/', $gcashNum))) {
        $errors[] = 'Enter a valid GCash number (09XXXXXXXXX).';
    }

    if (empty($errors)) {
        $_SESSION['checkout_otp'] = [
            'buyer_id' => $buyerId, 'mode' => $mode, 'order_id' => $orderId, 'items' => $itemsParam,
            'method'   => $method === 'GCash' ? 'GCash' : 'Bank', 'gcash' => $gcashNum,
        ];
        generateAndSendOtp('Buyer', $buyerId, $user['email'], $user['first_name'] ?? $user['username'], 'Payment', $mode === 'single' ? $orderId : null);
        $otpStage = true;
        $otpCtx   = $_SESSION['checkout_otp'];
        $sameCtx  = true;
    } else {
        $errorMsg = implode(' ', $errors);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['resend_otp']) && $sameCtx) {
    generateAndSendOtp('Buyer', $buyerId, $user['email'], $user['first_name'] ?? $user['username'], 'Payment', $mode === 'single' ? $orderId : null);
    $otpStage = true;
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['confirm_otp'])) {
    if (!$sameCtx) {
        $errorMsg = 'Your checkout session expired. Please choose your payment method again.';
    } else {
        $code = trim($_POST['otp'] ?? '');
        if (!verifyOtp('Buyer', $buyerId, 'Payment', $code, $mode === 'single' ? $orderId : null)) {
            $errorMsg = 'That code is incorrect or has expired.';
            $otpStage = true;
        } else {
            $method   = $otpCtx['method'];
            $gcashNum = $otpCtx['gcash'];

            /* ACID: Atomicity - every ORDER/PAYMENT/TRANSACTIONS/CART_ITEMS
               write for this checkout commits together or not at all */
            $pdo = DB::get();
            $pdo->beginTransaction();
            try {
                foreach ($rows as $r) {
                    $gatewayRef = 'SIM-' . strtoupper(bin2hex(random_bytes(6)));

                    if ($mode === 'single') {
                        DB::callProc('sp_pay_for_order', [$r['order_id'], $r['listing_id'], $buyerId, $r['price'], $method, $gatewayRef]);
                        $newOrderId = $r['order_id'];
                    } else {
                        $newOrderId = DB::callProcGetLastId('sp_checkout_listing',
                            [$r['listing_id'], $buyerId, $r['seller_id'], $r['price'], $method, $gatewayRef]
                        );
                    }

                    DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
                        [$r['seller_id'], 'Payment Received!', 'Payment of ' . convertCurrency($r['price']) . ' received for order #' . $newOrderId . '. Please ship within 48 hours.', 'ORDER']);
                }
                $pdo->commit();
                unset($_SESSION['checkout_otp']);

                /* Send the payment-confirmation emails right now, instead of
                   waiting on layout.php's opportunistic flush on some later
                   page load - that dependency turned out to be unreliable. */
                flushEmailQueue(3);
            } catch (\Throwable $e) {
                $pdo->rollBack();
                $errorMsg = 'Something went wrong processing your payment: ' . $e->getMessage();
                $otpStage = true;
            }

            if (empty($errorMsg)) {
                header('Location: orders.php?tab=receive&paid=1'); exit;
            }
        }
    }
}

$itemCount = count($rows);
renderHead($mode === 'single' ? 'Checkout - Order #' . $orderId : 'Checkout - ' . $itemCount . ' item' . ($itemCount !== 1 ? 's' : ''));
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('orders'); ?>

<main style="flex:1">
  <div style="max-width:900px;margin:0 auto;padding:28px var(--sp-margin-desktop) 80px">

    <a href="orders.php?tab=<?= $mode==='single'?'topay':'cart' ?>" style="display:inline-flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:20px;text-decoration:none">
      <span class="material-symbols-outlined icon-sm">arrow_back</span>Back to <?= $mode==='single'?'Orders':'Cart' ?>
    </a>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">

      <!-- Order summary -->
      <div style="display:flex;flex-direction:column;gap:16px">
        <div class="tb-card tb-card-body">
          <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:16px">Order Summary</h2>

          <?php foreach ($bySeller as $shop): ?>
          <div style="margin-bottom:16px;padding-bottom:16px;border-bottom:1px solid var(--clr-outline)">
            <p style="font-size:var(--fs-label-sm);font-weight:700;color:var(--clr-tertiary);margin-bottom:10px">
              <span class="material-symbols-outlined icon-sm" style="vertical-align:middle">storefront</span> <?= htmlspecialchars($shop['seller_name']) ?>
            </p>
            <?php foreach ($shop['items'] as $it): ?>
            <div style="display:flex;gap:14px;margin-bottom:10px">
              <div style="width:56px;height:56px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
                <?php if ($it['cover_image']): ?><img src="<?= htmlspecialchars($it['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
              </div>
              <div style="flex:1">
                <p style="font-weight:600;font-size:var(--fs-label-md);color:var(--clr-text)"><?= htmlspecialchars($it['title']) ?></p>
                <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= convertCurrency($it['price']) ?></p>
              </div>
            </div>
            <?php endforeach; ?>
          </div>
          <?php endforeach; ?>

          <div style="padding-top:4px;display:flex;flex-direction:column;gap:6px;font-size:var(--fs-label-md)">
            <div style="display:flex;justify-content:space-between"><span style="color:var(--clr-tertiary)">Item<?= $itemCount!==1?'s':'' ?> Total (<?= $itemCount ?>)</span><span><?= convertCurrency($amount) ?></span></div>
            <div style="display:flex;justify-content:space-between"><span style="color:var(--clr-tertiary)">Platform Fee</span><span style="color:var(--clr-success)">Free</span></div>
            <div style="display:flex;justify-content:space-between"><span style="color:var(--clr-tertiary)">Shipping</span><span style="color:var(--clr-tertiary)">To be arranged</span></div>
            <div style="display:flex;justify-content:space-between;font-weight:700;font-size:var(--fs-body-md);border-top:1px solid var(--clr-outline);padding-top:8px;margin-top:4px">
              <span>Total Due</span><span style="color:var(--clr-coral)"><?= convertCurrency($amount) ?></span>
            </div>
          </div>
          <?php if (count($bySeller) > 1): ?>
          <p style="font-size:11px;color:var(--clr-tertiary);margin-top:10px">Items from <?= count($bySeller) ?> different sellers will still be created as <?= $itemCount ?> separate orders.</p>
          <?php endif; ?>
        </div>

        <!-- Delivery address: required before payment, see the note near
             $defaultAddress above for why this is snapshotted, not live. -->
        <div class="tb-card tb-card-body">
          <p class="tb-section-label">Delivery Address</p>
          <?php if ($addressErrors): ?>
          <div class="tb-alert tb-alert-error show" style="margin:8px 0"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars(implode(' ', $addressErrors)) ?></div>
          <?php endif; ?>
          <?php if ($defaultAddress && !isset($_GET['edit_address'])): ?>
          <p style="font-size:var(--fs-label-md);color:var(--clr-text);margin-top:6px">
            <?= htmlspecialchars($defaultAddress['street_address']) ?>, <?= htmlspecialchars($defaultAddress['city']) ?>,
            <?= htmlspecialchars($defaultAddress['province']) ?> <?= htmlspecialchars($defaultAddress['zip_code']) ?>
          </p>
          <a href="?<?= http_build_query(array_merge($_GET, ['edit_address' => 1])) ?>" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">Change address</a>
          <?php else: ?>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin:6px 0 12px">
            <?= $defaultAddress ? 'Update your delivery address:' : 'Add a delivery address to continue - the seller needs to know where to ship this.' ?>
          </p>
          <form method="POST" style="display:flex;flex-direction:column;gap:10px">
            <input type="hidden" name="save_address" value="1">
            <input class="tb-input" name="street" type="text" placeholder="Street address" value="<?= htmlspecialchars($defaultAddress['street_address'] ?? '') ?>" required>
            <div style="display:flex;gap:10px">
              <input class="tb-input" name="city" type="text" placeholder="City" value="<?= htmlspecialchars($defaultAddress['city'] ?? '') ?>" required>
              <input class="tb-input" name="province" type="text" placeholder="Province" value="<?= htmlspecialchars($defaultAddress['province'] ?? '') ?>" required>
              <input class="tb-input" name="zip" type="text" placeholder="ZIP" style="max-width:100px" value="<?= htmlspecialchars($defaultAddress['zip_code'] ?? '') ?>" required>
            </div>
            <button type="submit" class="btn btn-primary btn-sm" style="align-self:flex-start">Save Address</button>
          </form>
          <?php endif; ?>
        </div>

        <!-- Currency display live rate-->
        <div class="tb-card tb-card-body">
          <p class="tb-section-label">View total in another currency</p>
          <div style="display:flex;gap:8px;margin-bottom:8px">
            <?php foreach (['PHP','USD','KRW'] as $cur): ?>
            <button type="button" onclick="showConverted('<?=$cur?>')" class="btn btn-ghost btn-sm"><?=$cur?></button>
            <?php endforeach; ?>
          </div>
          <p id="convertedAmt" style="font-size:var(--fs-body-md);font-weight:700;color:var(--clr-coral);min-height:22px"></p>
        </div>

        <div style="background:var(--clr-info-bg);border:1px solid #b8d4e8;border-left:3px solid var(--clr-info);border-radius:var(--radius-sm);padding:12px 14px;font-size:var(--fs-label-sm);color:var(--clr-info)">
          <strong>Escrow Protection:</strong> Payment is held securely until you confirm delivery. Your money is safe.
        </div>
      </div>

      <!-- Payment form / OTP step -->
      <div class="tb-card tb-card-body">

        <?php if ($errorMsg): ?>
        <div class="tb-alert tb-alert-error show" style="margin-bottom:14px"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div>
        <?php endif; ?>

        <?php if ($otpStage && $sameCtx): ?>
        <!-- STEP 2: Enter OTP -->
        <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:8px">Confirm Your Payment</h2>
        <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:18px">
          Paying via <strong><?= htmlspecialchars($otpCtx['method']) ?></strong><?= $otpCtx['method']==='GCash' ? ' (' . htmlspecialchars($otpCtx['gcash']) . ')' : '' ?>.
          We emailed a 6-digit code to <strong><?= htmlspecialchars($user['email']) ?></strong> to authorize this charge of <?= convertCurrency($amount) ?>.
        </p>

        <?php
        /* DEV MODE: see DEV_SHOW_OTP in config.php. Queried fresh so it
           reflects the current code whether this is the first send or a resend. */
        $devOtpCode = null;
        if (defined('DEV_SHOW_OTP') && DEV_SHOW_OTP) {
            $devRow = DB::fetch(
                'SELECT otp_code FROM EMAIL_OTPS WHERE owner_type="Buyer" AND owner_id=? AND purpose="Payment" ' .
                ($mode === 'single' ? 'AND related_order_id=? ' : 'AND related_order_id IS NULL ') .
                'AND is_used=0 ORDER BY otp_id DESC LIMIT 1',
                $mode === 'single' ? [$buyerId, $orderId] : [$buyerId]
            );
            $devOtpCode = $devRow['otp_code'] ?? null;
        }
        ?>
        <?php if ($devOtpCode): ?>
        <div style="background:#fff8e1;border:1px dashed #d4a017;border-radius:8px;padding:10px 14px;margin-bottom:16px;text-align:center">
          <p style="font-size:10px;font-weight:800;letter-spacing:0.06em;color:#8a6d00;text-transform:uppercase;margin-bottom:4px">Dev Mode — Real Email Not Configured</p>
          <p style="font-size:24px;font-weight:800;letter-spacing:4px;color:#1a1a1a">Code: <?= htmlspecialchars($devOtpCode) ?></p>
        </div>
        <?php endif; ?>

        <form method="POST" style="display:flex;flex-direction:column;gap:16px">
          <input type="hidden" name="confirm_otp" value="1">
          <div class="tb-form-group">
            <label class="tb-label">Verification Code</label>
            <input class="tb-input" name="otp" type="text" inputmode="numeric" pattern="\d{6}" maxlength="6" placeholder="000000" style="letter-spacing:8px;font-size:22px;text-align:center;font-weight:700" required autofocus>
          </div>
          <button type="submit" class="btn btn-primary btn-full btn-lg">
            <span class="material-symbols-outlined icon-sm">lock</span>
            Confirm Payment - <?= convertCurrency($amount) ?>
          </button>
        </form>
        <form method="POST" style="margin-top:10px">
          <input type="hidden" name="resend_otp" value="1">
          <button type="submit" class="btn btn-ghost btn-full btn-sm">Resend Code</button>
        </form>
        <p style="font-size:11px;color:var(--clr-tertiary);text-align:center;margin-top:12px">Simulation Mode: no real money moves. This OTP step stands in for the bank/GCash authorization step.</p>

        <?php else: ?>
        <!-- STEP 1: Choose payment method -->
        <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:18px">Payment Method</h2>

        <form method="POST" style="display:flex;flex-direction:column;gap:16px">
          <input type="hidden" name="request_otp" value="1">
          <div>
            <label class="tb-label">Choose Method</label>
            <div class="grid grid-cols-2 gap-3">
              <?php foreach ([
                ['GCash','G','#007DFE','GCash','Instant transfer'],
                ['Bank','account_balance','','Bank Transfer','BDO, BPI, UnionBank'],
              ] as [$val,$icon,$color,$name,$sub]): ?>
              <label style="cursor:pointer">
                <input type="radio" name="payment_method" value="<?=$val?>" style="display:none" id="pm_<?=$val?>" <?=$val==='GCash'?'checked':''?> onchange="updatePaymentUI()">
                <div id="pm_card_<?=$val?>" style="padding:14px;border:2px solid var(--clr-outline);border-radius:var(--radius-sm);text-align:center;transition:border-color var(--transition);<?=$val==='GCash'?'border-color:var(--clr-coral);background:rgba(255,107,107,0.03)':''?>">
                  <?php if ($color): ?>
                  <div style="width:36px;height:36px;background:<?=$color?>;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 6px;color:#fff;font-weight:900;font-size:14px"><?=$icon?></div>
                  <?php else: ?>
                  <span class="material-symbols-outlined" style="font-size:28px;color:var(--clr-tertiary);display:block;margin-bottom:6px"><?=$icon?></span>
                  <?php endif; ?>
                  <p style="font-weight:700;font-size:var(--fs-label-md)"><?=$name?></p>
                  <p style="font-size:11px;color:var(--clr-tertiary)"><?=$sub?></p>
                </div>
              </label>
              <?php endforeach; ?>
            </div>
          </div>

          <div id="gcashFields">
            <label class="tb-label">GCash Number</label>
            <input class="tb-input" type="tel" name="gcash_number" placeholder="09XXXXXXXXX" pattern="09[0-9]{9}" maxlength="11">
            <p style="font-size:var(--fs-label-sm);color:var(--clr-info);margin-top:6px;background:var(--clr-info-bg);padding:8px 10px;border-radius:var(--radius-sm)">
              <strong>Simulation Mode:</strong> Enter any valid 09XXXXXXXXX number. No real money transferred.
            </p>
          </div>

          <button type="submit" class="btn btn-primary btn-full btn-lg" <?= !$defaultAddress ? 'disabled title="Add a delivery address above first"' : '' ?>>
            <span class="material-symbols-outlined icon-sm">mail</span>
            Send Verification Code - <?= convertCurrency($amount) ?>
          </button>
        </form>

        <p style="font-size:11px;color:var(--clr-tertiary);text-align:center;margin-top:12px">Your payment is protected by ThriftBid until delivery is confirmed. You'll confirm with a one-time code emailed to you before anything is charged.</p>
        <?php endif; ?>
      </div>

    </div>
  </div>
</main>
<?php renderFooter(); ?>
<script>
const LIVE_AMOUNT_PHP = <?= (float)$amount ?>;
const LIVE_RATES = <?= json_encode(getLiveCurrencyRates()) ?>;
const SYMS = {PHP:'₱',USD:'$',KRW:'₩'};
function showConverted(c){
  const r = LIVE_AMOUNT_PHP * (LIVE_RATES[c] || 1);
  document.getElementById('convertedAmt').textContent = SYMS[c] + (c==='KRW' ? Math.round(r).toLocaleString() : r.toFixed(2)) + ' ' + c;
}
function updatePaymentUI(){
  ['GCash','Bank'].forEach(v=>{
    const checked=document.getElementById('pm_'+v)?.checked;
    const card=document.getElementById('pm_card_'+v);
    if(!card) return;
    card.style.borderColor=checked?'var(--clr-coral)':'var(--clr-outline)';
    card.style.background=checked?'rgba(255,107,107,0.03)':'';
  });
  const gf = document.getElementById('gcashFields');
  if (gf) gf.style.display=document.getElementById('pm_GCash')?.checked?'':'none';
}
</script>
</body></html>