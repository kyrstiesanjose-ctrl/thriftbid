<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$user    = currentUser();
$tab     = $_GET['tab'] ?? 'active';
$buyerId = $user['buyer_id'] ?? 0; // session row IS the buyer row now

$imgSub = '(SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image';

$activeBids = $cartItems = $toPay = $toReceive = $completed = $refunded = [];

if ($buyerId) {
    $activeBids = DB::fetchAll(
        "SELECT b.bid_amount, b.bid_time, a.auction_id, a.end_time, a.current_highest_bid, a.status, l.title, $imgSub
         FROM BIDDINGS b
         JOIN AUCTIONS a ON b.auction_id=a.auction_id
         JOIN LISTINGS l ON a.listing_id=l.listing_id
         WHERE b.buyer_id=? AND a.status='Active' AND b.is_deleted=0
         ORDER BY b.bid_time DESC",
        [$buyerId]
    );

    $cartItems = DB::fetchAll(
        "SELECT ci.cart_item_id, l.listing_id, l.title, l.price, l.condition_grade, l.is_active,
                c.name AS cat_name, sz.size_value, l.seller_id, COALESCE(se.shop_name, se.username) AS seller_name, $imgSub
         FROM CART_ITEMS ci
         JOIN LISTINGS l ON ci.listing_id=l.listing_id
         JOIN CATEGORIES c ON l.category_id=c.category_id
         JOIN CATEGORY_SIZES sz ON l.size_id=sz.size_id
         JOIN SELLER se ON l.seller_id=se.seller_id
         WHERE ci.buyer_id=?
         ORDER BY ci.added_at DESC",
        [$buyerId]
    );

    $toPay = DB::fetchAll(
        "SELECT o.*, l.title, COALESCE(se.shop_name, se.username) AS seller_name, p.payment_id, p.payment_status, $imgSub
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER se  ON o.seller_id=se.seller_id
         LEFT JOIN PAYMENTS p ON o.order_id=p.order_id
         WHERE o.buyer_id=? AND o.status='Preparing' AND (p.payment_id IS NULL OR p.payment_status='Pending')
         ORDER BY o.order_date DESC",
        [$buyerId]
    );

    $toReceive = DB::fetchAll(
        "SELECT o.*, l.title, COALESCE(se.shop_name, se.username) AS seller_name,
                sh.tracking_number, sh.status AS shipment_status, co.courier_name, $imgSub
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER se  ON o.seller_id=se.seller_id
         JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status='Completed'
         LEFT JOIN SHIPMENTS sh ON o.order_id=sh.order_id
         LEFT JOIN COURIERS co ON sh.courier_id=co.courier_id
         WHERE o.buyer_id=? AND o.status IN ('Preparing','Shipped','Out for Delivery')
         ORDER BY o.order_date DESC",
        [$buyerId]
    );

    $completed = DB::fetchAll(
        "SELECT o.*, l.title, COALESCE(se.shop_name, se.username) AS seller_name, se.seller_id, p.amount_paid, $imgSub
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER se  ON o.seller_id=se.seller_id
         LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status='Completed'
         WHERE o.buyer_id=? AND o.status='Delivered'
         ORDER BY o.order_date DESC",
        [$buyerId]
    );

    $refunded = DB::fetchAll(
        "SELECT d.*, o.order_id, l.title, COALESCE(se.shop_name, se.username) AS seller_name, p.amount_paid, $imgSub
         FROM DISPUTES d
         JOIN ORDERS o ON d.order_id=o.order_id
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER se  ON o.seller_id=se.seller_id
         LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status='Completed'
         WHERE d.buyer_id=?
         ORDER BY (d.status IN ('Open','Under Review')) DESC, COALESCE(d.resolved_at, d.opened_at) DESC",
        [$buyerId]
    );
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['remove_cart'])) {
    $cid = (int)$_POST['cart_item_id'];
    DB::query('DELETE FROM CART_ITEMS WHERE cart_item_id=? AND buyer_id=?', [$cid, $buyerId]);
    header('Location: orders.php?tab=cart'); exit;
}

// groupByDate() and renderDateHeader() 

$tabs = [
    'active'  => ['label'=>'Active Bids',   'count'=>count($activeBids)],
    'cart'    => ['label'=>'Cart',           'count'=>count($cartItems)],
    'topay'   => ['label'=>'To Pay',         'count'=>count($toPay)],
    'receive' => ['label'=>'To Receive',     'count'=>count($toReceive)],
    'done'    => ['label'=>'Completed',      'count'=>count($completed)],
    'refunded'=> ['label'=>'Refunds',        'count'=>count($refunded)],
];

