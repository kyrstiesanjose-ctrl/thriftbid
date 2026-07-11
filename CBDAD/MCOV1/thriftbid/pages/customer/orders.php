<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$user    = currentUser();
$tab     = $_GET['tab'] ?? 'active';
$buyer   = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$user['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;

$activeBids = $cartItems = $toPay = $toReceive = $completed = $refunded = [];

if ($buyerId) {
    $activeBids = DB::fetchAll(
        'SELECT b.bid_amount,b.bid_time,a.auction_id,a.end_time,a.current_highest_bid,a.status,l.title,l.image_url
         FROM BIDDINGS b
         JOIN AUCTIONS a ON b.auction_id=a.auction_id
         JOIN LISTINGS l ON a.listing_id=l.listing_id
         WHERE b.buyer_id=? AND a.status="Active"
         ORDER BY b.bid_time DESC',
        [$buyerId]
    );

    // Cart items 
    try {
        $cartItems = DB::fetchAll(
            'SELECT ci.cart_item_id,l.listing_id,l.title,l.price,l.image_url,l.item_condition,c.name as cat_name
             FROM CART_ITEMS ci
             JOIN LISTINGS l ON ci.listing_id=l.listing_id
             JOIN CATEGORIES c ON l.category_id=c.category_id
             WHERE ci.user_id=?
             ORDER BY ci.created_at DESC',
            [$user['user_id']]
        );
    } catch (\Exception $e) { $cartItems = []; }

    $toPay = DB::fetchAll(
        'SELECT o.*,l.title,l.image_url,u.username as seller_name,p.payment_id,p.payment_status
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER s ON o.seller_id=s.seller_id
         JOIN USERS u ON s.user_id=u.user_id
         LEFT JOIN PAYMENTS p ON o.order_id=p.order_id
         WHERE o.buyer_id=? AND o.status="Preparing" AND (p.payment_id IS NULL OR p.payment_status="Pending")
         ORDER BY o.order_date DESC',
        [$buyerId]
    );

    $toReceive = DB::fetchAll(
        'SELECT o.*,l.title,l.image_url,u.username as seller_name,
                sh.tracking_number,sh.status as shipment_status,co.courier_name
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER s ON o.seller_id=s.seller_id
         JOIN USERS u ON s.user_id=u.user_id
         LEFT JOIN SHIPMENTS sh ON o.order_id=sh.order_id
         LEFT JOIN COURIERS co ON sh.courier_id=co.courier_id
         WHERE o.buyer_id=? AND o.status IN ("Shipped","Out for Delivery")
         ORDER BY o.order_date DESC',
        [$buyerId]
    );

    $completed = DB::fetchAll(
        'SELECT o.*,l.title,l.image_url,u.username as seller_name,p.amount_paid
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER s ON o.seller_id=s.seller_id
         JOIN USERS u ON s.user_id=u.user_id
         LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status="Completed"
         WHERE o.buyer_id=? AND o.status="Delivered"
         ORDER BY o.order_date DESC',
        [$buyerId]
    );

    $refunded = DB::fetchAll(
        'SELECT d.*,o.order_id,l.title,l.image_url,u.username as seller_name,p.amount_paid
         FROM DISPUTES d
         JOIN ORDERS o ON d.order_id=o.order_id
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         JOIN SELLER s ON o.seller_id=s.seller_id
         JOIN USERS u ON s.user_id=u.user_id
         LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status="Completed"
         WHERE d.buyer_id=? AND d.status="Resolved"
         ORDER BY d.resolved_at DESC',
        [$buyerId]
    );
}

// Remove from cart action
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['remove_cart'])) {
    $cid = (int)$_POST['cart_item_id'];
    DB::query('DELETE FROM CART_ITEMS WHERE cart_item_id=? AND user_id=?', [$cid, $user['user_id']]);
    header('Location: orders.php?tab=cart'); exit;
}

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

<!-- Sub-header -->
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

<!-- ── ACTIVE BIDS ── -->
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
      <?php if ($b['image_url']): ?><img src="<?= htmlspecialchars($b['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
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

<!--  CART -->
<?php elseif ($tab === 'cart'): ?>
<?php if (empty($cartItems)): ?>
<div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
  <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">shopping_cart</span>
  <p style="font-weight:700;font-size:var(--fs-headline-sm)">Your cart is empty</p>
  <p style="margin-top:6px">Add items from listings to your cart.</p>
  <a href="categories.php" class="btn btn-primary" style="margin-top:20px">Browse Items</a>
