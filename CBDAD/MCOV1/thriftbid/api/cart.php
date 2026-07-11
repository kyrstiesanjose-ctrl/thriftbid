<?php
// api/cart.php 
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
header('Content-Type: application/json');
if (!isLoggedIn()) { echo json_encode(['error'=>'Unauthorized']); exit; }

$uid    = $_SESSION['user_id'];
$body   = json_decode(file_get_contents('php://input'), true) ?? [];
$action = $body['action'] ?? $_POST['action'] ?? 'toggle'; // add | remove | toggle
$lid    = (int)($body['listing_id'] ?? $_POST['listing_id'] ?? 0);
if (!$lid) { echo json_encode(['error'=>'Invalid listing']); exit; }

try {
    $existing = DB::fetch('SELECT cart_item_id FROM CART_ITEMS WHERE user_id=? AND listing_id=?', [$uid, $lid]);
    if ($action === 'remove' || ($action === 'toggle' && $existing)) {
        if ($existing) DB::query('DELETE FROM CART_ITEMS WHERE cart_item_id=?', [$existing['cart_item_id']]);
        echo json_encode(['success'=>true, 'added'=>false, 'message'=>'Removed from cart']);
    } else {
        if (!$existing) DB::query('INSERT INTO CART_ITEMS (user_id, listing_id) VALUES (?,?)', [$uid, $lid]);
        echo json_encode(['success'=>true, 'added'=>true, 'message'=>'Added to cart']);
    }
} catch (\Exception $e) {
    echo json_encode(['error'=>$e->getMessage()]);
}
