<?php
// ============================================================
// ThriftBid - pages/seller/buyer_profile.php
// ------------------------------------------------------------
// The seller-side view of a buyer they've actually
// transacted with (username, name, email, phone, order history
// with this seller). Access is restricted to buyers who have at
// least one order with the logged-in seller, so a seller can't
// browse  buyers' contact info platform-wide.
// ============================================================
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('../login.php');
requireRole(['seller', 'admin'], '../login.php');

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id'];
$buyerId  = (int)($_GET['id'] ?? 0);

if (!$buyerId) { 
    header('Location: to-ship.php'); 
    exit; 
}

$isAdmin = ($user['role'] ?? '') === 'admin';

// Privacy guard: only show this buyer's contact info to a seller who has
// actually transacted with them (admins can view any buyer via this page too).
$hasOrder = $isAdmin || (bool) DB::fetch(
    'SELECT order_id FROM ORDERS WHERE buyer_id = ? AND seller_id = ? LIMIT 1', 
    [$buyerId, $sellerId]
);

if (!$hasOrder) { 
    header('Location: to-ship.php'); 
    exit; 
}

// Fetch buyer demographics and total platform order count
$buyer = DB::fetch(
    'SELECT b.*, b.created_at AS joined,
            (SELECT COUNT(*) FROM ORDERS WHERE buyer_id = b.buyer_id) AS total_orders_platform
     FROM BUYER b WHERE b.buyer_id = ?',
    [$buyerId]
);

if (!$buyer) { 
    header('Location: to-ship.php'); 
    exit; 
}

// Order history scoped strictly to this seller <-> buyer relationship
$ordersWithMe = DB::fetchAll(
    "SELECT o.order_id, o.created_at AS order_date, o.order_status AS status, l.title,
            (SELECT amount FROM PAYMENTS WHERE order_id = o.order_id AND payment_status = 'Completed' LIMIT 1) AS amount_paid,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id = l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id = l.listing_id
     WHERE o.buyer_id = ? AND l.seller_id = ?
     ORDER BY o.created_at DESC",
    [$buyerId, $sellerId]
);

$totalSpentWithMe = array_sum(array_map(fn($o) => (float)($o['amount_paid'] ?? 0), $ordersWithMe));

renderHead('@' . ($buyer['username'] ?? 'buyer') . ' — Buyer Profile');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('ship', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('ship'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <!-- Navigation Link -->
  <a href="to-ship.php" style="display:inline-flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:16px;text-decoration:none">
    <span class="material-symbols-outlined icon-sm">arrow_back</span>Back to Orders
  </a>

  <!-- Profile Card Header -->
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:28px 32px;margin-bottom:24px;display:flex;align-items:center;gap:24px;flex-wrap:wrap">
    <div style="width:88px;height:88px;border-radius:50%;background:var(--clr-surface-mid);display:flex;align-items:center;justify-content:center;flex-shrink:0;border:2px solid var(--clr-outline)">
      <span class="material-symbols-outlined filled" style="font-size:52px;color:var(--clr-outline)">account_circle</span>
    </div>
    
    <div style="flex:1;min-width:220px">
      <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px;flex-wrap:wrap">
        <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text)">
          <?= htmlspecialchars(($buyer['first_name'] ?? '') . ' ' . ($buyer['last_name'] ?? '')) ?>
        </h1>
        <p style="font-size:11px;color:var(--clr-tertiary)">@<?= htmlspecialchars($buyer['username'] ?? '') ?></p>
        
        <?php if (!empty($buyer['is_verified'])): ?>
          <span class="tb-badge tb-badge-active">Verified</span>
        <?php endif; ?>
        
        <?php if (($buyer['buyer_status'] ?? 'Active') !== 'Active'): ?>
          <span class="tb-badge tb-badge-red"><?= htmlspecialchars($buyer['buyer_status']) ?></span>
        <?php endif; ?>
      </div>
      
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
        Member since <?= !empty($buyer['joined']) ? date('M Y', strtotime($buyer['joined'])) : 'N/A' ?>
      </p>

      <!-- Secure Contact Details -->
      <div style="display:flex;gap:18px;flex-wrap:wrap;margin-top:10px">
        <a href="mailto:<?= htmlspecialchars($buyer['email'] ?? '') ?>" style="display:flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-coral);text-decoration:none;font-weight:600">
          <span class="material-symbols-outlined icon-sm">mail</span><?= htmlspecialchars($buyer['email'] ?? '') ?>
        </a>
        <span style="display:flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-text-variant)">
          <span class="material-symbols-outlined icon-sm">call</span><?= htmlspecialchars($buyer['cellphone_number'] ?? 'N/A') ?>
        </span>
      </div>
    </div>

    <!-- Key Metrics Panel -->
    <div style="display:flex;gap:28px;flex-wrap:wrap">
      <?php 
      $stats = [
        ['val' => count($ordersWithMe), 'label' => 'Orders With You'],
        ['val' => convertCurrency($totalSpentWithMe), 'label' => 'Spent With You'],
        ['val' => $buyer['total_orders_platform'] ?? 0, 'label' => 'Total Orders (Platform)'],
      ]; 
      foreach ($stats as $st): 
      ?>
      <div style="text-align:center">
        <p style="font-family:'Hanken Grotesk',sans-serif;font-size:20px;font-weight:800;color:var(--clr-text)"><?= $st['val'] ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $st['label'] ?></p>
      </div>
      <?php endforeach; ?>
    </div>
  </div>

  <!-- Order History Scoped View -->
  <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:14px">Order History With You</h2>

  <?php if (empty($ordersWithMe)): ?>
  <div style="text-align:center;padding:48px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
    No orders with this buyer yet.
  </div>
  <?php else: ?>
  <div style="display:flex;flex-direction:column;gap:10px">
    <?php foreach ($ordersWithMe as $o): ?>
    <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:14px 18px;display:flex;align-items:center;gap:14px;flex-wrap:wrap">
      <div style="width:52px;height:52px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
        <?php if (!empty($o['cover_image'])): ?>
          <img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover">
        <?php else: ?>
          <span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span>
        <?php endif; ?>
      </div>
      <div style="flex:1;min-width:200px">
        <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
          Order #<?= $o['order_id'] ?> &bull; <?= date('M d, Y', strtotime($o['order_date'])) ?>
        </p>
      </div>
      <?php if (!empty($o['amount_paid'])): ?>
        <p style="font-weight:700;color:var(--clr-coral)"><?= convertCurrency((float)$o['amount_paid']) ?></p>
      <?php endif; ?>
      <span class="tb-badge tb-badge-blue"><?= htmlspecialchars($o['status']) ?></span>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>

</div>
</main>
</div>
</body>
</html>