</div>
<?php else: ?>
<div style="display:flex;flex-direction:column;gap:12px">
  <?php foreach ($cartItems as $ci): ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px;display:flex;align-items:center;gap:16px;flex-wrap:wrap">
    <div style="width:64px;height:64px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($ci['image_url']): ?><img src="<?= htmlspecialchars($ci['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($ci['title']) ?></p>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px"><?= htmlspecialchars($ci['cat_name']) ?> &bull; <?= htmlspecialchars($ci['item_condition']) ?></p>
      <p style="font-weight:800;color:var(--clr-coral);font-size:var(--fs-body-md);margin-top:4px"><?= convertCurrency((float)$ci['price']) ?></p>
    </div>
    <div style="display:flex;gap:8px;flex-shrink:0">
      <a href="listing.php?id=<?= $ci['listing_id'] ?>" class="btn btn-primary btn-sm">Buy Now</a>
      <form method="POST">
        <input type="hidden" name="remove_cart" value="1">
        <input type="hidden" name="cart_item_id" value="<?= $ci['cart_item_id'] ?>">
        <button type="submit" class="btn btn-ghost btn-sm" style="color:var(--clr-error)" onclick="return confirm('Remove from cart?')">
          <span class="material-symbols-outlined icon-sm">delete</span>
        </button>
      </form>
    </div>
  </div>
  <?php endforeach; ?>
</div>
<?php endif; ?>

<!--  TO PAY  -->
<?php elseif ($tab === 'topay'): ?>
<div style="display:flex;flex-direction:column;gap:14px">
  <?php if (empty($toPay)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No pending payments.</div>
  <?php else: foreach ($toPay as $o): ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:18px 20px;display:flex;align-items:center;gap:16px;flex-wrap:wrap">
    <div style="width:72px;height:72px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($o['image_url']): ?><img src="<?= htmlspecialchars($o['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px">Seller: @<?= htmlspecialchars($o['seller_name']) ?> &bull; Order #<?= $o['order_id'] ?></p>
      <span class="tb-badge tb-badge-red" style="margin-top:6px">Payment Pending</span>
    </div>
    <a href="checkout.php?order=<?= $o['order_id'] ?>" class="btn btn-primary btn-sm">Checkout Now</a>
  </div>
  <?php endforeach; endif; ?>
</div>

<!--  TO RECEIVE  -->
<?php elseif ($tab === 'receive'): ?>
<div style="display:flex;flex-direction:column;gap:14px">
  <?php if (empty($toReceive)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No orders currently in transit.</div>
  <?php else: foreach ($toReceive as $o):
    $steps = ['Preparing','Shipped','Out for Delivery','Delivered'];
    $cur   = array_search($o['status'], $steps);
    $pct   = $cur !== false ? round($cur / (count($steps)-1) * 100) : 0;
  ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden">
    <div style="padding:18px 20px;display:flex;gap:16px;align-items:flex-start;flex-wrap:wrap">
      <div style="width:64px;height:64px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
        <?php if ($o['image_url']): ?><img src="<?= htmlspecialchars($o['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-md" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
      </div>
      <div style="flex:1;min-width:0">
        <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px">Seller: @<?= htmlspecialchars($o['seller_name']) ?> &bull; Order #<?= $o['order_id'] ?></p>
        <?php if ($o['tracking_number']): ?>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px">Tracking: <strong style="font-family:monospace"><?= htmlspecialchars($o['tracking_number']) ?></strong> via <?= htmlspecialchars($o['courier_name']??'') ?></p>
        <?php endif; ?>
      </div>
      <span class="tb-badge tb-badge-blue"><?= htmlspecialchars($o['status']) ?></span>
    </div>
    <!-- Progress steps -->
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
      <form method="POST" action="../../api/order-complete.php">
        <input type="hidden" name="order_id" value="<?= $o['order_id'] ?>">
        <button type="submit" class="btn btn-primary btn-sm" <?= $o['status']!=='Out for Delivery'?'disabled style="opacity:.4;cursor:not-allowed"':'' ?>>Confirm Delivery</button>
      </form>
    </div>
  </div>
  <?php endforeach; endif; ?>
</div>

<!--  COMPLETED  -->
<?php elseif ($tab === 'done'): ?>
<div style="display:flex;flex-direction:column;gap:12px">
  <?php if (empty($completed)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No completed orders yet.</div>
  <?php else: foreach ($completed as $o): ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px;display:flex;align-items:center;gap:14px;flex-wrap:wrap">
    <div style="width:60px;height:60px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($o['image_url']): ?><img src="<?= htmlspecialchars($o['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">@<?= htmlspecialchars($o['seller_name']) ?></p>
      <?php if ($o['amount_paid']): ?><p style="font-weight:700;color:var(--clr-coral);font-size:var(--fs-label-md)"><?= convertCurrency((float)$o['amount_paid']) ?></p><?php endif; ?>
    </div>
    <span class="tb-badge tb-badge-active">
      <span class="material-symbols-outlined icon-sm">check_circle</span>Delivered
    </span>
  </div>
  <?php endforeach; endif; ?>
</div>

<!--  REFUNDED  -->
<?php elseif ($tab === 'refunded'): ?>
<div style="display:flex;flex-direction:column;gap:12px">
  <?php if (empty($refunded)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">No refunded orders.</div>
  <?php else: foreach ($refunded as $d): ?>
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px 20px;display:flex;align-items:center;gap:14px;flex-wrap:wrap">
    <div style="width:60px;height:60px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
      <?php if ($d['image_url']): ?><img src="<?= htmlspecialchars($d['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
    </div>
    <div style="flex:1;min-width:0">
      <span class="tb-badge tb-badge-gray" style="margin-bottom:4px">Dispute Resolved</span>
      <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($d['title']) ?></p>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);font-style:italic"><?= htmlspecialchars($d['reason']) ?></p>
    </div>
    <div style="text-align:right;flex-shrink:0">
      <?php if ($d['amount_paid']): ?>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);text-decoration:line-through"><?= convertCurrency((float)$d['amount_paid']) ?></p>
      <p style="font-weight:800;color:var(--clr-success)"><?= convertCurrency((float)$d['amount_paid']) ?> Refunded</p>
      <?php endif; ?>
      <?php if ($d['resolved_at']): ?><p style="font-size:11px;color:var(--clr-tertiary)"><?= date('M d, Y', strtotime($d['resolved_at'])) ?></p><?php endif; ?>
    </div>
  </div>
  <?php endforeach; endif; ?>
</div>
<?php endif; ?>

</main>
<?php renderFooter(); ?>
</body></html>
