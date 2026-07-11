<?php
// ============================================================
// ThriftBid - Auth & Session Helpers
// ============================================================
require_once __DIR__ . '/config.php';

if (session_status() === PHP_SESSION_NONE) {
    session_name('THRIFTBID_SESSION');
    session_set_cookie_params(['httponly' => true, 'samesite' => 'Lax']);
    session_start();
}

function isLoggedIn(): bool {
    return isset($_SESSION['user_id']);
}

function currentUser(): array|null {
    return $_SESSION['user'] ?? null;
}

function requireLogin(string $redirect = '/pages/login.php'): void {
    if (!isLoggedIn()) {
        header('Location: ' . $redirect);
        exit;
    }
}

function requireRole(string|array $roles, string $redirect = '/pages/login.php'): void {
    requireLogin($redirect);
    $role = $_SESSION['user']['role'] ?? '';
    $allowed = is_array($roles) ? $roles : [$roles];
    if (!in_array($role, $allowed)) {
        header('Location: /pages/unauthorized.php');
        exit;
    }
}

function loginUser(array $user): void {
    session_regenerate_id(true);
    $_SESSION['user_id']    = $user['user_id'];
    $_SESSION['user']       = [
        'user_id'    => $user['user_id'],
        'username'   => $user['username'],
        'email'      => $user['email'],
        'role'       => $user['role'],
        'is_verified'=> $user['is_verified'],
    ];
}

function logoutUser(): void {
    session_destroy();
    setcookie('THRIFTBID_SESSION', '', time() - 3600, '/');
}

function hashPassword(string $password): string {
    return password_hash($password, PASSWORD_BCRYPT, ['cost' => 10]);
}

function verifyPassword(string $password, string $hash): bool {
    return password_verify($password, $hash);
}

function csrfToken(): string {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function verifyCsrf(string $token): bool {
    return hash_equals($_SESSION['csrf_token'] ?? '', $token);
}
