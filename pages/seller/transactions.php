<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole(['seller','admin']);

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id']; // session row IS the seller row now

$dateFrom = trim($_GET['from'] ?? '');
$dateTo   = trim($_GET['to'] ?? '');
$groupBy  = ($_GET['group'] ?? 'day') === 'month' ? 'month' : 'day';
$q        = trim($_GET['q'] ?? '');
$method   = in_array($_GET['method'] ?? '', ['GCash','Bank'], true) ? $_GET['method'] : '';
$sort     = ($_GET['sort'] ?? 'date_desc');
$validSorts = ['date_desc','date_asc','amount_desc','amount_asc'];
if (!in_array($sort, $validSorts, true)) $sort = 'date_desc';

$where  = 'o.seller_id=?';
$params = [$sellerId];
if ($dateFrom) { $where .= ' AND t.transaction_date >= ?'; $params[] = $dateFrom . ' 00:00:00'; }
if ($dateTo)   { $where .= ' AND t.transaction_date <= ?'; $params[] = $dateTo . ' 23:59:59'; }
if ($method)   { $where .= ' AND p.payment_method=?'; $params[] = $method; }
if ($q !== '') {
    $where .= ' AND (l.title LIKE ? OR o.order_id=? OR p.gateway_reference_token LIKE ?)';
    $params[] = "%$q%"; $params[] = (int)$q; $params[] = "%$q%";
}

$orderBySql = match($sort) {
    'date_asc'    => 't.transaction_date ASC',
    'amount_desc' => 't.amount DESC',
    'amount_asc'  => 't.amount ASC',
    default       => 't.transaction_date DESC',
};

// Export to CSV, matches the reference's "Download Statement" action.

if (($_GET['export'] ?? '') === 'csv') {
    $rows = DB::fetchAll(
        "SELECT t.transaction_date, o.order_id, l.title, p.payment_method, p.gateway_reference_token, t.amount
         FROM TRANSACTIONS t
         JOIN ORDERS o    ON t.order_id=o.order_id
         JOIN LISTINGS l  ON o.listing_id=l.listing_id
         JOIN PAYMENTS p  ON t.payment_id=p.payment_id
         WHERE $where
         ORDER BY $orderBySql",
        $params
    );
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="thriftbid-transactions-' . date('Y-m-d') . '.csv"');
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Date', 'Order #', 'Item', 'Payment Method', 'Reference', 'Amount (PHP)']);
    foreach ($rows as $r) {
        fputcsv($out, [$r['transaction_date'], $r['order_id'], $r['title'], $r['payment_method'], $r['gateway_reference_token'] ?? 'N/A', $r['amount']]);
    }
    fclose($out);
    exit;
}

$total = DB::fetch(
    "SELECT COUNT(*) c FROM TRANSACTIONS t
     JOIN ORDERS o   ON t.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN PAYMENTS p ON t.payment_id=p.payment_id
     WHERE $where",
    $params
)['c'] ?? 0;

$transactions = DB::fetchAll(
    "SELECT t.*, o.order_id, l.title, bu.username AS buyer_name, p.payment_method, p.gateway_reference_token
     FROM TRANSACTIONS t
     JOIN ORDERS o    ON t.order_id=o.order_id
     JOIN LISTINGS l  ON o.listing_id=l.listing_id
     JOIN BUYER bu    ON o.buyer_id=bu.buyer_id
     JOIN PAYMENTS p  ON t.payment_id=p.payment_id
     WHERE $where
     ORDER BY $orderBySql",
    $params
);

$totalRevenue = DB::fetch(
    "SELECT COALESCE(SUM(t.amount),0) s FROM TRANSACTIONS t
     JOIN ORDERS o ON t.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN PAYMENTS p ON t.payment_id=p.payment_id
     WHERE $where",
    $params
)['s'] ?? 0;

$thisMonthRevenue = DB::fetch(
    'SELECT COALESCE(SUM(t.amount),0) s FROM TRANSACTIONS t JOIN ORDERS o ON t.order_id=o.order_id
     WHERE o.seller_id=? AND MONTH(t.transaction_date)=MONTH(NOW()) AND YEAR(t.transaction_date)=YEAR(NOW())',
    [$sellerId]
)['s'] ?? 0;

