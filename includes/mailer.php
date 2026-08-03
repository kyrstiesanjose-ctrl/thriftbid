<?php
/* ThriftBid - includes/mailer.php
   Sends via Gmail's own SMTP servers (App Password) - Gmail signing its
   own outgoing mail with its own DKIM key works
   Send order:
     1) Raw-socket SMTP (STARTTLS + AUTH LOGIN) - no PHPMailer/composer needed
     2) PHPMailer, only if separately composer-installed
     3) Native mail() - needs a real MTA on the server
     4) storage/mail_log.txt - last-resort log if every send path fails
   Only SMTP_HOST/USER/PASS in config.php need to be set - see EMAIL_SETUP.md. */
require_once __DIR__ . '/config.php';

function sendMail(string $toEmail, string $toName, string $subject, string $htmlBody): bool {
    $attempts = [];

    /* Seed/demo accounts use @example.com (an IANA-reserved domain that
       can never be a real inbox) on purpose, so importing test data or
       clicking around a demo never burns real send attempts or Gmail's
       daily sending quota. Swap a specific account's email to a real
       address in seed.sql (and, if it's one of the login.php quick-login
       buttons, update that too) whenever you actually want that account
       to receive real mail - everything else stays permanently inert. */
    if (preg_match('/@example\.com$/i', $toEmail)) {
        logMail($toEmail, $subject, $htmlBody, ['Skipped: test/demo address (@example.com), no real send attempted'], true);
        return true;
    }

    /* 1) Dependency-free raw SMTP */
    if (defined('SMTP_HOST') && SMTP_HOST) {
        [$ok, $log] = smtpSend($toEmail, $toName, $subject, $htmlBody);
        $attempts[] = "SMTP: " . ($ok ? 'sent' : 'FAILED') . "\n$log";
        if ($ok) { logMail($toEmail, $subject, $htmlBody, $attempts, true); return true; }
    } else {
        $attempts[] = 'SMTP: skipped (SMTP_HOST not set)';
    }

    /* 2) PHPMailer, only if separately composer-installed */
    if (class_exists('PHPMailer\PHPMailer\PHPMailer') && defined('SMTP_HOST') && SMTP_HOST) {
        try {
            $mail = new \PHPMailer\PHPMailer\PHPMailer(true);
            $mail->isSMTP();
            $mail->Host       = SMTP_HOST;
            $mail->SMTPAuth   = true;
            $mail->Username   = SMTP_USER;
            $mail->Password   = SMTP_PASS;
            $mail->SMTPSecure = \PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port       = defined('SMTP_PORT') ? SMTP_PORT : 587;
            $mail->setFrom(defined('MAIL_FROM') ? MAIL_FROM : SMTP_USER, 'ThriftBid');
            $mail->addAddress($toEmail, $toName);
            $mail->isHTML(true);
            $mail->Subject = $subject;
            $mail->Body    = $htmlBody;
            $mail->AltBody = strip_tags($htmlBody);
            $mail->send();
            $attempts[] = 'PHPMailer: sent';
            logMail($toEmail, $subject, $htmlBody, $attempts, true);
            return true;
        } catch (\Throwable $e) {
            $attempts[] = 'PHPMailer: FAILED — ' . $e->getMessage();
        }
    }

    /* 3) Native mail() - needs a real local MTA configured */
    $headers = "MIME-Version: 1.0\r\nContent-type: text/html; charset=UTF-8\r\n";
    $headers .= 'From: ThriftBid <' . (defined('MAIL_FROM') ? MAIL_FROM : 'no-reply@thriftbid.local') . ">\r\n";
    if (@mail($toEmail, $subject, $htmlBody, $headers)) {
        $attempts[] = 'native mail(): sent';
        logMail($toEmail, $subject, $htmlBody, $attempts, true);
        return true;
    }
    $attempts[] = 'native mail(): FAILED (no local MTA configured)';

    /* 4) Nothing worked - log honestly and return false */
    logMail($toEmail, $subject, $htmlBody, $attempts, false);
    return false;
}

/**
 * Minimal SMTP client: connects, STARTTLS, AUTH LOGIN, sends one HTML email.
 * No external libraries. Returns [bool success, string transcriptLog].
 */
