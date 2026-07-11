<?php
// api/cart-popup.php returns cart items + active bids 
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
header('Content-Type: application/json');
if (!isLoggedIn()) { echo json_encode([]); exit; }

$uid   = $_SESSION['user_id'];
$items = [];

// 1. Cart items 
try {
    $cartRows = DB::fetchAll(
        'SELECT ci.cart_item_id, l.listing_id, l.title, l.image_url, l.price
         FROM CART_ITEMS ci
         JOIN LISTINGS l ON ci.listing_id = l.listing_id
         WHERE ci.user_id = ? ORDER BY ci.created_at DESC LIMIT 10',
        [$uid]
    );
    foreach ($cartRows as $r) {
        $items[] = [
            'type'          => 'Cart Item',
            'title'         => $r['title'],
            'image_url'     => $r['image_url'],
            'price_display' => '₱' . number_format((float)$r['price'], 2),
            'link'          => '../pages/customer/listing.php?id=' . $r['listing_id'],
        ];
    }
} catch (\Exception $e) {}

// 2. Active bids
try {
    $buyer = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$uid]);
    if ($buyer) {
        $bidRows = DB::fetchAll(
            'SELECT l.listing_id, l.title, l.image_url, a.auction_id, a.current_highest_bid, b.bid_amount
             FROM BIDDINGS b
             JOIN AUCTIONS a ON b.auction_id = a.auction_id
             JOIN LISTINGS l ON a.listing_id = l.listing_id
             WHERE b.buyer_id = ? AND a.status = "Active"
             ORDER BY b.bid_time DESC LIMIT 10',
            [$buyer['buyer_id']]
        );
        foreach ($bidRows as $r) {
            $winning = (float)$r['bid_amount'] >= (float)$r['current_highest_bid'];
            $items[] = [
                'type'          => $winning ? 'Winning Bid' : 'Active Bid',
                'title'         => $r['title'],
                'image_url'     => $r['image_url'],
                'price_display' => '₱' . number_format((float)$r['bid_amount'], 2),
                'link'          => '../pages/customer/auction_room.php?id=' . $r['auction_id'],
            ];
        }
    }
} catch (\Exception $e) {}

echo json_encode($items);
