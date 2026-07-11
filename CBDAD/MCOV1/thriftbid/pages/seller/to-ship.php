<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole(['seller','admin'],'/pages/login.php');

$user     = currentUser();
$seller   = DB::fetch('SELECT seller_id FROM SELLER WHERE user_id=?',[$user['user_id']]);
$sellerId = $seller['seller_id'] ?? 0;

$successMsg = $errorMsg = '';

// Handle ship submission
if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['ship_order'])) {
    $orderId    = (int)$_POST['order_id'];
    $courierId  = (int)$_POST['courier_id'];
    $trackingNo = trim($_POST['tracking_number'] ?? '');

    if (!$trackingNo) {
        $errorMsg = 'Please enter a tracking number.';
    } else {
        // Create shipment record
        DB::query('INSERT INTO SHIPMENTS (order_id,courier_id,tracking_number,status,shipped_date) VALUES (?,?,?,"Shipped",NOW())',
            [$orderId, $courierId, $trackingNo]);
        DB::query('UPDATE ORDERS SET status="Shipped" WHERE order_id=? AND seller_id=?',[$orderId,$sellerId]);

        // Notify buyer
        $order = DB::fetch('SELECT o.*,b.user_id as buyer_uid FROM ORDERS o JOIN BUYER by2 ON o.buyer_id=by2.buyer_id JOIN USERS b ON by2.user_id=b.user_id WHERE o.order_id=?',[$orderId]);
        if ($order) {
            DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
                [$order['buyer_uid'], 'Your Order Has Shipped!',
                 'Your order #'.$orderId.' has been shipped! Tracking: '.$trackingNo, 'ORDER']);
        }
        $successMsg = 'Order #'.$orderId.' marked as shipped!';
    }
}

// Orders to ship (Preparing + paid, no shipment yet)
$toShip = DB::fetchAll(
    'SELECT o.*,l.title,l.image_url,u.username as buyer_name,p.amount_paid,p.payment_method
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER by2  ON o.buyer_id=by2.buyer_id
     JOIN USERS u    ON by2.user_id=u.user_id
     JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status="Completed"
     LEFT JOIN SHIPMENTS sh ON o.order_id=sh.order_id
     WHERE o.seller_id=? AND o.status="Preparing" AND sh.shipment_id IS NULL
     ORDER BY o.order_date ASC',
    [$sellerId]
);

// Already shipped
$shipped = DB::fetchAll(
    'SELECT o.*,l.title,l.image_url,u.username as buyer_name,sh.tracking_number,sh.status as ship_status,co.courier_name
     FROM ORDERS o
     JOIN LISTINGS l  ON o.listing_id=l.listing_id
     JOIN BUYER by2   ON o.buyer_id=by2.buyer_id
     JOIN USERS u     ON by2.user_id=u.user_id
     JOIN SHIPMENTS sh ON o.order_id=sh.order_id
     JOIN COURIERS co  ON sh.courier_id=co.courier_id
     WHERE o.seller_id=? AND o.status IN ("Shipped","Out for Delivery")
     ORDER BY sh.shipped_date DESC',
    [$sellerId]
);

$couriers = DB::fetchAll('SELECT * FROM COURIERS ORDER BY courier_name');

renderHead('To Ship');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('ship', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('ship'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Orders to Ship</h1>
  <p class="tb-page-subtitle mb-8">Mark orders as shipped once you've handed them to a courier. You must ship within 48 hours of payment.</p>

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>
  <?php if ($errorMsg):   ?><div class="tb-alert tb-alert-error show mb-6"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div><?php endif; ?>

  <!-- Penalty warning -->
  <div class="tb-alert tb-alert-warning show mb-6">
    <span class="material-symbols-outlined icon-sm">warning</span>
    <div>
      <strong>Shipping Policy:</strong> Failure to ship within 48 hours triggers automatic refund to the buyer. Repeat offenses lead to account suspension.
    </div>
  </div>

  <!-- Pending shipments -->
  <h2 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:16px">Ready to Ship (<?= count($toShip) ?>)</h2>
  <?php if (empty($toShip)): ?>
  <div class="tb-card tb-card-body text-center mb-10" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">local_shipping</span>
    No orders waiting to be shipped.
  </div>
  <?php else: ?>
  <div class="flex flex-col gap-5 mb-10">
    <?php foreach ($toShip as $o): ?>
    <div class="tb-card">
      <div class="tb-card-body" style="display:flex;gap:20px;align-items:flex-start;flex-wrap:wrap">
        <div style="width:72px;height:72px;border-radius:var(--radius-lg);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0">
          <?php if ($o['image_url']): ?><img src="<?= htmlspecialchars($o['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined" style="color:var(--clr-outline-variant);margin:20px">checkroom</span><?php endif; ?>
        </div>
        <div style="flex:1;min-width:220px">
          <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($o['title']) ?></h3>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:4px">
            Buyer: @<?= htmlspecialchars($o['buyer_name']) ?> &bull; Order #<?= $o['order_id'] ?> &bull; Paid: <?= convertCurrency((float)$o['amount_paid']) ?> via <?= htmlspecialchars($o['payment_method']) ?>
          </p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Ordered: <?= date('M d, Y H:i', strtotime($o['order_date'])) ?></p>
        </div>
        <!-- Ship form -->
        <form method="POST" class="flex flex-col gap-2" style="min-width:260px">
          <input type="hidden" name="ship_order" value="1">
          <input type="hidden" name="order_id" value="<?= $o['order_id'] ?>">
          <select name="courier_id" class="tb-select" required>
            <option value="">Select Courier</option>
            <?php foreach ($couriers as $c): ?><option value="<?= $c['courier_id'] ?>"><?= htmlspecialchars($c['courier_name']) ?></option><?php endforeach; ?>
          </select>
          <input type="text" name="tracking_number" class="tb-input" placeholder="Tracking number" required>
          <button type="submit" class="btn btn-primary btn-sm">
            <span class="material-symbols-outlined icon-sm">local_shipping</span>Mark as Shipped
          </button>
        </form>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>

  <!-- Already shipped -->
  <h2 class="font-headline" style="font-size:var(--fs-headline-sm);margin-bottom:16px">In Transit (<?= count($shipped) ?>)</h2>
  <?php if (empty($shipped)): ?>
  <div style="color:var(--clr-tertiary);padding:16px 0">No orders currently in transit.</div>
  <?php else: ?>
  <div class="tb-table-wrapper">
    <table class="tb-table">
      <thead><tr><th>Item</th><th>Buyer</th><th>Courier</th><th>Tracking</th><th>Status</th></tr></thead>
      <tbody>
        <?php foreach ($shipped as $o): ?>
        <tr>
          <td style="font-weight:600"><?= htmlspecialchars($o['title']) ?></td>
          <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($o['buyer_name']) ?></td>
          <td><?= htmlspecialchars($o['courier_name']) ?></td>
          <td style="font-family:monospace;font-size:var(--fs-label-sm)"><?= htmlspecialchars($o['tracking_number']) ?></td>
          <td><span class="tb-badge tb-badge-blue"><?= htmlspecialchars($o['ship_status']) ?></span></td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>

</div>
</main>
</div>
</body></html>
