<?php
/* flush-now.php - manual, one-time run to process whatever's currently
   stuck in EMAIL_QUEUE (is_sent=0), instead of waiting on any page load.
   Open directly in the browser once, then delete - debug tool, not part
   of the live app. Place in project root (same level as index.php). */
require_once __DIR__ . '/includes/mailer.php';
require_once __DIR__ . '/includes/db.php';

header('Content-Type: text/plain');

$before = DB::fetch('SELECT COUNT(*) c FROM EMAIL_QUEUE WHERE is_sent=0')['c'] ?? 0;
echo "Pending before flush: $before\n";

flushEmailQueue(15); // small batch - re-run this page again if there's more to process

$after = DB::fetch('SELECT COUNT(*) c FROM EMAIL_QUEUE WHERE is_sent=0')['c'] ?? 0;
echo "Pending after flush: $after\n";
echo ($after < $before) ? "Processed " . ($before - $after) . " email(s) - check mail_log.txt for what happened to each.\n" : "Nothing changed - check mail_log.txt and error_log for why.\n";