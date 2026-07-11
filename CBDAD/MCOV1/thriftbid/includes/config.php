<?php
// ============================================================
// ThriftBid - Configuration
// ============================================================


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

// NEED PALA API TO AND NAG UUPDATE FROM TIME TO TIME NOT HARD CODED CHANGE THIS
define('EXCHANGE_RATES', [
    'PHP' => 1.0,
    'USD' => 0.0175,
    'KRW' => 23.5,
]);
?>