$lastMonthRevenue = DB::fetch(
    'SELECT COALESCE(SUM(t.amount),0) s FROM TRANSACTIONS t JOIN ORDERS o ON t.order_id=o.order_id
     WHERE o.seller_id=? AND MONTH(t.transaction_date)=MONTH(NOW() - INTERVAL 1 MONTH) AND YEAR(t.transaction_date)=YEAR(NOW() - INTERVAL 1 MONTH)',
    [$sellerId]
)['s'] ?? 0;
$monthTrend = $lastMonthRevenue > 0 ? round((($thisMonthRevenue - $lastMonthRevenue) / $lastMonthRevenue) * 100) : null;

function sortLink(string $key, string $label, string $currentSort, array $getParams): string {
    $asc  = $key . '_asc';
    $desc = $key . '_desc';
    $next = $currentSort === $desc ? $asc : $desc;
    $icon = $currentSort === $asc ? 'arrow_upward' : ($currentSort === $desc ? 'arrow_downward' : 'unfold_more');
    $url  = '?' . http_build_query(array_merge($getParams, ['sort' => $next]));
    return '<a href="' . htmlspecialchars($url) . '" style="display:inline-flex;align-items:center;gap:2px;color:inherit;text-decoration:none">'
         . htmlspecialchars($label) . '<span class="material-symbols-outlined" style="font-size:14px">' . $icon . '</span></a>';
}

