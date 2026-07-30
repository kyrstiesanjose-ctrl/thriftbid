<?php
/* ThriftBid - includes/otp.php
   Generates, emails, and verifies 6-digit OTP codes, backed by the
   EMAIL_OTPS table (schema.sql). Used by:
     - verify-email.php (purpose = 'Registration')
     - checkout.php (purpose = 'Payment') */
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/mailer.php';

const OTP_TTL_MINUTES = 5;

/**
 * Creates a fresh OTP row, invalidates any older unused OTPs for the same
 * owner+purpose(+order), and emails the code. Returns the code (useful for
 * dev/testing when mail isn't configured) or false on failure.
 */
function generateAndSendOtp(string $ownerType, int $ownerId, string $email, string $name, string $purpose, ?int $orderId = null): string|false {
    $code = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    $expiresAt = date('Y-m-d H:i:s', strtotime('+' . OTP_TTL_MINUTES . ' minutes'));

    try {
        /* Invalidates older pending OTPs of the same kind, so only the
           latest requested code is ever valid */
        $sql = 'UPDATE EMAIL_OTPS SET is_used=1 WHERE owner_type=? AND owner_id=? AND purpose=? AND is_used=0';
        $params = [$ownerType, $ownerId, $purpose];
        if ($orderId !== null) { $sql .= ' AND related_order_id=?'; $params[] = $orderId; }
        DB::query($sql, $params);

        DB::insert(
            'INSERT INTO EMAIL_OTPS (owner_type, owner_id, purpose, related_order_id, otp_code, expires_at) VALUES (?,?,?,?,?,?)',
            [$ownerType, $ownerId, $purpose, $orderId, $code, $expiresAt]
        );
    } catch (\Throwable $e) {
        /* Logged to BOTH PHP's error_log (for a real deployment) AND
           storage/mail_log.txt (so it shows up in the same file you're
           already checking, without needing server file access) */
        $msg = '[ThriftBid otp] Could not persist OTP for ' . $ownerType . ' #' . $ownerId . ' (' . $purpose . '): ' . $e->getMessage();
        error_log($msg);
        $logDir = __DIR__ . '/../storage';
        if (!is_dir($logDir)) @mkdir($logDir, 0775, true);
        @file_put_contents($logDir . '/mail_log.txt', '[' . date('Y-m-d H:i:s') . "] $msg\n\n=====\n\n", FILE_APPEND);
        return false;
    }

    $subject = $purpose === 'Payment' ? 'Your ThriftBid Payment Confirmation Code' : 'Verify your ThriftBid account';
    $body = '<div style="font-family:sans-serif;max-width:480px;margin:0 auto">'
          . '<h2 style="color:#ff6b6b">ThriftBid</h2>'
          . '<p>Hi ' . htmlspecialchars($name) . ',</p>'
          . '<p>' . ($purpose === 'Payment'
                ? 'Use the code below to confirm your payment. This authorizes the charge on your order.'
                : 'Use the code below to verify your email and activate your account.') . '</p>'
          . '<p style="font-size:32px;font-weight:800;letter-spacing:6px;color:#1a1a1a">' . $code . '</p>'
          . '<p style="color:#777;font-size:13px">This code expires in ' . OTP_TTL_MINUTES . ' minutes. If you didn\'t request this, you can ignore this email.</p>'
          . '</div>';

    sendMail($email, $name, $subject, $body);
    return $code;
}

/**
 * Verifies a submitted code. On success, marks the OTP row used (single-use)
 * and returns true. Returns false for wrong/expired/already-used codes.
 */
function verifyOtp(string $ownerType, int $ownerId, string $purpose, string $inputCode, ?int $orderId = null): bool {
    $sql = 'SELECT * FROM EMAIL_OTPS WHERE owner_type=? AND owner_id=? AND purpose=? AND is_used=0';
    $params = [$ownerType, $ownerId, $purpose];
    if ($orderId !== null) { $sql .= ' AND related_order_id=?'; $params[] = $orderId; }
    $sql .= ' ORDER BY otp_id DESC LIMIT 1';

    $row = DB::fetch($sql, $params);
    if (!$row) return false;
    if (strtotime($row['expires_at']) < time()) return false;
    if (!hash_equals($row['otp_code'], $inputCode)) return false;

    DB::query('UPDATE EMAIL_OTPS SET is_used=1 WHERE otp_id=?', [$row['otp_id']]);
    return true;
}