<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? $user['id']; // session row IS the buyer row now


$orderId    = (int)($_GET['order'] ?? 0);
$itemsParam = trim($_GET['items'] ?? '');
$mode       = $orderId ? 'single' : 'cart';

$errorMsg = '';
$rows = []; // normalized list of ['listing_id','seller_id','seller_name','title','cover_image','price','order_id'(if already created)]

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

    // Determine amount: winning bid or fixed price
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

// Silently drops sold-out or inactive items instead of throwing an error.
// Allows the checkout process to continue for the remaining valid items.
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

// Group rows by seller for display, same idea as Shopee's cart-by-store blocks
$bySeller = [];
foreach ($rows as $r) { $bySeller[$r['seller_id']]['seller_name'] = $r['seller_name']; $bySeller[$r['seller_id']]['items'][] = $r; }

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $method   = $_POST['payment_method'] ?? 'GCash';
    $gcashNum = trim($_POST['gcash_number'] ?? '');
    $errors   = [];

    if ($method === 'GCash' && (!$gcashNum || !preg_match('/^09\d{9}$/', $gcashNum))) {
        $errors[] = 'Enter a valid GCash number (09XXXXXXXXX).';
    }

    if (empty($errors)) {
        $pdo = DB::get();
        $pdo->beginTransaction();
        try {
            foreach ($rows as $r) {
                $gatewayRef = 'SIM-' . strtoupper(bin2hex(random_bytes(6)));

                if ($mode === 'single') {
                    // Order already exists (created by Buy Now), just pay for it.
                    DB::callProc('sp_pay_for_order', [$r['order_id'], $r['listing_id'], $buyerId, $r['price'], $method === 'GCash' ? 'GCash' : 'Bank', $gatewayRef]);
                    $newOrderId = $r['order_id'];
                } else {
                    // sp_checkout_listing handles ORDER/Completed PAYMENT creation and clears the CART_ITEMS row.
                    // Called once per selected item; each item generates its own order/payment pair.
                    $newOrderId = DB::callProcGetLastId('sp_checkout_listing',
                        [$r['listing_id'], $buyerId, $r['seller_id'], $r['price'], $method === 'GCash' ? 'GCash' : 'Bank', $gatewayRef]
                    );
                }

                // Payment trigger only notifies the buyer.
                // Explicitly send the seller-facing shipping notice here (once per order).
                DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
                    [$r['seller_id'], 'Payment Received!', 'Payment of ' . convertCurrency($r['price']) . ' received for order #' . $newOrderId . '. Please ship within 48 hours.', 'ORDER']);
            }
            $pdo->commit();
        } catch (\Throwable $e) {
            $pdo->rollBack();
            // Intentional  message exposure for  debugging.
            
            $errors[] = 'Something went wrong processing your payment: ' . $e->getMessage();
        }
    }

    if (empty($errors)) {
        header('Location: orders.php?tab=receive&paid=1'); exit;
    }
    $errorMsg = implode(' ', $errors);
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

      <!-- Payment form -->
      <div class="tb-card tb-card-body">
        <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:18px">Payment Method</h2>

        <?php if ($errorMsg): ?>
        <div class="tb-alert tb-alert-error show"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div>
        <?php endif; ?>

        <form method="POST" style="display:flex;flex-direction:column;gap:16px">
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

          <button type="submit" class="btn btn-primary btn-full btn-lg">
            <span class="material-symbols-outlined icon-sm">lock</span>
            Confirm Payment - <?= convertCurrency($amount) ?>
          </button>
        </form>

        <p style="font-size:11px;color:var(--clr-tertiary);text-align:center;margin-top:12px">Your payment is protected by ThriftBid until delivery is confirmed.</p>
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
    const checked=document.getElementById('pm_'+v).checked;
    const card=document.getElementById('pm_card_'+v);
    card.style.borderColor=checked?'var(--clr-coral)':'var(--clr-outline)';
    card.style.background=checked?'rgba(255,107,107,0.03)':'';
  });
  document.getElementById('gcashFields').style.display=document.getElementById('pm_GCash').checked?'':'none';
}
</script>
</body></html>