function smtpSend(string $toEmail, string $toName, string $subject, string $htmlBody): array {
    $host = SMTP_HOST;
    $port = defined('SMTP_PORT') ? (int) SMTP_PORT : 587;
    $user = defined('SMTP_USER') ? SMTP_USER : '';
    $pass = defined('SMTP_PASS') ? SMTP_PASS : '';
    $from = defined('MAIL_FROM') ? MAIL_FROM : $user;
    $log  = '';

    $read = function ($sock) use (&$log) {
        $data = '';
        while ($line = fgets($sock, 515)) {
            $data .= $line;
            if (isset($line[3]) && $line[3] === ' ') break;
        }
        $log .= $data;
        return $data;
    };
    $write = function ($sock, string $cmd) use (&$log) {
        $log .= (stripos($cmd, 'AUTH') === 0 ? "[credential omitted]\r\n" : "> $cmd\r\n");
        fwrite($sock, $cmd . "\r\n");
    };

    $errno = 0; $errstr = '';
    $sock = @stream_socket_client("tcp://$host:$port", $errno, $errstr, 10);
    if (!$sock) {
        return [false, "Could not connect to $host:$port — $errstr ($errno)"];
    }
    stream_set_timeout($sock, 10);

    $read($sock);
    $write($sock, "EHLO thriftbid.local");
    $read($sock);

    $write($sock, "STARTTLS");
    $resp = $read($sock);
    if (strpos($resp, '220') === false) {
        fclose($sock);
        return [false, "STARTTLS refused by server.\n$log"];
    }
    if (!@stream_socket_enable_crypto($sock, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
        fclose($sock);
        return [false, "TLS handshake failed.\n$log"];
    }

    $write($sock, "EHLO thriftbid.local");
    $read($sock);

    $write($sock, "AUTH LOGIN");
    $read($sock);
    $write($sock, base64_encode($user));
    $read($sock);
    $write($sock, base64_encode($pass));
    $authResp = $read($sock);
    if (strpos($authResp, '235') === false) {
        fclose($sock);
        return [false, "Authentication failed — check SMTP_USER/SMTP_PASS.\n$log"];
    }

    $write($sock, "MAIL FROM:<$from>");
    $read($sock);
    $write($sock, "RCPT TO:<$toEmail>");
    $rcptResp = $read($sock);
    if (strpos($rcptResp, '250') === false) {
        fclose($sock);
        return [false, "Recipient rejected: $toEmail\n$log"];
    }
    $write($sock, "DATA");
    $read($sock);

    $headers  = "From: ThriftBid <$from>\r\n";
    $headers .= "To: " . ($toName ? "$toName <$toEmail>" : $toEmail) . "\r\n";
    $headers .= "Subject: $subject\r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    $headers .= "Content-Transfer-Encoding: 8bit\r\n";
    $body = preg_replace('/\n\./', "\n..", $htmlBody);

    fwrite($sock, $headers . "\r\n" . $body . "\r\n.\r\n");
    $dataResp = $read($sock);
    $write($sock, "QUIT");
    fclose($sock);

    if (strpos($dataResp, '250') === false) {
        return [false, "Server rejected the message body.\n$log"];
    }
    return [true, $log];
}

function logMail(string $to, string $subject, string $body, array $attempts, bool $succeeded): void {
    $logDir = __DIR__ . '/../storage';
    if (!is_dir($logDir)) @mkdir($logDir, 0775, true);
    $status = $succeeded ? 'SENT' : 'NOT SENT — see attempts below';
    @file_put_contents(
        $logDir . '/mail_log.txt',
        '[' . date('Y-m-d H:i:s') . "] To: $to | Subject: $subject | $status\n"
      . implode("\n", $attempts) . "\n\n--- message body ---\n$body\n\n=====\n\n",
        FILE_APPEND
    );
}

/**
 * Communication / email-forwarding: sends whatever's waiting in
 * EMAIL_QUEUE (populated by DB triggers — see schema.sql). Two kinds of
 * rows:
 *   - template IS NULL: simple stored subject/body, sent as-is (the
 *     "new order" and "shipped" emails).
 *   - template IS SET: subject/body are built here from live order data
 *     via buildTemplatedEmail() (payment confirmation, auction win).
 * Call this opportunistically on any page load (see layout.php) — it's a
 * cheap no-op SELECT when the queue is empty, no real cron job needed.
 */
function flushEmailQueue(int $limit = 10): void {
    require_once __DIR__ . '/db.php';

    try {
        /* LIMIT interpolated directly, not bound - with
           PDO::ATTR_EMULATE_PREPARES=false (db.php), MySQL rejects a
           string-bound LIMIT. $limit is typed int, so this is safe. */
        $pending = DB::fetchAll("SELECT * FROM EMAIL_QUEUE WHERE is_sent = 0 ORDER BY created_at ASC LIMIT $limit");
    } catch (\Throwable $e) {
        return; /* table not migrated yet, or DB unreachable - fail silently */
    }

    /* Hard wall-clock ceiling for the whole loop, not just one socket
       read. Each email is a full SMTP round-trip (EHLO/STARTTLS/AUTH/
       MAIL FROM/RCPT TO/DATA/QUIT) - a per-read timeout alone doesn't
       bound how long a slow or half-rate-limited server can drag a
       BATCH out to. Stop early and leave the rest for the next flush,
       rather than risk PHP's own 120s execution-time limit killing the
       whole page request. */
    $startedAt = time();
    $maxSeconds = 60;

    foreach ($pending as $row) {
        if (time() - $startedAt > $maxSeconds) {
            error_log('[ThriftBid mailer] flushEmailQueue stopped early after ' . $maxSeconds . 's - remaining rows will retry next flush.');
            break;
        }

        $isSeller = $row['recipient_type'] === 'Seller';
        $table = $isSeller ? 'SELLER' : 'BUYER';
        $idCol = $isSeller ? 'seller_id' : 'buyer_id';
        /* SELLER has no first_name column, only BUYER does - one COALESCE
           for both tables would throw "Unknown column" for a seller email */
        $nameExpr = $isSeller ? 'COALESCE(shop_name, username)' : 'COALESCE(first_name, username)';

        try {
            $person = DB::fetch("SELECT email, $nameExpr AS display_name FROM $table WHERE $idCol = ?", [$row['recipient_id']]);
        } catch (\Throwable $e) {
            $person = null;
        }

        /* No matching account/email at all - unrecoverable, mark handled
           so it doesn't get retried forever for no reason. */
        if (!$person || !$person['email']) {
            try {
                DB::query('UPDATE EMAIL_QUEUE SET is_sent = 1, sent_at = NOW() WHERE queue_id = ?', [$row['queue_id']]);
            } catch (\Throwable $e) { /* ignore */ }
            continue;
        }

        $subject = $row['subject'];
        $body    = $row['body'];
        $templateBroken = false;

        if (!empty($row['template'])) {
            try {
                [$subject, $body] = buildTemplatedEmail($row['template'], (int)$row['related_order_id']);
            } catch (\Throwable $e) {
                error_log('[ThriftBid mailer] Template build failed for ' . $row['template'] . ': ' . $e->getMessage());
                /* Broken template data (e.g. order got deleted) won't fix
                   itself by retrying - mark handled, not left stuck forever. */
                $templateBroken = true;
            }
        }

        if ($templateBroken) {
            try {
                DB::query('UPDATE EMAIL_QUEUE SET is_sent = 1, sent_at = NOW() WHERE queue_id = ?', [$row['queue_id']]);
            } catch (\Throwable $e) { /* ignore */ }
            continue;
        }

        $sent = sendMail($person['email'], $person['display_name'] ?: '', $subject, $body);

        /* Only mark handled if it actually sent. A genuine failure (rate
           limit, temporary SMTP hiccup, etc.) is left as is_sent=0 so the
           next flush retries it - marking it sent here would silently
           lose the email forever the moment Gmail's daily cap is hit. */
        if ($sent) {
            try {
                DB::query('UPDATE EMAIL_QUEUE SET is_sent = 1, sent_at = NOW() WHERE queue_id = ?', [$row['queue_id']]);
            } catch (\Throwable $e) { /* ignore */ }
        }
    }
}

/**
 * Pulls everything a detailed order email might need in one query:
 * buyer/seller contact info, the order's snapshotted shipping address,
 * payment details (if paid), and shipment/courier details (if shipped).
 * Any auction-specific fields are fetched separately by the caller since
 * not every order came from an auction.
 */
function fetchOrderEmailContext(int $orderId): ?array {
    require_once __DIR__ . '/db.php';

    return DB::fetch(
        "SELECT o.order_id, o.order_date, o.status,
                l.listing_id, l.title,
                bu.buyer_id, COALESCE(bu.first_name, bu.username) AS buyer_name, bu.email AS buyer_email, bu.cellphone_number AS buyer_phone,
                se.seller_id, COALESCE(se.shop_name, se.username) AS seller_name, se.email AS seller_email, se.cellphone_number AS seller_phone,
                p.payment_method, p.amount_paid, p.currency, p.gateway_reference_token, p.payment_date,
                o.shipping_street AS street_address, o.shipping_city AS city, o.shipping_province AS province, o.shipping_zip AS zip_code,
                sh.tracking_number, co.courier_name
         FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id = l.listing_id
         JOIN BUYER bu   ON o.buyer_id = bu.buyer_id
         JOIN SELLER se  ON o.seller_id = se.seller_id
         LEFT JOIN PAYMENTS p ON o.order_id = o.order_id AND p.payment_status = 'Completed'
         LEFT JOIN SHIPMENTS sh ON sh.order_id = o.order_id
         LEFT JOIN COURIERS co ON co.courier_id = sh.courier_id
         WHERE o.order_id = ?
         LIMIT 1",
        [$orderId]
    ) ?: null;
}

/** Small HTML helper: one label/value row inside the order-detail table used by every template below. */
function _emailRow(string $label, string $value): string {
    return '<tr><td style="padding:4px 12px 4px 0;color:#777;white-space:nowrap">' . htmlspecialchars($label) . '</td>'
         . '<td style="padding:4px 0;font-weight:600;color:#1a1a1a">' . $value . '</td></tr>';
}

function _emailWrapper(string $heading, string $intro, string $rowsHtml, string $footerNote = ''): string {
    return '<div style="font-family:sans-serif;max-width:520px;margin:0 auto;color:#1a1a1a">'
         . '<h2 style="color:#ff6b6b;margin-bottom:4px">ThriftBid</h2>'
         . '<h3 style="margin:0 0 12px">' . htmlspecialchars($heading) . '</h3>'
         . '<p>' . $intro . '</p>'
         . '<table style="border-collapse:collapse;width:100%;margin:14px 0;border-top:1px solid #eee;border-bottom:1px solid #eee">' . $rowsHtml . '</table>'
         . ($footerNote ? '<p style="color:#777;font-size:13px">' . $footerNote . '</p>' : '')
         . '</div>';
}

/**
 * Builds the subject/body for a templated EMAIL_QUEUE row. Returns
 * [subject, htmlBody]. Throws if the order/template combo can't be
 * resolved, which flushEmailQueue() catches and logs rather than sending
 * a broken email.
 */
function buildTemplatedEmail(string $template, int $orderId): array {
    $ctx = fetchOrderEmailContext($orderId);
    if (!$ctx) throw new \RuntimeException("No order context found for order #$orderId");

    $orderedAt = date('M d, Y \a\t h:i A', strtotime($ctx['order_date']));
    $address = trim(implode(', ', array_filter([$ctx['street_address'], $ctx['city'], $ctx['province'], $ctx['zip_code']])));

    // Dynamic Currency Formatting
    $cur = $ctx['currency'] ?? 'PHP';
    $sym = match($cur) {
        'USD' => '$',
        'KRW' => '₩',
        default => '₱'
    };
    $decimals = $cur === 'KRW' ? 0 : 2;
    $formattedAmount = $sym . number_format((float)($ctx['amount_paid'] ?? 0), $decimals);

    switch ($template) {

        case 'payment_confirmed_buyer':
            $rows = _emailRow('Order #', (string)$ctx['order_id'])
                  . _emailRow('Item', htmlspecialchars($ctx['title']))
                  . _emailRow('Amount Paid', $formattedAmount)
                  . _emailRow('Payment Method', htmlspecialchars($ctx['payment_method'] ?? 'N/A'))
                  . _emailRow('Reference No.', htmlspecialchars($ctx['gateway_reference_token'] ?? 'N/A'))
                  . _emailRow('Date & Time', $ctx['payment_date'] ? date('M d, Y \a\t h:i A', strtotime($ctx['payment_date'])) : $orderedAt)
                  . _emailRow('Sold By', htmlspecialchars($ctx['seller_name']));
            return [
                'Payment Confirmed — Order #' . $ctx['order_id'],
                _emailWrapper('Payment Confirmed', 'Hi ' . htmlspecialchars($ctx['buyer_name']) . ', we\'ve confirmed your payment for the order below.', $rows,
                    'Your seller has been notified and will prepare your order for shipping. You\'ll get another email the moment it ships.'),
            ];

        case 'payment_confirmed_seller':
            $rows = _emailRow('Order #', (string)$ctx['order_id'])
                  . _emailRow('Item', htmlspecialchars($ctx['title']))
                  . _emailRow('Ordered On', $orderedAt)
                  . _emailRow('Buyer', htmlspecialchars($ctx['buyer_name']))
                  . _emailRow('Buyer Email', htmlspecialchars($ctx['buyer_email']))
                  . _emailRow('Buyer Phone', htmlspecialchars($ctx['buyer_phone'] ?? 'N/A'))
                  . _emailRow('Delivering To', htmlspecialchars($address ?: 'No address on file'))
                  . _emailRow('Amount Paid', $formattedAmount)
                  . _emailRow('Payment Method', htmlspecialchars($ctx['payment_method'] ?? 'N/A'))
                  . _emailRow('Payment Reference', htmlspecialchars($ctx['gateway_reference_token'] ?? 'N/A'))
                  . _emailRow('Payment Date & Time', $ctx['payment_date'] ? date('M d, Y \a\t h:i A', strtotime($ctx['payment_date'])) : $orderedAt);
            return [
                'Payment Received — Order #' . $ctx['order_id'],
                _emailWrapper('Payment Received', 'Hi ' . htmlspecialchars($ctx['seller_name']) . ', payment for the order below has cleared.', $rows,
                    '<strong>Please ship this order within 48 hours.</strong> Once you have a tracking number, mark it shipped from your Seller Center so the buyer gets notified automatically.'),
            ];

        case 'auction_won_buyer':
            $bid = DB::fetch(
                'SELECT MAX(b.bid_amount) amt, b.bid_currency FROM BIDDINGS b JOIN AUCTIONS a ON b.auction_id=a.auction_id
                 WHERE a.listing_id=? AND b.buyer_id=? AND b.is_deleted=0 GROUP BY b.bid_currency',
                [$ctx['listing_id'], $ctx['buyer_id']]
            );
            
            $bidFormatted = '-';
            if ($bid) {
                $bidCur = $bid['bid_currency'] ?? 'PHP';
                $bidSym = match($bidCur) { 'USD' => '$', 'KRW' => '₩', default => '₱' };
                $bidDec = $bidCur === 'KRW' ? 0 : 2;
                $bidFormatted = $bidSym . number_format((float)$bid['amt'], $bidDec);
            }

            $rows = _emailRow('Order #', (string)$ctx['order_id'])
                  . _emailRow('Item', htmlspecialchars($ctx['title']))
                  . _emailRow('Winning Bid', $bidFormatted)
                  . _emailRow('Sold By', htmlspecialchars($ctx['seller_name']))
                  . _emailRow('Won On', $orderedAt);
            return [
                'You Won the Auction! Order #' . $ctx['order_id'] . ' — Action Required',
                _emailWrapper('Congratulations, you won!', 'Hi ' . htmlspecialchars($ctx['buyer_name']) . ', your bid won the auction below.', $rows,
                    '<strong style="color:#c0392b">Please complete payment within 24 hours</strong> or your win will be forfeited and the item re-listed to other bidders.'),
            ];

        case 'auction_won_seller':
            $bid = DB::fetch(
                'SELECT MAX(b.bid_amount) amt, b.bid_currency FROM BIDDINGS b JOIN AUCTIONS a ON b.auction_id=a.auction_id
                 WHERE a.listing_id=? AND b.buyer_id=? AND b.is_deleted=0 GROUP BY b.bid_currency',
                [$ctx['listing_id'], $ctx['buyer_id']]
            );
            
            $bidFormatted = '-';
            if ($bid) {
                $bidCur = $bid['bid_currency'] ?? 'PHP';
                $bidSym = match($bidCur) { 'USD' => '$', 'KRW' => '₩', default => '₱' };
                $bidDec = $bidCur === 'KRW' ? 0 : 2;
                $bidFormatted = $bidSym . number_format((float)$bid['amt'], $bidDec);
            }

            $rows = _emailRow('Order #', (string)$ctx['order_id'])
                  . _emailRow('Item', htmlspecialchars($ctx['title']))
                  . _emailRow('Winning Bidder', htmlspecialchars($ctx['buyer_name']))
                  . _emailRow('Winning Bid', $bidFormatted)
                  . _emailRow('Ended On', $orderedAt);
            return [
                'Your Auction Has Ended — Order #' . $ctx['order_id'],
                _emailWrapper('Your auction ended', 'Hi ' . htmlspecialchars($ctx['seller_name']) . ', here\'s a summary of your closed auction.', $rows,
                    'The winning bidder has 24 hours to complete payment. You\'ll get a separate email the moment payment clears, with instructions to ship.'),
            ];

        default:
            throw new \InvalidArgumentException("Unknown email template: $template");
    }
}