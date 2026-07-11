<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole(['seller','admin'],'/pages/login.php');

$user     = currentUser();
$seller   = DB::fetch('SELECT seller_id FROM SELLER WHERE user_id=?',[$user['user_id']]);
$sellerId = $seller['seller_id'] ?? 0;
$page     = max(1,(int)($_GET['page'] ?? 1));
$per      = 15; $offset = ($page-1)*$per;

$total = DB::fetch('SELECT COUNT(*) c FROM TRANSACTIONS t JOIN ORDERS o ON t.order_id=o.order_id WHERE o.seller_id=?',[$sellerId])['c'] ?? 0;
$transactions = DB::fetchAll(
    'SELECT t.*,o.order_id,o.status as order_status,o.order_date,l.title,p.payment_method,p.payment_status,u.username as buyer_name
     FROM TRANSACTIONS t
     JOIN ORDERS o ON t.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN PAYMENTS p ON t.payment_id=p.payment_id
     JOIN BUYER by2 ON o.buyer_id=by2.buyer_id
     JOIN USERS u   ON by2.user_id=u.user_id
     WHERE o.seller_id=?
     ORDER BY t.transaction_date DESC LIMIT ? OFFSET ?',
    [$sellerId, $per, $offset]
);
$totalPages = max(1,ceil($total/$per));
$totalEarned = DB::fetch('SELECT COALESCE(SUM(t.amount),0) s FROM TRANSACTIONS t JOIN ORDERS o ON t.order_id=o.order_id JOIN PAYMENTS p ON t.payment_id=p.payment_id WHERE o.seller_id=? AND p.payment_status="Completed"',[$sellerId])['s'] ?? 0;

renderHead('Transactions');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('transactions', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('transactions'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <div class="flex items-start justify-between mb-8">
    <div>
      <h1 class="tb-page-title">Transaction History</h1>
      <p class="tb-page-subtitle">All confirmed sales and payments on your account.</p>
    </div>
    <div class="tb-card tb-card-body" style="text-align:right;min-width:180px">
      <p class="tb-section-label">Total Earned</p>
      <p class="font-headline" style="font-size:var(--fs-headline-md);color:var(--clr-coral);font-weight:800"><?= convertCurrency((float)$totalEarned) ?></p>
    </div>
  </div>

  <?php if (empty($transactions)): ?>
  <div class="text-center py-20" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">receipt_long</span>
    <p style="font-weight:700">No transactions yet</p>
    <p style="margin-top:4px">Transactions appear after buyers complete payment.</p>
  </div>
  <?php else: ?>
  <div class="tb-table-wrapper">
    <table class="tb-table">
      <thead><tr>
        <th>Transaction</th><th>Item</th><th>Buyer</th><th>Method</th><th>Amount</th><th>Status</th><th>Date</th>
      </tr></thead>
      <tbody>
        <?php foreach ($transactions as $t): ?>
        <tr>
          <td style="font-family:monospace;font-size:var(--fs-label-sm);color:var(--clr-tertiary)">#<?= $t['transaction_id'] ?></td>
          <td style="font-weight:600;max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($t['title']) ?></td>
          <td style="color:var(--clr-tertiary)">@<?= htmlspecialchars($t['buyer_name']) ?></td>
          <td><span class="tb-badge tb-badge-gray"><?= htmlspecialchars($t['payment_method']) ?></span></td>
          <td style="font-weight:700;color:var(--clr-coral)"><?= convertCurrency((float)$t['amount']) ?></td>
          <td>
            <span class="tb-badge <?= $t['payment_status']==='Completed'?'tb-badge-green':($t['payment_status']==='Failed'?'tb-badge-red':'tb-badge-yellow') ?>">
              <?= htmlspecialchars($t['payment_status']) ?>
            </span>
          </td>
          <td style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)"><?= date('M d, Y', strtotime($t['transaction_date'])) ?></td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
    <?php if ($totalPages > 1): ?>
    <div class="tb-pagination">
      <p class="tb-pagination-info">Page <?= $page ?> of <?= $totalPages ?></p>
      <div class="tb-pagination-btns">
        <?php if ($page>1): ?><a href="?page=<?=$page-1?>" class="tb-pagination-btn">Prev</a><?php endif; ?>
        <?php if ($page<$totalPages): ?><a href="?page=<?=$page+1?>" class="tb-pagination-btn">Next</a><?php endif; ?>
      </div>
    </div>
    <?php endif; ?>
  </div>
  <?php endif; ?>

</div>
</main>
</div>
</body></html>
