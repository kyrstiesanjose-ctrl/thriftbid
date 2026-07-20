<?php
// api/order-complete.php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';

if (!isLoggedIn()) { header('Location: ' . BASE_URL . '/pages/login.php'); exit; }

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? 0; // session row IS the buyer row now
$orderId = (int)($_POST['order_id'] ?? 0);

if ($orderId && $buyerId) {
    $order = DB::fetch('SELECT * FROM ORDERS WHERE order_id=? AND buyer_id=? AND status IN ("Shipped","Out for Delivery")', [$orderId, $buyerId]);
    if ($order) {

        DB::query('UPDATE SHIPMENTS SET status="Delivered", delivered_date=NOW() WHERE order_id=?', [$orderId]);


        DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
            [$order['seller_id'], 'Order Completed!', 'Buyer confirmed delivery for order #' . $orderId . '. Payment will be released.', 'ORDER']);
    }
}

header('Location: ' . BASE_URL . '/pages/customer/orders.php?tab=done');
exit;