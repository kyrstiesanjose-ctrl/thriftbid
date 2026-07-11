<?php
// api/notifs-popup.php 
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
header('Content-Type: application/json');
if (!isLoggedIn()) { echo json_encode([]); exit; }

$notifs = DB::fetchAll(
    'SELECT notification_id, title, message, notification_type, is_read, created_at
     FROM NOTIFICATIONS WHERE user_id=?
     ORDER BY created_at DESC LIMIT 10',
    [$_SESSION['user_id']]
);

// Mark all as read silently
DB::query('UPDATE NOTIFICATIONS SET is_read=1 WHERE user_id=?', [$_SESSION['user_id']]);

foreach ($notifs as &$n) {
    $diff = time() - strtotime($n['created_at']);
    if      ($diff < 60)   $n['time_ago'] = 'just now';
    elseif  ($diff < 3600) $n['time_ago'] = floor($diff/60).'m ago';
    elseif  ($diff < 86400)$n['time_ago'] = floor($diff/3600).'h ago';
    else                   $n['time_ago'] = date('M d', strtotime($n['created_at']));
}
echo json_encode($notifs);
