<?php
// ============================================================
// ThriftBid - Auth & Session Helpers
// currentUser() returns the full row from whichever table the
// person authenticated against
// ============================================================
require_once __DIR__ . '/config.php';

// BASE_URL: Automatically calculates the folder path so links and assets don't break when moving between XAMPP and live servers.

if (!defined('BASE_URL')) {
    $projectRoot = str_replace('\\', '/', dirname(__DIR__)); // .../thriftbid (this file lives in includes/)
    $docRoot     = str_replace('\\', '/', rtrim($_SERVER['DOCUMENT_ROOT'] ?? '', '/'));
    $base = ($docRoot && str_starts_with($projectRoot, $docRoot))
        ? substr($projectRoot, strlen($docRoot))
        : '';
    define('BASE_URL', $base); // e.g. '/CBDAD/MCOV1/thriftbid' locally, '' in production at domain root
}

if (session_status() === PHP_SESSION_NONE) {
    session_name('THRIFTBID_SESSION');
    session_set_cookie_params(['httponly' => true, 'samesite' => 'Lax']);
    session_start();
}

function isLoggedIn(): bool {
    return isset($_SESSION['auth']);
}

/**
 * Returns the logged-in person's  and 'id'. Returns null if not logged in.
 */
function currentUser(): array|null {
    return $_SESSION['auth'] ?? null;
}

function requireLogin(?string $redirect = null): void {
    $redirect = $redirect ?? BASE_URL . '/pages/login.php';
    if (!isLoggedIn()) {
        header('Location: ' . $redirect);
        exit;
    }
}

function requireRole(string|array $roles, ?string $redirect = null): void {
    $redirect = $redirect ?? BASE_URL . '/pages/login.php';
    requireLogin($redirect);
    $role = $_SESSION['auth']['role'] ?? '';
    $allowed = is_array($roles) ? $roles : [$roles];
    if (!in_array($role, $allowed)) {
        header('Location: ' . BASE_URL . '/pages/unauthorized.php');
        exit;
    }
}

/**
 * Logs a person in. 
 */

function loginUser(array $row, string $role): void {
    session_regenerate_id(true);

    $idCol = match ($role) {
        'admin'  => 'admin_id',
        'seller' => 'seller_id',
        'buyer'  => 'buyer_id',
    };

    $auth = $row;
    $auth['role'] = $role;
    $auth['id']   = $row[$idCol];

    $auth['user_id'] = $row[$idCol];

    $_SESSION['auth'] = $auth;
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

/**
 * Look up a person by email across all three login tables.
 * Returns ['role' => ..., 'row' => [...]] or null.
 */
function findAccountByEmail(string $email): ?array {
    if ($row = DB::fetch('SELECT * FROM ADMIN WHERE email=?', [$email]))  return ['role' => 'admin',  'row' => $row];
    if ($row = DB::fetch('SELECT * FROM SELLER WHERE email=?', [$email])) return ['role' => 'seller', 'row' => $row];
    if ($row = DB::fetch('SELECT * FROM BUYER WHERE email=?', [$email]))  return ['role' => 'buyer',  'row' => $row];
    return null;
}

/**
 * Rule 8 (Account Verification): "one account per verified contact number."
 * A UNIQUE constraint on cellphone_number only prevents duplicates *within*
 * BUYER or *within* SELLER individually — this checks across both tables,
 * since a phone number registered as a buyer must also block registering
 * that same number as a seller (and vice versa).
 * Returns ['role' => ..., 'row' => [...]] or null.
 */
function findAccountByPhone(string $phone): ?array {
    if ($row = DB::fetch('SELECT * FROM SELLER WHERE cellphone_number=?', [$phone])) return ['role' => 'seller', 'row' => $row];
    if ($row = DB::fetch('SELECT * FROM BUYER WHERE cellphone_number=?', [$phone]))  return ['role' => 'buyer',  'row' => $row];
    return null;
}

/**
 * username is NOT NULL UNIQUE on ADMIN/SELLER/BUYER individually, but that
 * only guards each table on its own - same gap phone/email had. Checks
 * all three so a chosen username can't collide with any existing account,
 * including an admin's.
 */
function findAccountByUsername(string $username): ?array {
    if ($row = DB::fetch('SELECT * FROM ADMIN WHERE username=?', [$username]))  return ['role' => 'admin',  'row' => $row];
    if ($row = DB::fetch('SELECT * FROM SELLER WHERE username=?', [$username])) return ['role' => 'seller', 'row' => $row];
    if ($row = DB::fetch('SELECT * FROM BUYER WHERE username=?', [$username]))  return ['role' => 'buyer',  'row' => $row];
    return null;
}