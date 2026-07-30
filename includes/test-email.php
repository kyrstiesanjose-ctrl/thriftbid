<?php
// ============================================================
// test-email.php — put this in your project root (or pages/), open
// it directly in the browser (e.g. http://localhost/.../test-email.php),
// and it will try to send itself a test email and print exactly what
// happened. DELETE THIS FILE once email is confirmed working — it's a
// debug tool, not something that belongs in the live app.
// ============================================================
require_once __DIR__ . '/mailer.php'; // adjust path if you place this file elsewhere

header('Content-Type: text/plain');

$to = $_GET['to'] ?? (defined('SMTP_USER') ? SMTP_USER : '');
if (!$to) {
    echo "Usage: test-email.php?to=your@email.com\n";
    exit;
}

echo "SMTP_HOST configured: " . (defined('SMTP_HOST') && SMTP_HOST ? SMTP_HOST : '(not set)') . "\n";
echo "SMTP_USER configured: " . (defined('SMTP_USER') && SMTP_USER ? SMTP_USER : '(not set)') . "\n";
echo "Sending test email to: $to\n\n";

$ok = sendMail($to, 'Test', 'ThriftBid SMTP Test', '<p>If you are reading this in your inbox, SMTP is working.</p><p>Code: ' . rand(100000, 999999) . '</p>');

echo $ok ? "RESULT: SUCCESS — check your inbox (and spam folder).\n" : "RESULT: FAILED — see storage/mail_log.txt for the exact SMTP transcript/error.\n";

$logPath = __DIR__ . '/storage/mail_log.txt';
if (file_exists($logPath)) {
    echo "\n--- last entry in storage/mail_log.txt ---\n";
    $lines = file($logPath);
    echo implode('', array_slice($lines, -40));
}
