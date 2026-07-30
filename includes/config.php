<?php
/* ThriftBid - Configuration */

/* Keeps PHP's own time()/date() on Asia/Manila, matching db.php's
   SET time_zone = '+08:00' fix. Without this, PHP-side date math (e.g.
   "time ago" labels) can disagree with what's actually stored in the DB. */
date_default_timezone_set('Asia/Manila');


$envFile = __DIR__ . '/../.env'; 
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            [$key, $val] = explode('=', $line, 2);
            $_ENV[trim($key)] = trim($val);
        }
    }
}


define('DB_HOST',        $_ENV['DB_HOST']        ?? 'ccscloud.dlsu.edu.ph');
define('DB_PORT',        $_ENV['DB_PORT']        ?? '22003');
define('DB_USER',        $_ENV['DB_USER']        ?? 'CBDBADM01');
define('DB_PASSWORD',    $_ENV['DB_PASSWORD']    ?? 'y9pSAee2MURj');
define('DB_NAME',        $_ENV['DB_NAME']        ?? 'thriftbid_db2');
define('SESSION_SECRET', $_ENV['SESSION_SECRET'] ?? 'thriftbid_super_secret_key_2025');
define('APP_URL',        $_ENV['APP_URL']        ?? 'http://localhost');

/* Static fallback only - live rates come from currency.php */
define('EXCHANGE_RATES', [
    'PHP' => 1.0,
    'USD' => 0.0175,
    'KRW' => 23.5,
]);

/* EMAIL (OTP delivery - registration verification + checkout OTP)
   Sends via Gmail's own SMTP servers using an App Password  */
define('MAIL_FROM', $_ENV['MAIL_FROM'] ?? 'thriftbid05@gmail.com');

define('DEV_SHOW_OTP', false);
define('SMTP_HOST', $_ENV['SMTP_HOST'] ?? 'smtp.gmail.com');
define('SMTP_PORT', (int)($_ENV['SMTP_PORT'] ?? 587));
define('SMTP_USER', $_ENV['SMTP_USER'] ?? 'thriftbid05@gmail.com');
define('SMTP_PASS', $_ENV['SMTP_PASS'] ?? 'cpvkxfltkhtpjdvp'); /* App Password, spaces removed */
?>