<?php
// api/order-complete.php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';

if (!isLoggedIn()) { header('Location: /pages/login.php'); exit; }
$user   = currentUser();
$buyer  = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id = ?', [$user['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;
$orderId = (int)($_POST['order_id'] ?? 0);

if ($orderId && $buyerId) {
    // Verify this buyer owns the order
    $order = DB::fetch('SELECT * FROM ORDERS WHERE order_id=? AND buyer_id=?', [$orderId, $buyerId]);
    if ($order) {
        DB::query('UPDATE ORDERS SET status="Delivered" WHERE order_id=?', [$orderId]);
        // Release wallet hold ,  Release to seller
        DB::query('INSERT INTO WALLET_TRANSACTIONS (user_id, amount, transaction_type, status) VALUES (?,?,"Release","Completed")',
            [$user['user_id'], 0]);
        // Notify seller
        $sellerUser = DB::fetch('SELECT u.user_id FROM SELLER s JOIN USERS u ON s.user_id=u.user_id WHERE s.seller_id=?', [$order['seller_id']]);
        if ($sellerUser) {
            DB::query('INSERT INTO NOTIFICATIONS (user_id, title, message, notification_type) VALUES (?,?,?,?)',
                [$sellerUser['user_id'], 'Order Completed!', 'Buyer confirmed delivery for order #' . $orderId . '. Payment will be released.', 'ORDER']);
        }
    }
}

header('Location: /pages/customer/orders.php?tab=completed');
exit;