renderHead('My Orders');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('orders'); ?>

<div style="background:var(--clr-white);border-bottom:1px solid var(--clr-outline);position:sticky;top:56px;z-index:99">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:0 var(--sp-margin-desktop)">
    <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:700;padding-top:20px;margin-bottom:12px">My Orders &amp; Cart</h1>
    <div class="tb-tabs">
      <?php foreach ($tabs as $key => $info): ?>
      <a href="?tab=<?= $key ?>" class="tb-tab-link <?= $tab===$key?'active':'' ?>">
        <?= $info['label'] ?><?php if ($info['count']): ?> (<?= $info['count'] ?>)<?php endif; ?>
      </a>
      <?php endforeach; ?>
    </div>
  </div>
</div>

<main style="flex:1;max-width:var(--sp-container);margin:0 auto;padding:24px var(--sp-margin-desktop) 80px;width:100%">

<?php if ($_GET['paid'] ?? false): ?>
<div class="tb-alert tb-alert-success show" style="margin-bottom:16px">
  <span class="material-symbols-outlined icon-sm">check_circle</span>Payment confirmed! Your order is now being prepared.
</div>
<?php endif; ?>

<?php if ($tab === 'active'): ?>
<div style="display:flex;flex-direction:column;gap:14px">
  <?php if (empty($activeBids)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">gavel</span>
    <p style="font-weight:700;font-size:var(--fs-headline-sm)">No active bids</p>
    <p style="margin-top:6px">Explore live auctions and join a bid!</p>
    <a href="live-bids.php" class="btn btn-primary" style="margin-top:20px">View Live Auctions</a>
  </div>
  <?php else: foreach ($activeBids as $b):
    $isWinning = (float)$b['bid_amount'] >= (float)$b['current_highest_bid'];
  ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:18px 20px;display:flex;align-items:center;gap:16px;flex-wrap:wrap">
    <div style="width:72px;height:72px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($b['cover_image']): ?><img src="<?= htmlspecialchars($b['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <p style="font-weight:700;font-size:var(--fs-body-md);color:var(--clr-text)"><?= htmlspecialchars($b['title']) ?></p>
      <div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:6px;font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
        <span>Your bid: <strong style="color:var(--clr-text)"><?= convertCurrency((float)$b['bid_amount']) ?></strong></span>
        <span>Highest: <strong style="color:<?= $isWinning?'var(--clr-success)':'var(--clr-error)' ?>"><?= convertCurrency((float)$b['current_highest_bid']) ?></strong></span>
        <span style="color:var(--clr-coral)">Ends: <?= formatTimeLeft($b['end_time']) ?></span>
      </div>
      <span class="tb-badge <?= $isWinning?'tb-badge-active':'tb-badge-red' ?>" style="margin-top:6px"><?= $isWinning?'Winning':'Outbid' ?></span>
    </div>
    <div style="display:flex;flex-direction:column;gap:6px;min-width:130px">
      <a href="auction_room.php?id=<?= $b['auction_id'] ?>" class="btn btn-yellow btn-sm">Join Bid Room</a>
      <?php if (!$isWinning): ?>
      <a href="auction_room.php?id=<?= $b['auction_id'] ?>" class="btn btn-outline btn-sm">Raise Bid</a>
      <?php endif; ?>
    </div>
  </div>
  <?php endforeach; endif; ?>
</div>

<?php elseif ($tab === 'cart'): ?>
<?php if (empty($cartItems)): ?>
<div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
  <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">shopping_cart</span>
  <p style="font-weight:700;font-size:var(--fs-headline-sm)">Your cart is empty</p>
  <p style="margin-top:6px">Add items from listings to your cart.</p>
  <a href="categories.php" class="btn btn-primary" style="margin-top:20px">Browse Items</a>
</div>
<?php else:
  $cartBySeller = [];
  foreach ($cartItems as $ci) { $cartBySeller[$ci['seller_id']]['seller_name'] = $ci['seller_name']; $cartBySeller[$ci['seller_id']]['items'][] = $ci; }
?>
<div style="display:flex;flex-direction:column;gap:16px">
  <label style="display:flex;align-items:center;gap:8px;font-weight:600;font-size:var(--fs-label-md);cursor:pointer">
    <input type="checkbox" id="selectAllCart" onchange="toggleAllCart(this.checked)" style="width:18px;height:18px;accent-color:var(--clr-coral)">
    Select All Items
  </label>

  <?php foreach ($cartBySeller as $shop): ?>
  <div class="tb-card">
    <div style="padding:14px 18px;border-bottom:1px solid var(--clr-outline);display:flex;align-items:center;gap:10px">
      <input type="checkbox" class="shop-checkbox" onchange="toggleShop(this)" style="width:18px;height:18px;accent-color:var(--clr-coral)">
      <span class="material-symbols-outlined icon-sm" style="color:var(--clr-tertiary)">storefront</span>
      <span style="font-weight:700"><?= htmlspecialchars($shop['seller_name']) ?></span>
    </div>
    <?php foreach ($shop['items'] as $ci): $sold = !$ci['is_active']; ?>
    <div style="padding:16px 18px;display:flex;align-items:center;gap:14px;border-bottom:1px solid var(--clr-outline)" class="cart-row">
      <input type="checkbox" class="item-checkbox" data-price="<?= $ci['price'] ?>" data-listing="<?= $ci['listing_id'] ?>"
             onchange="recalcCart()" style="width:18px;height:18px;accent-color:var(--clr-coral);flex-shrink:0" <?= $sold?'disabled':'' ?>>
      <div onclick="window.location.href='listing.php?id=<?= $ci['listing_id'] ?>'" style="display:flex;align-items:center;gap:14px;flex:1;cursor:pointer;min-width:0">
        <div style="position:relative;width:64px;height:64px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
          <?php if ($ci['cover_image']): ?><img src="<?= htmlspecialchars($ci['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover;<?= $sold?'opacity:0.5':'' ?>"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
          <?php if ($sold): ?>
          <div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;background:rgba(0,0,0,0.35)">
            <span style="background:#1a1a1a;color:#fff;font-size:9px;font-weight:800;letter-spacing:0.05em;padding:2px 6px;border-radius:4px">SOLD</span>
          </div>
          <?php endif; ?>
        </div>
        <div style="flex:1;min-width:0">
          <p style="font-weight:700;color:var(--clr-text);overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($ci['title']) ?></p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px">Size <?= htmlspecialchars($ci['size_value']) ?> &bull; <?= htmlspecialchars($ci['cat_name']) ?> &bull; <?= htmlspecialchars($ci['condition_grade']) ?></p>
          <p style="font-weight:800;color:var(--clr-coral);font-size:var(--fs-body-md);margin-top:4px"><?= convertCurrency((float)$ci['price']) ?></p>
        </div>
      </div>
      <?php if ($sold): ?>
      <span class="tb-badge tb-badge-gray" style="flex-shrink:0">No longer available</span>
      <?php endif; ?>
      <form method="POST" style="flex-shrink:0" onsubmit="event.stopPropagation()">
        <input type="hidden" name="remove_cart" value="1">
        <input type="hidden" name="cart_item_id" value="<?= $ci['cart_item_id'] ?>">
        <button type="submit" class="btn btn-ghost btn-sm" style="color:var(--clr-error)" onclick="event.stopPropagation();return confirm('Remove from cart?')">
          <span class="material-symbols-outlined icon-sm">delete</span>
        </button>
      </form>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endforeach; ?>

  <!-- Subtotal / Checkout -->
  <div style="background:#fff;border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px;display:flex;align-items:center;justify-content:flex-end;gap:20px;position:sticky;bottom:16px;box-shadow:0 4px 16px rgba(0,0,0,0.08)">
    <div style="text-align:right">
      <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><span id="selectedCount">0</span> item(s) selected</span>
      <p style="font-weight:800;font-size:var(--fs-headline-sm);color:var(--clr-coral)">Subtotal: <span id="cartSubtotal">₱0.00</span></p>
    </div>
    <button type="button" class="btn btn-primary btn-lg" id="cartCheckoutBtn" disabled onclick="goToCheckout()">Checkout / Buy Now</button>
  </div>
</div>
<?php endif; ?>


<?php elseif ($tab === 'topay'): ?>
<div style="display:flex;flex-direction:column;gap:14px">
  <?php if (empty($toPay)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No pending payments.</div>
  <?php else: foreach (groupByDate($toPay, 'order_date') as $dateLabel => $rows): renderDateHeader($dateLabel); foreach ($rows as $o): ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:18px 20px;display:flex;align-items:center;gap:16px;flex-wrap:wrap">
    <div style="width:72px;height:72px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px">Seller: <?= htmlspecialchars($o['seller_name']) ?> &bull; Order #<?= $o['order_id'] ?></p>
      <span class="tb-badge tb-badge-red" style="margin-top:6px">Payment Pending</span>
    </div>
    <a href="checkout.php?order=<?= $o['order_id'] ?>" class="btn btn-primary btn-sm">Checkout Now</a>
  </div>
  <?php endforeach; endforeach; endif; ?>
</div>

<?php elseif ($tab === 'receive'): ?>
<div style="display:flex;flex-direction:column;gap:14px">
  <?php if (empty($toReceive)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No orders currently in transit.</div>
  <?php else: foreach (groupByDate($toReceive, 'order_date') as $dateLabel => $rows): renderDateHeader($dateLabel); foreach ($rows as $o):
    $steps = ['Preparing','Shipped','Out for Delivery','Delivered'];
    $cur   = array_search($o['status'], $steps);
    $pct   = $cur !== false ? round($cur / (count($steps)-1) * 100) : 0;
  ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden">
    <div style="padding:18px 20px;display:flex;gap:16px;align-items:flex-start;flex-wrap:wrap">
      <div style="width:64px;height:64px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
        <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
      </div>
      <div style="flex:1;min-width:0">
        <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px">Seller: <?= htmlspecialchars($o['seller_name']) ?> &bull; Order #<?= $o['order_id'] ?></p>
        <?php if ($o['tracking_number']): ?>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px">Tracking: <strong style="font-family:monospace"><?= htmlspecialchars($o['tracking_number']) ?></strong> via <?= htmlspecialchars($o['courier_name']??'') ?></p>
        <?php endif; ?>
      </div>
      <span class="tb-badge tb-badge-blue"><?= htmlspecialchars($o['status']) ?></span>
    </div>
    <div style="padding:16px 20px;border-top:1px solid var(--clr-outline);background:var(--clr-bg)">
      <div class="tb-steps" style="padding:0 10px">
        <div class="tb-steps-progress" style="width:<?= $pct ?>%"></div>
        <?php foreach ($steps as $si => $step): $done = $si <= $cur; ?>
        <div class="tb-step">
          <div class="tb-step-dot <?= $done?'done':($si===$cur?'active':'') ?>">
            <?php if ($done): ?><span class="material-symbols-outlined icon-sm" style="font-size:10px;color:#fff">check</span><?php endif; ?>
          </div>
          <span class="tb-step-label <?= $done?'done':'' ?>"><?= $step ?></span>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
    <div style="padding:12px 20px;border-top:1px solid var(--clr-outline);display:flex;justify-content:flex-end;gap:8px">
      <a href="request-refund.php?order=<?= $o['order_id'] ?>" class="btn btn-ghost btn-sm" style="color:var(--clr-error)">Request Refund</a>
      <form method="POST" action="../../api/order-complete.php">
        <input type="hidden" name="order_id" value="<?= $o['order_id'] ?>">
        <button type="submit" class="btn btn-primary btn-sm" <?= !in_array($o['status'], ['Shipped','Out for Delivery'], true) ? 'disabled style="opacity:.4;cursor:not-allowed"' : '' ?>>Confirm Delivery</button>
      </form>
    </div>
  </div>
  <?php endforeach; endforeach; endif; ?>
</div>

<?php elseif ($tab === 'done'): ?>
<div style="display:flex;flex-direction:column;gap:12px">
  <?php if (empty($completed)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No completed orders yet.</div>
  <?php else: foreach (groupByDate($completed, 'order_date') as $dateLabel => $rows): renderDateHeader($dateLabel); foreach ($rows as $o): ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px;display:flex;align-items:center;gap:14px;flex-wrap:wrap">
    <div style="width:60px;height:60px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($o['seller_name']) ?></p>
      <?php if ($o['amount_paid']): ?><p style="font-weight:700;color:var(--clr-coral);font-size:var(--fs-label-md)"><?= convertCurrency((float)$o['amount_paid']) ?></p><?php endif; ?>
    </div>
    <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px">
      <span class="tb-badge tb-badge-active"><span class="material-symbols-outlined icon-sm">check_circle</span>Delivered</span>
      <a href="seller_profile.php?id=<?= $o['seller_id'] ?>#reviews" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">Leave a review &rarr;</a>
      <a href="request-refund.php?order=<?= $o['order_id'] ?>" style="font-size:var(--fs-label-sm);color:var(--clr-error);font-weight:600">Request Refund</a>
    </div>
  </div>
  <?php endforeach; endforeach; endif; ?>
</div>

<?php elseif ($tab === 'refunded'): ?>
<div style="display:flex;flex-direction:column;gap:12px">
  <?php if (empty($refunded)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No refund requests yet.</div>
  <?php else:

    // Groups by creation date if unresolved (resolved_at IS NULL), otherwise by resolution date.
    foreach ($refunded as &$d) { $d['group_date'] = $d['resolved_at'] ?? $d['opened_at']; } unset($d);
    foreach (groupByDate($refunded, 'group_date') as $dateLabel => $rows): renderDateHeader($dateLabel); foreach ($rows as $d):
      $statusBadge = match($d['status']) {
        'Open', 'Under Review' => ['label' => $d['status'] === 'Open' ? 'Pending Review' : 'Under Review', 'class' => 'tb-badge-coral'],
        'Resolved' => ['label' => htmlspecialchars($d['resolution_type']), 'class' => 'tb-badge-green'],
        'Rejected' => ['label' => 'Rejected', 'class' => 'tb-badge-gray'],
        default => ['label' => $d['status'], 'class' => 'tb-badge-gray'],
      };
  ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px;display:flex;align-items:center;gap:14px;flex-wrap:wrap">
    <div style="width:60px;height:60px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($d['cover_image']): ?><img src="<?= htmlspecialchars($d['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <span class="tb-badge <?= $statusBadge['class'] ?>" style="margin-bottom:4px"><?= $statusBadge['label'] ?></span>
      <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($d['title']) ?></p>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);font-style:italic"><?= htmlspecialchars($d['reason']) ?></p>
    </div>
    <div style="text-align:right;flex-shrink:0">
      <?php if ($d['status'] === 'Resolved' && $d['amount_paid']): ?>
      <p style="font-weight:800;color:var(--clr-success)">
        <?= convertCurrency((float)$d['amount_paid'] * ($d['resolution_type']==='Partial Refund' ? 0.5 : 1)) ?> Refunded
      </p>
      <?php endif; ?>
      <?php if ($d['resolved_at']): ?>
      <p style="font-size:11px;color:var(--clr-tertiary)">Resolved <?= date('M d, Y', strtotime($d['resolved_at'])) ?></p>
      <?php else: ?>
      <p style="font-size:11px;color:var(--clr-tertiary)">Filed <?= date('M d, Y', strtotime($d['opened_at'])) ?></p>
      <?php endif; ?>
    </div>
  </div>
  <?php endforeach; endforeach; endif; ?>
</div>
<?php endif; ?>

</main>
<?php renderFooter(); ?>
<?php if ($tab === 'cart' && !empty($cartItems)): ?>
<script>
function recalcCart(){
  const boxes = document.querySelectorAll('.item-checkbox:checked');
  let total = 0;
  boxes.forEach(b => total += parseFloat(b.dataset.price));
  document.getElementById('selectedCount').textContent = boxes.length;
  document.getElementById('cartSubtotal').textContent = '₱' + total.toLocaleString(undefined, {minimumFractionDigits:2, maximumFractionDigits:2});
  document.getElementById('cartCheckoutBtn').disabled = boxes.length === 0;

  // Shop-level and select-all checkboxes items
  document.querySelectorAll('.shop-checkbox').forEach(shopBox => {
    const group = shopBox.closest('.tb-card').querySelectorAll('.item-checkbox:not(:disabled)');
    const checked = shopBox.closest('.tb-card').querySelectorAll('.item-checkbox:checked');
    shopBox.checked = group.length > 0 && checked.length === group.length;
  });
  const all = document.querySelectorAll('.item-checkbox:not(:disabled)');
  const allChecked = document.querySelectorAll('.item-checkbox:checked');
  document.getElementById('selectAllCart').checked = all.length > 0 && allChecked.length === all.length;
}
function toggleShop(shopCheckbox){
  const group = shopCheckbox.closest('.tb-card').querySelectorAll('.item-checkbox:not(:disabled)');
  group.forEach(cb => cb.checked = shopCheckbox.checked);
  recalcCart();
}
function toggleAllCart(checked){
  document.querySelectorAll('.item-checkbox:not(:disabled)').forEach(cb => cb.checked = checked);
  recalcCart();
}
function goToCheckout(){
  const ids = Array.from(document.querySelectorAll('.item-checkbox:checked')).map(cb => cb.dataset.listing);
  if (!ids.length) return;
  window.location.href = 'checkout.php?items=' + ids.join(',');
}
</script>
<?php endif; ?>
</body></html>