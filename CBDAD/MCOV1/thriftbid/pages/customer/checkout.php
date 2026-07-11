<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$user    = currentUser();
$buyer   = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$user['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;
$orderId = (int)($_GET['order'] ?? 0);

if (!$orderId || !$buyerId) { header('Location: orders.php?tab=topay'); exit; }

$order = DB::fetch(
    'SELECT o.*,l.title,l.price,l.image_url,u.username as seller_name
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN SELLER s   ON o.seller_id=s.seller_id
     JOIN USERS u    ON s.user_id=u.user_id
     WHERE o.order_id=? AND o.buyer_id=?',
    [$orderId, $buyerId]
);
if (!$order) { header('Location: orders.php?tab=topay'); exit; }

// Determine amount: winning bid or fixed price
$winBid = DB::fetch(
    'SELECT MAX(b.bid_amount) as max_bid FROM BIDDINGS b
     JOIN AUCTIONS a ON b.auction_id=a.auction_id
     WHERE a.listing_id=? AND b.buyer_id=?',
    [$order['listing_id'], $buyerId]
);
$amount   = (float)($winBid['max_bid'] ?? $order['price'] ?? 0);
$errorMsg = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $method   = $_POST['payment_method'] ?? 'GCash';
    $gcashNum = trim($_POST['gcash_number'] ?? '');
    $currency = $_POST['currency'] ?? 'PHP';
    $errors   = [];

    if ($method === 'GCash' && (!$gcashNum || !preg_match('/^09\d{9}$/', $gcashNum))) {
        $errors[] = 'Enter a valid GCash number (09XXXXXXXXX).';
    }

    if (empty($errors)) {
        $paymentId = DB::insert(
            'INSERT INTO PAYMENTS (payment_method,amount_paid,payment_status,order_id) VALUES (?,?,"Completed",?)',
            [$method === 'GCash' ? 'GCash' : 'Bank', $amount, $orderId]
        );
        DB::query('INSERT INTO TRANSACTIONS (amount,order_id,payment_id) VALUES (?,?,?)', [$amount, $orderId, $paymentId]);
        DB::query('INSERT INTO WALLET_TRANSACTIONS (user_id,amount,transaction_type,status) VALUES (?,?,"Hold","Completed")', [$user['user_id'], $amount]);

        // Remove from cart if it was a cart item
        DB::query('DELETE FROM CART_ITEMS WHERE user_id=? AND listing_id=?', [$user['user_id'], $order['listing_id']]);

        $sellerUser = DB::fetch('SELECT u.user_id FROM SELLER s JOIN USERS u ON s.user_id=u.user_id WHERE s.seller_id=?', [$order['seller_id']]);
        if ($sellerUser) DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$sellerUser['user_id'], 'Payment Received!', 'Payment of '.convertCurrency($amount).' received for order #'.$orderId.'. Please ship within 48 hours.', 'ORDER']);
        DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$user['user_id'], 'Payment Confirmed!', 'Your payment for "'.$order['title'].'" was successful.', 'ORDER']);

        header('Location: orders.php?tab=receive&paid=1'); exit;
    }
    $errorMsg = implode(' ', $errors);
}

renderHead('Checkout — Order #' . $orderId);
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('orders'); ?>

