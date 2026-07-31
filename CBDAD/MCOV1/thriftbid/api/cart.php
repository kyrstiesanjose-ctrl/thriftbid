<?php
/* api/cart.php - toggles a listing in/out of the buyer's cart, called via
   fetch() from listing/category pages. Returns JSON, never redirects. */
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
header('Content-Type: application/json');

if (!isLoggedIn()) { echo json_encode(['error'=>'Unauthorized']); exit; }

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? 0; /* session row IS the buyer row */
if (!$buyerId) { echo json_encode(['error'=>'Only buyers can use the cart']); exit; }

$body   = json_decode(file_get_contents('php://input'), true) ?? [];
$action = $body['action'] ?? $_POST['action'] ?? 'toggle'; /* 'add' | 'remove' | 'toggle' */
$lid    = (int)($body['listing_id'] ?? $_POST['listing_id'] ?? 0);
if (!$lid) { echo json_encode(['error'=>'Invalid listing']); exit; }

try {
    $existing = DB::fetch('SELECT cart_item_id FROM CART_ITEMS WHERE buyer_id=? AND listing_id=?', [$buyerId, $lid]);
    /* 'toggle' removes if already in cart, adds otherwise; 'remove'/'add'
       are explicit and idempotent (re-adding or re-removing is a no-op) */
    if ($action === 'remove' || ($action === 'toggle' && $existing)) {
        if ($existing) DB::query('DELETE FROM CART_ITEMS WHERE cart_item_id=?', [$existing['cart_item_id']]);
        echo json_encode(['success'=>true, 'added'=>false, 'message'=>'Removed from cart']);
    } else {
        if (!$existing) DB::query('INSERT INTO CART_ITEMS (buyer_id, listing_id) VALUES (?,?)', [$buyerId, $lid]);
        echo json_encode(['success'=>true, 'added'=>true, 'message'=>'Added to cart']);
    }
} catch (\Exception $e) {
    echo json_encode(['error'=>$e->getMessage()]);
}