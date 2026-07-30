<?php
/* index.php - root redirect. Reached via .htaccess for '/' and any
   non-existent path. Sends a logged-in visitor to their role's
   dashboard, everyone else to the login page. */
require_once __DIR__ . '/includes/auth.php';

if (isLoggedIn()) {
    $role = currentUser()['role'] ?? 'buyer';
    header('Location: ' . BASE_URL . match ($role) {
        'admin'  => '/pages/admin/dashboard.php',
        'seller' => '/pages/seller/dashboard.php',
        default  => '/pages/customer/home.php',
    });
} else {
    header('Location: ' . BASE_URL . '/pages/login.php');
}
exit;