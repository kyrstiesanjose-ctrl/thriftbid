<?php

require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? $user['id'];
$orderId = (int)($_GET['order'] ?? 0);

// Valid buyer-side reasons
$BUYER_REASONS = [
    'Item condition misrepresented',
    'Not as described',
    'Not received',
    'Wrong item received',
];

$order = DB::fetch(
    "SELECT o.*, l.title, l.listing_id, COALESCE(se.shop_name, se.username) AS seller_name,
            sh.delivered_date, sh.status AS shipment_status,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN SELLER se ON o.seller_id=se.seller_id
     LEFT JOIN SHIPMENTS sh ON o.order_id=sh.order_id
     WHERE o.order_id=? AND o.buyer_id=?",
    [$orderId, $buyerId]
);
if (!$order) { header('Location: orders.php?tab=receive'); exit; }

// Eligibility window: 7 days from delivery date, or 7 days from shipping date for non-delivery claims.
$referenceDate = $order['delivered_date'] ?? $order['order_date'];
$daysSince = (time() - strtotime($referenceDate)) / 86400;
$withinWindow = $daysSince <= 7;

$existingDispute = DB::fetch(
    "SELECT * FROM DISPUTES WHERE order_id=? AND buyer_id=? AND status IN ('Open','Under Review') ORDER BY opened_at DESC LIMIT 1",
    [$orderId, $buyerId]
);

$errors = [];
$submitted = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $reasonType = $_POST['reason_type'] ?? '';
    $details    = trim($_POST['details'] ?? '');

    if (!$withinWindow) {
        $errors[] = 'The 7 day window to file a dispute for this order has passed.';
    } elseif ($existingDispute) {
        $errors[] = 'You already have an open dispute for this order.';
    } elseif (!in_array($reasonType, $BUYER_REASONS, true)) {
        $errors[] = 'Please select a valid reason.';
    } elseif (!$details) {
        $errors[] = 'Please describe what happened, this helps admin resolve it faster.';
    } else {
        $fullReason = $reasonType . ': ' . $details;
        DB::query(
            'INSERT INTO DISPUTES (order_id, buyer_id, seller_id, reason, status) VALUES (?,?,?,?,"Open")',
            [$orderId, $buyerId, $order['seller_id'], $fullReason]
        );
        DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
            [$order['seller_id'], 'Dispute Filed', 'A buyer filed a dispute on order #' . $orderId . ' (' . $reasonType . '). Admin will review within 5 business days.', 'ORDER']);
        $submitted = true;
    }
}

renderHead('Request Refund - Order #' . $orderId);
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('orders'); ?>
<main style="flex:1">
  <div style="max-width:640px;margin:0 auto;padding:28px var(--sp-margin-desktop) 80px">

    <a href="orders.php?tab=receive" style="display:inline-flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:20px;text-decoration:none">
      <span class="material-symbols-outlined icon-sm">arrow_back</span>Back to Orders
    </a>

    <?php if ($submitted): ?>
    <div class="tb-card tb-card-body" style="text-align:center;padding:48px 24px">
      <span class="material-symbols-outlined icon-xl" style="color:var(--clr-success);display:block;margin-bottom:12px">check_circle</span>
      <h2 style="font-family:'Hanken Grotesk',sans-serif;font-weight:700;font-size:var(--fs-headline-sm)">Dispute Filed</h2>
      <p style="color:var(--clr-tertiary);margin-top:8px">Admin will review this within 5 business days. You can track its status under the Refunds tab.</p>
      <a href="orders.php?tab=refunded" class="btn btn-primary" style="margin-top:20px">View Refunds Tab</a>
    </div>
    <?php else: ?>

    <div class="tb-card tb-card-body" style="margin-bottom:20px">
      <p class="tb-section-label">Order</p>
      <div style="display:flex;gap:14px;margin-top:8px">
        <div style="width:64px;height:64px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0">
          <?php if ($order['cover_image']): ?><img src="<?= htmlspecialchars($order['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php endif; ?>
        </div>
        <div>
          <p style="font-weight:700"><?= htmlspecialchars($order['title']) ?></p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Sold by <?= htmlspecialchars($order['seller_name']) ?> &bull; Order #<?= $orderId ?></p>
        </div>
      </div>
    </div>

    <?php if ($existingDispute): ?>
    <div class="tb-alert tb-alert-warning show mb-6">
      <span class="material-symbols-outlined icon-sm">info</span>
      You already have a <?= strtolower($existingDispute['status']) ?> dispute for this order. Check the Refunds tab for updates.
    </div>
    <?php elseif (!$withinWindow): ?>
    <div class="tb-alert tb-alert-error show mb-6">
      <span class="material-symbols-outlined icon-sm">error</span>
      The 7 day window to request a refund on this order has passed.
    </div>
    <?php else: ?>

    <?php if ($errors): ?>
    <div class="tb-alert tb-alert-error show mb-6">
      <span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars(implode(' ', $errors)) ?>
    </div>
    <?php endif; ?>

    <div class="tb-card tb-card-body">
      <h2 style="font-family:'Hanken Grotesk',sans-serif;font-weight:700;font-size:var(--fs-headline-sm);margin-bottom:6px">Request a Refund</h2>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:18px">Tell us what went wrong. Admin reviews every request within 5 business days and can approve a full refund, a partial refund, or reject it.</p>

      <form method="POST" style="display:flex;flex-direction:column;gap:16px">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
        <div>
          <label class="tb-label">Reason</label>
          <select name="reason_type" class="tb-select" required>
            <option value="">Select a reason</option>
            <?php foreach ($BUYER_REASONS as $r): ?>
            <option value="<?= htmlspecialchars($r) ?>"><?= htmlspecialchars($r) ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div>
          <label class="tb-label">Tell us more</label>
          <textarea name="details" class="tb-input" rows="4" placeholder="Describe what happened, this goes straight to the admin reviewing your case." required></textarea>
        </div>
        <div style="background:var(--clr-info-bg);border-left:3px solid var(--clr-info);border-radius:var(--radius-sm);padding:10px 14px;font-size:var(--fs-label-sm);color:var(--clr-info)">
          Filing a false dispute can result in account penalties. Please only file if the issue is genuine.
        </div>
        <button type="submit" class="btn btn-primary btn-full btn-lg">Submit Dispute</button>
      </form>
    </div>
    <?php endif; ?>
    <?php endif; ?>

  </div>
</main>
<?php renderFooter(); ?>
</body></html>