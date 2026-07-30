<?php
/* api/order-complete.php - buyer clicks "Confirm Delivery" on orders.php.
   Only fires for orders already Shipped/Out for Delivery, and only the
   buyer who placed it can confirm - stops anyone else marking an order
   delivered early. */
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';

if (!isLoggedIn()) { header('Location: ' . BASE_URL . '/pages/login.php'); exit; }

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? 0; /* session row IS the buyer row */
$orderId = (int)($_POST['order_id'] ?? 0);

if ($orderId && $buyerId) {
    $order = DB::fetch('SELECT * FROM ORDERS WHERE order_id=? AND buyer_id=? AND status IN ("Shipped","Out for Delivery")', [$orderId, $buyerId]);
    if ($order) {

        /* This one UPDATE cascades through two triggers automatically:
           after_shipment_status_change (schema.sql) copies the new status
           onto ORDERS.status, which then  after_order_status_change_
           notify_buyer - so the buyer's own "Order Update: Delivered"
           notification is NOT sent here.
           The NOTIFICATIONS insert just below is a separate, deliberate
           message to the SELLER (the trigger chain doesn't notify them). */
        DB::query('UPDATE SHIPMENTS SET status="Delivered", delivered_date=NOW() WHERE order_id=?', [$orderId]);

        DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
            [$order['seller_id'], 'Order Completed!', 'Buyer confirmed delivery for order #' . $orderId . '. Payment will be released.', 'ORDER']);
    }
}

header('Location: ' . BASE_URL . '/pages/customer/orders.php?tab=done');
exit;