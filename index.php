<?php
// index.php — root redirect
require_once __DIR__ . '/includes/auth.php';

$subfolder = '/CBDAD/MCOV1/thriftbid';

if (isLoggedIn()) {
    $role = $_SESSION['user']['role'] ?? 'buyer';
    header('Location: ' . match($role) {
        'admin'     => $subfolder . '/pages/admin/dashboard.php',
        'seller'    => $subfolder . '/pages/seller/dashboard.php',
        'moderator' => $subfolder . '/pages/admin/disputes.php',
        default     => $subfolder . '/pages/customer/home.php',
    });
} else {
    header('Location: ' . $subfolder . '/pages/login.php');
}
exit;
?>