<main style="flex:1">
  <div style="max-width:900px;margin:0 auto;padding:28px var(--sp-margin-desktop) 80px">

    <!-- Back -->
    <a href="orders.php?tab=topay" style="display:inline-flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:20px;text-decoration:none">
      <span class="material-symbols-outlined icon-sm">arrow_back</span>Back to Orders
    </a>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">

      <!-- Order summary -->
      <div style="display:flex;flex-direction:column;gap:16px">
        <div class="tb-card tb-card-body">
          <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:16px">Order Summary</h2>
          <div style="display:flex;gap:14px;margin-bottom:16px">
            <div style="width:72px;height:72px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
              <?php if ($order['image_url']): ?><img src="<?= htmlspecialchars($order['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
            </div>
            <div>
              <p style="font-weight:700;font-size:var(--fs-label-md);color:var(--clr-text)"><?= htmlspecialchars($order['title']) ?></p>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px">Sold by @<?= htmlspecialchars($order['seller_name']) ?></p>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Order #<?= $orderId ?></p>
            </div>
          </div>
          <div style="border-top:1px solid var(--clr-outline);padding-top:12px;display:flex;flex-direction:column;gap:6px;font-size:var(--fs-label-md)">
            <div style="display:flex;justify-content:space-between"><span style="color:var(--clr-tertiary)">Item Total</span><span><?= convertCurrency($amount) ?></span></div>
            <div style="display:flex;justify-content:space-between"><span style="color:var(--clr-tertiary)">Platform Fee</span><span style="color:var(--clr-success)">Free</span></div>
            <div style="display:flex;justify-content:space-between"><span style="color:var(--clr-tertiary)">Shipping</span><span style="color:var(--clr-tertiary)">To be arranged</span></div>
            <div style="display:flex;justify-content:space-between;font-weight:700;font-size:var(--fs-body-md);border-top:1px solid var(--clr-outline);padding-top:8px;margin-top:4px">
              <span>Total Due</span><span style="color:var(--clr-coral)"><?= convertCurrency($amount) ?></span>
            </div>
          </div>
        </div>

        <!-- Currency display -->
        <div class="tb-card tb-card-body">
          <p class="tb-section-label">View total in another currency</p>
          <div style="display:flex;gap:8px;margin-bottom:8px">
            <?php foreach (['PHP','USD','KRW'] as $cur): ?>
            <button onclick="showCur('<?=$cur?>',<?=$amount?>)" class="btn btn-ghost btn-sm"><?=$cur?></button>
            <?php endforeach; ?>
          </div>
          <p id="convertedAmt" style="font-size:var(--fs-body-md);font-weight:700;color:var(--clr-coral);min-height:22px"></p>
        </div>

        <!-- Escrow notice -->
        <div style="background:var(--clr-info-bg);border:1px solid #b8d4e8;border-left:3px solid var(--clr-info);border-radius:var(--radius-sm);padding:12px 14px;font-size:var(--fs-label-sm);color:var(--clr-info)">
          <strong>Escrow Protection:</strong> Payment is held securely until you confirm delivery. Your money is safe.
        </div>
      </div>

      <!-- Payment form -->
      <div class="tb-card tb-card-body">
        <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:18px">Payment Method</h2>

        <?php if ($errorMsg): ?>
        <div class="tb-alert tb-alert-error show"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div>
        <?php endif; ?>

        <form method="POST" style="display:flex;flex-direction:column;gap:16px">
          <!-- Payment method selector -->
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

          <!-- GCash number -->
          <div id="gcashFields">
            <label class="tb-label">GCash Number</label>
            <input class="tb-input" type="tel" name="gcash_number" placeholder="09XXXXXXXXX" pattern="09[0-9]{9}" maxlength="11">
            <p style="font-size:var(--fs-label-sm);color:var(--clr-info);margin-top:6px;background:var(--clr-info-bg);padding:8px 10px;border-radius:var(--radius-sm)">
              <strong>Simulation Mode:</strong> Enter any valid 09XXXXXXXXX number. No real money transferred.
            </p>
          </div>

          <!-- Currency -->
          <div>
            <label class="tb-label">Payment Currency</label>
            <select name="currency" class="tb-select">
              <option value="PHP">PHP — Philippine Peso</option>
              <option value="USD">USD — US Dollar</option>
              <option value="KRW">KRW — Korean Won</option>
            </select>
          </div>

          <button type="submit" class="btn btn-primary btn-full btn-lg">
            <span class="material-symbols-outlined icon-sm">lock</span>
            Confirm Payment — <?= convertCurrency($amount) ?>
          </button>
        </form>

        <p style="font-size:11px;color:var(--clr-tertiary);text-align:center;margin-top:12px">Your payment is protected by ThriftBid Escrow until delivery is confirmed.</p>
      </div>

    </div>
  </div>
</main>
<?php renderFooter(); ?>
<script>
const rates={PHP:1,USD:0.0175,KRW:23.5},syms={PHP:'₱',USD:'$',KRW:'₩'};
function showCur(c,v){const r=v*rates[c];document.getElementById('convertedAmt').textContent=syms[c]+(c==='KRW'?Math.round(r).toLocaleString():r.toFixed(2))+' '+c;}
function updatePaymentUI(){
  ['GCash','Bank'].forEach(v=>{
    const checked=document.getElementById('pm_'+v).checked;
    const card=document.getElementById('pm_card_'+v);
    card.style.borderColor=checked?'var(--clr-coral)':'var(--clr-outline)';
    card.style.background=checked?'rgba(255,107,107,0.03)':'';
  });
  document.getElementById('gcashFields').style.display=document.getElementById('pm_GCash').checked?'':'none';
}
</script>
</body></html>
