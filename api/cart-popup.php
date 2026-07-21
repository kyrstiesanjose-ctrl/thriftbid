<?php
// api/cart-popup.php returns cart items + active bids
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
header('Content-Type: application/json');

if (!isLoggedIn()) { echo json_encode([]); exit; }

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? 0; 
$items   = [];

if ($buyerId) {
    $imgSub = '(SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image';

    try {
        $cartRows = DB::fetchAll(
            "SELECT ci.cart_item_id, l.listing_id, l.title, l.price, $imgSub
             FROM CART_ITEMS ci
             JOIN LISTINGS l ON ci.listing_id = l.listing_id
             WHERE ci.buyer_id = ? ORDER BY ci.added_at DESC LIMIT 10",
            [$buyerId]
        );
        foreach ($cartRows as $r) {
            $items[] = [
                'type'          => 'Cart Item',
                'title'         => $r['title'],
                'image_url'     => $r['cover_image'],
                'price_display' => '₱' . number_format((float)$r['price'], 2),
                'link'          => '../pages/customer/listing.php?id=' . $r['listing_id'],
            ];
        }
    } catch (\Exception $e) {}

    try {
        $bidRows = DB::fetchAll(
            "SELECT l.listing_id, l.title, $imgSub, a.auction_id, a.current_highest_bid, b.bid_amount
             FROM BIDDINGS b
             JOIN AUCTIONS a ON b.auction_id = a.auction_id
             JOIN LISTINGS l ON a.listing_id = l.listing_id
             WHERE b.buyer_id = ? AND a.status = 'Active' AND b.is_deleted = 0
             ORDER BY b.bid_time DESC LIMIT 10",
            [$buyerId]
        );
        foreach ($bidRows as $r) {
            $winning = (float)$r['bid_amount'] >= (float)$r['current_highest_bid'];
            $items[] = [
                'type'          => $winning ? 'Winning Bid' : 'Active Bid',
                'title'         => $r['title'],
                'image_url'     => $r['cover_image'],
                'price_display' => '₱' . number_format((float)$r['bid_amount'], 2),
                'link'          => '../pages/customer/auction_room.php?id=' . $r['auction_id'],
            ];
        }
    } catch (\Exception $e) {}
}

echo json_encode($items);