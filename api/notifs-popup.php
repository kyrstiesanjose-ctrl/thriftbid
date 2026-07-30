<?php
/* api/notifs-popup.php - feeds the navbar bell dropdown. NOTIFICATIONS
   has separate buyer_id/seller_id columns (no generic user_id), so which
   column to query depends on the logged-in role; admins get neither and
   see an empty list. Also marks everything read as a side effect of
   opening the dropdown. */
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
header('Content-Type: application/json');

if (!isLoggedIn()) { echo json_encode([]); exit; }

$user = currentUser();
$role = $user['role'] ?? '';


$col = match ($role) {
    'buyer'  => 'buyer_id',
    'seller' => 'seller_id',
    default  => null,
};

if (!$col) { echo json_encode([]); exit; }

$id = $user['id'];

/* Fetched BEFORE marking read, so is_read in the response still reflects
   each notification's state at the moment the dropdown was opened (lets
   the frontend highlight what's newly-read this time vs. already seen) */
$notifs = DB::fetchAll(
    "SELECT notification_id, title, message, notification_type, is_read, created_at
     FROM NOTIFICATIONS WHERE $col=?
     ORDER BY created_at DESC LIMIT 10",
    [$id]
);

DB::query("UPDATE NOTIFICATIONS SET is_read=1 WHERE $col=?", [$id]);

/* Relative time labels (just now / Xm ago / Xh ago / M d) for display */
foreach ($notifs as &$n) {
    $diff = time() - strtotime($n['created_at']);
    if      ($diff < 60)   $n['time_ago'] = 'just now';
    elseif  ($diff < 3600) $n['time_ago'] = floor($diff/60).'m ago';
    elseif  ($diff < 86400)$n['time_ago'] = floor($diff/3600).'h ago';
    else                   $n['time_ago'] = date('M d', strtotime($n['created_at']));
}
echo json_encode($notifs);