renderHead('Transactions');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('home', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('transactions'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <!-- Header row: title (left) + Filter/Export buttons (right), matches reference layout -->
  <div style="display:flex;align-items:flex-start;justify-content:space-between;flex-wrap:wrap;gap:12px;margin-bottom:20px">
    <div>
      <h1 class="tb-page-title mb-1">Transaction List</h1>
      <p class="tb-page-subtitle">Every completed payment tied to your orders, this is your revenue ledger.</p>
    </div>
    <div style="display:flex;gap:8px;flex-shrink:0">
      <button type="button" onclick="document.getElementById('filterPanel').classList.toggle('hidden')" class="btn btn-outline btn-sm">
        <span class="material-symbols-outlined icon-sm">calendar_month</span>
        <?= ($dateFrom || $dateTo) ? 'Filtered' : 'Filter By Date' ?>
      </button>
      <a href="?<?= http_build_query(array_merge($_GET, ['export' => 'csv'])) ?>" class="btn btn-primary btn-sm">
        <span class="material-symbols-outlined icon-sm">download</span>Download Statement
      </a>
    </div>
  </div>

  <!-- Collapsible date filter panel -->
  <form method="GET" id="filterPanel" class="<?= ($dateFrom || $dateTo) ? '' : 'hidden' ?>" style="display:flex;align-items:center;flex-wrap:wrap;gap:10px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:12px 14px;margin-bottom:16px">
    <input type="date" name="from" value="<?= htmlspecialchars($dateFrom) ?>" class="tb-input" style="padding:6px 10px;font-size:var(--fs-label-sm)">
    <span style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)">to</span>
    <input type="date" name="to" value="<?= htmlspecialchars($dateTo) ?>" class="tb-input" style="padding:6px 10px;font-size:var(--fs-label-sm)">
    <input type="hidden" name="group" value="<?= $groupBy ?>">
    <?php if ($q): ?><input type="hidden" name="q" value="<?= htmlspecialchars($q) ?>"><?php endif; ?>
    <?php if ($method): ?><input type="hidden" name="method" value="<?= htmlspecialchars($method) ?>"><?php endif; ?>
    <button type="submit" class="btn btn-primary btn-sm">Apply</button>
    <?php if ($dateFrom || $dateTo): ?><a href="?<?= http_build_query(array_diff_key($_GET, ['from'=>1,'to'=>1])) ?>" style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Clear dates</a><?php endif; ?>
  </form>

  <!-- Tight KPI banner cards: first one tinted, matching the reference's highlighted primary metric -->
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
    <div style="background:linear-gradient(135deg,#FFF0EE,#F5F8FF);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:14px 16px;position:relative">
      <span class="material-symbols-outlined icon-sm" style="position:absolute;top:14px;right:14px;color:var(--clr-coral)">payments</span>
      <p style="font-size:11px;color:var(--clr-tertiary);font-weight:600;text-transform:uppercase;letter-spacing:0.04em">Total Revenue<?= ($dateFrom || $dateTo || $q || $method) ? ' (filtered)' : '' ?></p>
      <div style="display:flex;align-items:baseline;gap:8px;margin-top:2px">
        <span style="font-size:22px;font-weight:800;color:var(--clr-text)"><?= convertCurrency((float)$totalRevenue) ?></span>
        <?php if ($monthTrend !== null): ?>
        <span style="font-size:11px;font-weight:700;color:<?= $monthTrend>=0?'var(--clr-success)':'var(--clr-error)' ?>"><?= $monthTrend>=0?'&uarr; +':'&darr; ' ?><?= $monthTrend ?>%</span>
        <?php endif; ?>
      </div>
      <p style="font-size:11px;color:var(--clr-tertiary);margin-top:2px"><?= $monthTrend !== null ? 'from last period' : 'No prior period to compare' ?></p>
    </div>
    <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:14px 16px;position:relative">
      <span class="material-symbols-outlined icon-sm" style="position:absolute;top:14px;right:14px;color:var(--clr-outline-variant)">calendar_month</span>
      <p style="font-size:11px;color:var(--clr-tertiary);font-weight:600;text-transform:uppercase;letter-spacing:0.04em">This Month</p>
      <p style="font-size:22px;font-weight:800;color:var(--clr-text);margin-top:2px"><?= convertCurrency((float)$thisMonthRevenue) ?></p>
    </div>
    <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:14px 16px;position:relative">
      <span class="material-symbols-outlined icon-sm" style="position:absolute;top:14px;right:14px;color:var(--clr-outline-variant)">receipt_long</span>
      <p style="font-size:11px;color:var(--clr-tertiary);font-weight:600;text-transform:uppercase;letter-spacing:0.04em">Total Transactions</p>
      <p style="font-size:22px;font-weight:800;color:var(--clr-text);margin-top:2px"><?= number_format($total) ?></p>
    </div>
  </div>

  <!-- Search + payment-method filter + Day/Month grouping toggle, one row -->
  <form method="GET" style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:16px">
    <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;flex:1">
      <div style="position:relative;flex:1;min-width:200px;max-width:280px">
        <span class="material-symbols-outlined icon-sm" style="position:absolute;left:10px;top:50%;transform:translateY(-50%);color:var(--clr-outline-variant)">search</span>
        <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" placeholder="Search item, order #, or reference" class="tb-input" style="padding:8px 10px 8px 34px;font-size:var(--fs-label-sm);width:100%">
      </div>
      <select name="method" class="tb-select" style="width:auto;padding:8px 10px;font-size:var(--fs-label-sm)" onchange="this.form.submit()">
        <option value="">All Payment Methods</option>
        <option value="GCash" <?= $method==='GCash'?'selected':'' ?>>GCash</option>
        <option value="Bank" <?= $method==='Bank'?'selected':'' ?>>Bank Transfer</option>
      </select>
      <button type="submit" class="btn btn-outline btn-sm">Search</button>
      <input type="hidden" name="from" value="<?= htmlspecialchars($dateFrom) ?>">
      <input type="hidden" name="to" value="<?= htmlspecialchars($dateTo) ?>">
      <input type="hidden" name="group" value="<?= $groupBy ?>">
      <input type="hidden" name="sort" value="<?= $sort ?>">
    </div>
    <div style="display:inline-flex;background:var(--clr-surface-low);border-radius:999px;padding:3px;gap:2px">
      <a href="?<?= http_build_query(array_merge($_GET,['group'=>'day'])) ?>" style="padding:5px 16px;border-radius:999px;font-size:var(--fs-label-sm);font-weight:600;text-decoration:none;transition:all var(--transition);<?= $groupBy==='day' ? 'background:var(--clr-coral);color:#fff' : 'color:var(--clr-tertiary)' ?>">Day</a>
      <a href="?<?= http_build_query(array_merge($_GET,['group'=>'month'])) ?>" style="padding:5px 16px;border-radius:999px;font-size:var(--fs-label-sm);font-weight:600;text-decoration:none;transition:all var(--transition);<?= $groupBy==='month' ? 'background:var(--clr-coral);color:#fff' : 'color:var(--clr-tertiary)' ?>">Month</a>
    </div>
  </form>

  <?php if (empty($transactions)): ?>
  <div class="tb-card tb-card-body text-center" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">receipt_long</span>
    <?= ($q || $method || $dateFrom || $dateTo) ? 'No transactions match your filters.' : 'No transactions yet.' ?>
  </div>
  <?php else:
    $format = $groupBy === 'month' ? 'F Y' : 'F j, Y';
    $paymentBadgeStyle = [
        'GCash' => 'background:#E3F2FD;color:#1565C0',
        'Bank'  => 'background:#EEF0F7;color:#3F4B66',
    ];
  ?>
  <div style="border:1px solid var(--clr-outline);border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-white)">
    <div style="max-height:calc(100vh - 420px);overflow-y:auto;position:relative">
      <table style="width:100%;border-collapse:collapse">
        <?php foreach (groupByDate($transactions, 'transaction_date', $format) as $dateLabel => $rows):
          $groupTotal = array_sum(array_column($rows, 'amount'));
        ?>
        <thead style="position:sticky;top:0;z-index:5">
          <tr>
            <th colspan="7" style="background:var(--clr-surface-low);padding:10px 16px;text-align:left;border-bottom:1px solid var(--clr-outline);border-top:1px solid var(--clr-outline)">
              <div style="display:flex;align-items:baseline;justify-content:space-between">
                <span style="font-size:var(--fs-label-sm);font-weight:800;color:var(--clr-text);text-transform:uppercase;letter-spacing:0.04em"><?= htmlspecialchars($dateLabel) ?></span>
                <span style="font-size:var(--fs-label-sm);font-weight:700;color:var(--clr-success)"><?= convertCurrency((float)$groupTotal) ?> &middot; <?= count($rows) ?> transaction<?= count($rows)!==1?'s':'' ?></span>
              </div>
            </th>
          </tr>
          <tr style="font-size:11px;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.03em;background:var(--clr-white)">
            <th style="text-align:left;padding:8px 16px;font-weight:600"><?= sortLink('date', 'Time', $sort, $_GET) ?></th>
            <th style="text-align:left;padding:8px 16px;font-weight:600">Item</th>
            <th style="text-align:left;padding:8px 16px;font-weight:600">Order</th>
            <th style="text-align:left;padding:8px 16px;font-weight:600">Method</th>
            <th style="text-align:left;padding:8px 16px;font-weight:600">Reference</th>
            <th style="text-align:left;padding:8px 16px;font-weight:600">Status</th>
            <th style="text-align:right;padding:8px 16px;font-weight:600"><?= sortLink('amount', 'Amount', $sort, $_GET) ?></th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($rows as $t): $ref = $t['gateway_reference_token'] ?? ''; $refShort = strlen($ref) > 11 ? substr($ref, 0, 11) . '...' : ($ref ?: 'N/A'); ?>
          <tr style="border-bottom:1px solid var(--clr-outline)">
            <td style="padding:10px 16px;font-size:var(--fs-label-sm);color:#6B7280"><?= date('h:i A', strtotime($t['transaction_date'])) ?></td>
            <td style="padding:10px 16px;font-weight:700;color:var(--clr-text);max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($t['title']) ?></td>
            <td style="padding:10px 16px;font-size:var(--fs-label-sm);color:#6B7280">#<?= $t['order_id'] ?></td>
            <td style="padding:10px 16px">
              <span style="display:inline-block;padding:3px 10px;border-radius:999px;font-size:11px;font-weight:700;<?= $paymentBadgeStyle[$t['payment_method']] ?? 'background:var(--clr-surface-low);color:#6B7280' ?>"><?= htmlspecialchars($t['payment_method']) ?></span>
            </td>
            <td style="padding:10px 16px">
              <?php if ($ref): ?>
              <span class="tx-ref" onclick="copyRef(this, '<?= htmlspecialchars($ref, ENT_QUOTES) ?>')" title="Click to copy" style="font-family:monospace;font-size:11px;color:#6B7280;cursor:pointer;display:inline-flex;align-items:center;gap:4px">
                <?= htmlspecialchars($refShort) ?>
                <span class="material-symbols-outlined" style="font-size:13px;opacity:0.5">content_copy</span>
              </span>
              <?php else: ?>
              <span style="font-size:11px;color:#6B7280">N/A</span>
              <?php endif; ?>
            </td>
            <td style="padding:10px 16px">
              <span style="display:inline-block;padding:3px 10px;border-radius:999px;font-size:11px;font-weight:700;background:#E6F4EA;color:#1E7E34">Success</span>
            </td>
            <td style="padding:10px 16px;text-align:right;font-weight:700;color:var(--clr-success)"><?= convertCurrency((float)$t['amount']) ?></td>
          </tr>
          <?php endforeach; ?>
        </tbody>
        <?php endforeach; ?>
      </table>
    </div>
  </div>
  <?php endif; ?>

</div>
</main>
</div>
<script>
function copyRef(el, ref) {
  navigator.clipboard.writeText(ref).then(() => {
    const icon = el.querySelector('.material-symbols-outlined');
    const original = icon.textContent;
    icon.textContent = 'check';
    icon.style.color = 'var(--clr-success)';
    setTimeout(() => { icon.textContent = original; icon.style.opacity = '0.5'; icon.style.color = ''; }, 1200);
  });
}
</script>
</body></html>