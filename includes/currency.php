<?php
/**
 * ============================================================
 * ThriftBid - Live Currency Exchange Helper
 * ============================================================
 */

require_once __DIR__ . '/db.php';

const CURRENCY_API_URL = 'https://open.er-api.com/v6/latest/PHP';
const CURRENCY_SUPPORTED = ['PHP', 'USD', 'KRW'];

/**
 * Returns [ 'USD' => 0.0175, 'KRW' => 23.5, 'PHP' => 1.0 ]
 */
function getLiveCurrencyRates(): array {
    static $memo = null;
    if ($memo !== null) return $memo;

    $rates = ['PHP' => 1.0];

    // check todays cached row first
    $cached = DB::fetchAll(
        'SELECT target_currency, exchange_rate, recorded_date
         FROM CURRENCY_RATES
         WHERE base_currency = "PHP"
           AND recorded_date = CURDATE()
         ORDER BY rate_id DESC'
    );

    $haveFreshCache = false;
    if (!empty($cached)) {
        foreach ($cached as $row) {
            $rates[$row['target_currency']] = (float) $row['exchange_rate'];
        }
        if (count($rates) >= count(CURRENCY_SUPPORTED)) {
            $haveFreshCache = true;
        }
    }

    if (!$haveFreshCache) {
        $fetched = fetchRatesFromApi();
        if ($fetched !== null) {
            $rates = array_merge($rates, $fetched);
            persistRates($fetched);
        } elseif (!empty($cached)) {
            // API failed, use the most recent cached rate on file.
            $stale = DB::fetchAll(
                'SELECT target_currency, exchange_rate
                 FROM CURRENCY_RATES
                 WHERE base_currency = "PHP"
                 ORDER BY recorded_date DESC, rate_id DESC'
            );
            foreach ($stale as $row) {
                if (!isset($rates[$row['target_currency']])) {
                    $rates[$row['target_currency']] = (float) $row['exchange_rate'];
                }
            }
        }
    }

    // last resort static fallback so the page never breaks
    $rates += ['USD' => 0.0175, 'KRW' => 23.5];

    return $memo = $rates;
}

function fetchRatesFromApi(): ?array {
    $ctx = stream_context_create(['http' => ['timeout' => 3]]);
    $json = @file_get_contents(CURRENCY_API_URL, false, $ctx);
    if ($json === false) return null;

    $data = json_decode($json, true);
    if (!is_array($data) || ($data['result'] ?? '') !== 'success') return null;

    $rates = $data['rates'] ?? [];
    $out = [];
    foreach (CURRENCY_SUPPORTED as $cur) {
        if ($cur === 'PHP') continue;
        if (isset($rates[$cur])) $out[$cur] = (float) $rates[$cur];
    }
    return $out ?: null;
}

function persistRates(array $rates): void {
    foreach ($rates as $target => $rate) {
        try {
            DB::query(
                'INSERT INTO CURRENCY_RATES (base_currency, target_currency, exchange_rate, recorded_date)
                 VALUES ("PHP", ?, ?, CURDATE())
                 ON DUPLICATE KEY UPDATE exchange_rate = VALUES(exchange_rate)',
                [$target, $rate]
            );
        } catch (\Throwable $e) {
           
        }
    }
}


function convertCurrency(float $php, string $cur = 'PHP'): string {
    $rates = getLiveCurrencyRates();
    $c = $php * ($rates[$cur] ?? 1.0);
    return match ($cur) {
        'USD'   => '$' . number_format($c, 2),
        'KRW'   => '₩' . number_format($c, 0),
        default => '₱' . number_format($c, 2),
    };
}