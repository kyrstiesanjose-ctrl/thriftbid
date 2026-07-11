<?php
// api/watchlist.php — toggle watchlist (JSON API)
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';

header('Content-Type: application/json');

if (!isLoggedIn()) { echo json_encode(['error'=>'Unauthorized']); exit; }
$user   = currentUser();
$buyer  = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id = ?', [$user['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;

if (!$buyerId) { echo json_encode(['error'=>'Not a buyer']); exit; }

$body      = json_decode(file_get_contents('php://input'), true) ?? [];
$listingId = (int)($body['listing_id'] ?? $_POST['listing_id'] ?? 0);

if (!$listingId) { echo json_encode(['error'=>'Invalid listing']); exit; }

// Check if already in watchlist
$existing = DB::fetch('SELECT watchlist_id FROM WATCHLIST WHERE buyer_id=? AND listing_id=?', [$buyerId, $listingId]);

if ($existing) {
    DB::query('DELETE FROM WATCHLIST WHERE watchlist_id=?', [$existing['watchlist_id']]);
    echo json_encode(['success'=>true, 'added'=>false, 'message'=>'Removed from watchlist']);
} else {
    DB::query('INSERT INTO WATCHLIST (buyer_id, listing_id) VALUES (?,?)', [$buyerId, $listingId]);
    echo json_encode(['success'=>true, 'added'=>true, 'message'=>'Added to watchlist']);
}
