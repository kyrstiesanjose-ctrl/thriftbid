<?php
/**
 * Notifies BidBot to instantly index (or remove) a single listing right
 * after it's created, edited, (de)activated, or soft-deleted - instead
 * of waiting for the next scheduled full rebuild.
 *
 * Always non-fatal: if BidBot is down or slow, the page still saves and
 * redirects normally. The listing just won't be searchable via BidBot
 * until it's reachable again / the next full reindex runs.
 */
function notifyBidBotReindex(int $listingId): void {
    if (!defined('BIDBOT_REINDEX_URL')) return;

    $url = BIDBOT_REINDEX_URL;
    // Resolve a relative URL (the default, e.g. /bidbot-api/reindex-listing)
    // against this same host, since curl needs an absolute URL.
    if (str_starts_with($url, '/')) {
        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $url = $scheme . '://' . ($_SERVER['HTTP_HOST'] ?? 'localhost') . $url;
    }

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST           => true,
        CURLOPT_POSTFIELDS     => json_encode(['listing_id' => $listingId]),
        CURLOPT_HTTPHEADER     => [
            'Content-Type: application/json',
            'X-Internal-Key: ' . (defined('BIDBOT_INTERNAL_KEY') ? BIDBOT_INTERNAL_KEY : ''),
        ],
        CURLOPT_TIMEOUT        => 3,   // don't hang the page if BidBot is slow/unreachable
        CURLOPT_RETURNTRANSFER => true,
    ]);
    @curl_exec($ch);   // best-effort - failures are silently ignored on purpose
}