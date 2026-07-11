<?php
// ============================================================
// ThriftBid  layout.php  
// ============================================================
require_once __DIR__ . '/auth.php';

//  Head 
function renderHead(string $title = 'ThriftBid'): void { ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= htmlspecialchars($title) ?> | ThriftBid</title>
<link rel="stylesheet" href="../../public/style.css">
<script src="https://cdn.tailwindcss.com?plugins=forms"></script>
<script>
tailwind.config = { theme:{ extend:{ colors:{
  "thrift-coral":"#ff6b6b","thrift-yellow":"#ffc107",
  "on-surface":"#1a1c1c","surface":"#f4f4f4",
  "surface-container":"#eeeeee","outline-variant":"#d8d8d8",
  "tertiary":"#6b6b6b","background":"#f4f4f4","error":"#c0392b",
  "error-container":"#f5e0de","primary-container":"#ff6b6b"
}}}}
</script>
</head>
<?php }

// Head variant
function renderHeadRoot(string $title = 'ThriftBid'): void { ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= htmlspecialchars($title) ?> | ThriftBid</title>
<link rel="stylesheet" href="../public/style.css">
<script src="https://cdn.tailwindcss.com?plugins=forms"></script>
<script>
tailwind.config = { theme:{ extend:{ colors:{
  "thrift-coral":"#ff6b6b","thrift-yellow":"#ffc107",
  "on-surface":"#1a1c1c","surface":"#f4f4f4",
  "surface-container":"#eeeeee","outline-variant":"#d8d8d8",
  "tertiary":"#6b6b6b","background":"#f4f4f4","error":"#c0392b",
  "error-container":"#f5e0de","primary-container":"#ff6b6b"
}}}}
</script>
</head>
<?php }

//  Notification count 
function getUnreadNotifCount(): int {
    if (!isLoggedIn()) return 0;
    try {
        require_once __DIR__ . '/db.php';
        return (int)(DB::fetch('SELECT COUNT(*) c FROM NOTIFICATIONS WHERE user_id=? AND is_read=0', [$_SESSION['user_id']])['c'] ?? 0);
    } catch (\Exception $e) { return 0; }
}

// Cart item count (cart items + active bids)
function getCartCount(): int {
    if (!isLoggedIn()) return 0;
    try {
        require_once __DIR__ . '/db.php';
        $uid = $_SESSION['user_id'];
        // cart items (CART_ITEMS table if exists, else session-based)
        $cart = (int)(DB::fetch('SELECT COUNT(*) c FROM CART_ITEMS WHERE user_id=?', [$uid])['c'] ?? 0);
        // active bids
        $bids = 0;
        $buyer = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$uid]);
        if ($buyer) {
            $bids = (int)(DB::fetch('SELECT COUNT(*) c FROM BIDDINGS b JOIN AUCTIONS a ON b.auction_id=a.auction_id WHERE b.buyer_id=? AND a.status="Active"', [$buyer['buyer_id']])['c'] ?? 0);
        }
        return $cart + $bids;
    } catch (\Exception $e) { return 0; }
}

//  Main Navbar 
function renderNavbar(string $active = 'home', bool $sellerMode = false): void {
    $user     = currentUser();
    $role     = $user['role'] ?? 'buyer';
    $username = htmlspecialchars($user['username'] ?? 'User');
    $nc       = getUnreadNotifCount();
    $cartCnt  = getCartCount();

    $homeHref = match($role) {
        'admin'  => '../../pages/admin/dashboard.php',
        'seller' => '../../pages/seller/dashboard.php',
        default  => '../../pages/customer/home.php',
    }; ?>
<header class="tb-navbar">
  <!-- Brand -->
  <a href="<?= $homeHref ?>" class="tb-navbar-brand">ThriftBid</a>

  <!-- Left nav links -->
  <nav class="tb-nav-links">
    <?php if ($role === 'admin'): ?>
      <a href="../../pages/admin/dashboard.php"  class="tb-nav-link <?= $active==='home'?'active':'' ?>">Dashboard</a>
      <a href="../../pages/admin/users.php"      class="tb-nav-link <?= $active==='users'?'active':'' ?>">Users</a>
      <a href="../../pages/admin/listings.php"   class="tb-nav-link <?= $active==='listings'?'active':'' ?>">Listings</a>
      <a href="../../pages/admin/disputes.php"   class="tb-nav-link <?= $active==='disputes'?'active':'' ?>">Disputes</a>
      <a href="../../pages/admin/reports.php"    class="tb-nav-link <?= $active==='reports'?'active':'' ?>">Reports</a>
    <?php elseif ($role === 'seller' || $sellerMode): ?>
      <a href="../../pages/seller/dashboard.php"       class="tb-nav-link <?= $active==='home'?'active':'' ?>">Overview</a>
      <a href="../../pages/seller/create-listing.php"  class="tb-nav-link <?= $active==='create'?'active':'' ?>">New Listing</a>
      <a href="../../pages/seller/active-auctions.php" class="tb-nav-link <?= $active==='auctions'?'active':'' ?>">Auctions</a>
      <a href="../../pages/seller/to-ship.php"         class="tb-nav-link <?= $active==='ship'?'active':'' ?>">To Ship</a>
      <a href="../../pages/seller/transactions.php"    class="tb-nav-link <?= $active==='transactions'?'active':'' ?>">Transactions</a>
    <?php else: ?>
      <a href="../../pages/customer/home.php"       class="tb-nav-link <?= $active==='home'?'active':'' ?>">Home</a>
      <a href="../../pages/customer/categories.php" class="tb-nav-link <?= $active==='categories'?'active':'' ?>">Categories</a>
      <a href="../../pages/customer/live-bids.php"  class="tb-nav-link <?= $active==='livebids'?'active':'' ?>">Live Bids</a>
      <a href="../../pages/customer/orders.php"     class="tb-nav-link <?= $active==='orders'?'active':'' ?>">Orders</a>
    <?php endif; ?>
  </nav>

  <!-- Search bar (center) -->
  <div class="tb-nav-search">
    <span class="material-symbols-outlined search-icon">search</span>
    <input type="text" id="navSearchInput" placeholder="Search curated vintage..."
      onkeydown="if(event.key==='Enter' && this.value.trim())location.href='../../pages/customer/categories.php?q='+encodeURIComponent(this.value)">
  </div>

  <!-- Right actions -->
  <div class="tb-nav-actions">

    <!-- Cart  buyers only -->
    <?php if ($role === 'buyer'): ?>
    <div class="tb-dropdown" id="cartWrap">
      <button class="tb-nav-icon-btn" onclick="togglePopup('cartPopup')" title="Cart & Active Bids">
        <span class="material-symbols-outlined icon-sm">shopping_cart</span>
        <?php if ($cartCnt > 0): ?>
        <span class="badge-count"><?= $cartCnt ?></span>
        <?php endif; ?>
      </button>
      <div class="tb-cart-popup" id="cartPopup">
        <div class="tb-cart-popup-header">
          <span>Cart &amp; Active Bids</span>
          <a href="../../pages/customer/orders.php" style="font-size:var(--fs-label-sm);color:var(--clr-coral);font-weight:600">View All</a>
        </div>
        <div class="tb-cart-popup-body" id="cartPopupBody">
          <div style="padding:20px;text-align:center;color:var(--clr-tertiary);font-size:var(--fs-label-sm)">Loading...</div>
        </div>
        <div class="tb-cart-popup-footer">
          <a href="../../pages/customer/orders.php?tab=topay" class="btn btn-primary btn-sm" style="flex:1">Checkout</a>
          <a href="../../pages/customer/orders.php?tab=active" class="btn btn-ghost btn-sm" style="flex:1">My Bids</a>
        </div>
      </div>
    </div>
    <?php endif; ?>

    <!-- Help -->
    <div style="position:relative" id="helpWrap">
      <button class="tb-nav-icon-btn" title="Help" onclick="togglePopup('helpMenu')">
        <span class="material-symbols-outlined icon-sm">help_outline</span>
      </button>
      <div id="helpMenu" style="position:absolute;right:0;top:100%;margin-top:4px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);box-shadow:var(--shadow-lg);min-width:200px;overflow:hidden;display:none;z-index:300">
        <div class="tb-dropdown-header">Help &amp; Support</div>
        <a href="#" class="tb-dropdown-item">How Bidding Works</a>
        <a href="#" class="tb-dropdown-item">Payment Guide</a>
        <a href="#" class="tb-dropdown-item">Shipping Policy</a>
        <div class="tb-dropdown-sep"></div>
        <a href="#" class="tb-dropdown-item">Contact Support</a>
      </div>
    </div>

    <!-- Notifications -->
    <div style="position:relative" id="notifWrap">
      <button class="tb-nav-icon-btn" onclick="togglePopup('notifPopup')" title="Notifications">
        <span class="material-symbols-outlined icon-sm">notifications</span>
        <?php if ($nc > 0): ?>
        <span class="badge-count"><?= $nc ?></span>
        <?php endif; ?>
      </button>
      <div class="tb-notif-popup" id="notifPopup">
        <div class="tb-notif-popup-header">
          <span>Notifications</span>
          <a href="../../pages/notifications.php" style="font-size:var(--fs-label-sm);color:var(--clr-coral)">See all</a>
        </div>
        <div class="tb-notif-popup-body" id="notifPopupBody">
          <div style="padding:20px;text-align:center;color:var(--clr-tertiary);font-size:var(--fs-label-sm)">Loading...</div>
        </div>
      </div>
    </div>

    <!-- Profile dropdown (click-toggle,) -->
    <div style="position:relative" id="profileWrap">
      <button class="tb-nav-icon-btn" title="Profile" onclick="togglePopup('profileMenu')" id="profileBtn">
        <span class="material-symbols-outlined icon-sm filled">account_circle</span>
      </button>
      <div id="profileMenu" style="position:absolute;right:0;top:100%;margin-top:4px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);box-shadow:var(--shadow-lg);min-width:180px;overflow:hidden;display:none;z-index:300">
        <div class="tb-dropdown-header"><?= $username ?></div>
        <a href="../../pages/profile.php"           class="tb-dropdown-item">My Profile</a>
        <?php if ($role === 'buyer'): ?>
        <a href="../../pages/customer/orders.php"   class="tb-dropdown-item">My Orders</a>
        <?php endif; ?>
        <?php if ($role === 'buyer'): ?>
        <a href="../../pages/seller/dashboard.php"  class="tb-dropdown-item">Seller Center</a>
        <?php endif; ?>
        <div class="tb-dropdown-sep"></div>
        <a href="../../api/logout.php"              class="tb-dropdown-item danger">Log Out</a>
      </div>
    </div>

  </div><!-- /nav-actions -->
</header>

<script>
// Universal popup toggle  handles notif, cart, profile, help
function togglePopup(id) {

  const notifCart = ['notifPopup', 'cartPopup'];
  const plainMenus = ['profileMenu', 'helpMenu'];

  if (notifCart.includes(id)) {
    const el = document.getElementById(id);
    const isOpen = el.classList.contains('open');
    // close everything
    document.querySelectorAll('.tb-notif-popup,.tb-cart-popup').forEach(p => p.classList.remove('open'));
    plainMenus.forEach(m => { const el2 = document.getElementById(m); if(el2) el2.style.display = 'none'; });
    if (!isOpen) {
      el.classList.add('open');
      if (id === 'notifPopup') loadNotifs();
      if (id === 'cartPopup')  loadCart();
    }
  } else {
    const el = document.getElementById(id);
    if (!el) return;
    const isOpen = el.style.display === 'block';
    // close everything
    document.querySelectorAll('.tb-notif-popup,.tb-cart-popup').forEach(p => p.classList.remove('open'));
    plainMenus.forEach(m => { const el2 = document.getElementById(m); if(el2) el2.style.display = 'none'; });
    el.style.display = isOpen ? 'none' : 'block';
  }
}
// Close all popups on outside click
document.addEventListener('click', e => {
  const inside = ['notifWrap','cartWrap','profileWrap','helpWrap'];
  if (!inside.some(id => e.target.closest('#'+id))) {
    document.querySelectorAll('.tb-notif-popup,.tb-cart-popup').forEach(p => p.classList.remove('open'));
    ['profileMenu','helpMenu'].forEach(m => { const el = document.getElementById(m); if(el) el.style.display='none'; });
  }
});
// Load notifications via fetch
function loadNotifs() {
  fetch('../../api/notifs-popup.php')
    .then(r => r.json())
    .then(data => {
      const body = document.getElementById('notifPopupBody');
      if (!data.length) { body.innerHTML = '<div style="padding:20px;text-align:center;color:var(--clr-tertiary);font-size:12px">No notifications yet</div>'; return; }
      body.innerHTML = data.map(n => `
        <div class="tb-notif-row ${n.is_read==0?'unread':''}">
          <div class="tb-notif-row-icon"><span class="material-symbols-outlined icon-sm">${iconForType(n.notification_type)}</span></div>
          <div style="flex:1;min-width:0">
            <div class="tb-notif-row-title line-clamp-1">${escHtml(n.title)}</div>
            <div class="tb-notif-row-body line-clamp-1">${escHtml(n.message||'')}</div>
          </div>
          <div class="tb-notif-row-time">${n.time_ago}</div>
        </div>
      `).join('');
    }).catch(() => {});
}
function loadCart() {
  fetch('../../api/cart-popup.php')
    .then(r => r.json())
    .then(data => {
      const body = document.getElementById('cartPopupBody');
      if (!data.length) { body.innerHTML = '<div style="padding:20px;text-align:center;color:var(--clr-tertiary);font-size:12px">Your cart is empty</div>'; return; }
      body.innerHTML = data.map(i => `
        <div class="tb-cart-row">
          <div class="tb-cart-row-img">${i.image_url ? `<img src="${escHtml(i.image_url)}" alt="">` : '<span class="material-symbols-outlined icon-sm" style="color:var(--clr-tertiary)">checkroom</span>'}</div>
          <div style="flex:1;min-width:0">
            <div class="tb-cart-row-title line-clamp-1">${escHtml(i.title)}</div>
            <div class="tb-cart-row-type">${escHtml(i.type)}</div>
          </div>
          <div class="tb-cart-row-price">${escHtml(i.price_display)}</div>
        </div>
      `).join('');
    }).catch(() => {});
}
function iconForType(t) {
  return {BID:'gavel',ORDER:'package_2',AUCTION:'timer',SYSTEM:'notifications',PAYMENT:'payments'}[t]||'notifications';
}
function escHtml(s) { const d=document.createElement('div'); d.textContent=s; return d.innerHTML; }
</script>
<?php }

//  Seller sidebar 
function renderSellerSidebar(string $active = 'overview'): void {
    $links = [
        'overview'     => ['icon'=>'dashboard',     'label'=>'Overview',        'href'=>'../../pages/seller/dashboard.php'],
        'create'       => ['icon'=>'add_circle',    'label'=>'Create Listing',  'href'=>'../../pages/seller/create-listing.php'],
        'auctions'     => ['icon'=>'gavel',         'label'=>'Active Auctions', 'href'=>'../../pages/seller/active-auctions.php'],
        'ship'         => ['icon'=>'local_shipping','label'=>'To Ship',         'href'=>'../../pages/seller/to-ship.php'],
        'transactions' => ['icon'=>'history',       'label'=>'Transactions',    'href'=>'../../pages/seller/transactions.php'],
        'analytics'    => ['icon'=>'analytics',     'label'=>'Analytics',       'href'=>'../../pages/seller/analytics.php'],
    ]; ?>
<aside class="tb-sidebar">
  <div class="tb-sidebar-title">Merchant Center</div>
  <div class="tb-sidebar-subtitle">Seller Dashboard</div>
  <nav class="tb-sidebar-nav">
    <?php foreach ($links as $k => $l): ?>
    <a href="<?= $l['href'] ?>" class="tb-sidebar-link <?= $active===$k?'active':'' ?>">
      <span class="material-symbols-outlined"><?= $l['icon'] ?></span><?= $l['label'] ?>
    </a>
    <?php endforeach; ?>
  </nav>
  <div style="margin-top:auto;padding-top:20px">
    <div style="background:rgba(255,107,107,0.06);border:1px solid rgba(255,107,107,0.15);border-radius:var(--radius-sm);padding:14px">
      <p style="font-size:11px;font-weight:700;color:var(--clr-coral);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:4px">Seller Status</p>
      <p style="font-size:var(--fs-label-md);font-weight:600">Active Merchant</p>
      <div class="tb-progress-bar" style="margin-top:8px"><div class="tb-progress-fill" style="width:82%"></div></div>
      <p style="font-size:11px;color:var(--clr-tertiary);margin-top:4px">82% Fulfillment Rate</p>
    </div>
  </div>
</aside>
<?php }

//  Admin sidebar 
function renderAdminSidebar(string $active = 'dashboard'): void {
    $links = [
        'dashboard' => ['icon'=>'dashboard',     'label'=>'Dashboard',  'href'=>'../../pages/admin/dashboard.php'],
        'users'     => ['icon'=>'group',         'label'=>'Users',      'href'=>'../../pages/admin/users.php'],
        'listings'  => ['icon'=>'storefront',    'label'=>'Listings',   'href'=>'../../pages/admin/listings.php'],
        'auctions'  => ['icon'=>'gavel',         'label'=>'Auctions',   'href'=>'../../pages/admin/auctions.php'],
        'disputes'  => ['icon'=>'report_problem','label'=>'Disputes',   'href'=>'../../pages/admin/disputes.php'],
        'penalties' => ['icon'=>'block',         'label'=>'Penalties',  'href'=>'../../pages/admin/penalties.php'],
        'reports'   => ['icon'=>'analytics',     'label'=>'Reports',    'href'=>'../../pages/admin/reports.php'],
    ]; ?>
<aside class="tb-sidebar" style="width:220px;min-width:220px">
  <div class="tb-sidebar-title" style="font-size:16px">Admin Panel</div>
  <nav class="tb-sidebar-nav" style="margin-top:16px">
    <?php foreach ($links as $k => $l): ?>
    <a href="<?= $l['href'] ?>" class="tb-sidebar-link <?= $active===$k?'active':'' ?>">
      <span class="material-symbols-outlined"><?= $l['icon'] ?></span><?= $l['label'] ?>
    </a>
    <?php endforeach; ?>
  </nav>
</aside>
<?php }

//  Footer 
function renderFooter(): void { ?>
<footer class="tb-footer">
  <div style="max-width:var(--sp-container);margin:0 auto">
    <div class="grid grid-cols-2 md:grid-cols-4 gap-8 mb-8">
      <div>
        <span style="font-family:'Hanken Grotesk',sans-serif;font-size:18px;font-weight:800;color:var(--clr-coral)">ThriftBid</span>
        <p style="margin-top:10px;font-size:var(--fs-label-sm);color:var(--clr-tertiary);line-height:1.6">Curated second-hand pieces from trusted sellers.</p>
      </div>
      <div>
        <p style="font-size:var(--fs-label-sm);font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:var(--clr-tertiary);margin-bottom:12px">Shop</p>
        <div style="display:flex;flex-direction:column;gap:8px">
          <a href="../../pages/customer/categories.php" style="font-size:var(--fs-label-md);color:var(--clr-tertiary)">All Categories</a>
          <a href="../../pages/customer/live-bids.php"  style="font-size:var(--fs-label-md);color:var(--clr-tertiary)">Live Auctions</a>
        </div>
      </div>
      <div>
        <p style="font-size:var(--fs-label-sm);font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:var(--clr-tertiary);margin-bottom:12px">Sell</p>
        <div style="display:flex;flex-direction:column;gap:8px">
          <a href="../../pages/seller/dashboard.php"      style="font-size:var(--fs-label-md);color:var(--clr-tertiary)">Seller Center</a>
          <a href="../../pages/seller/create-listing.php" style="font-size:var(--fs-label-md);color:var(--clr-tertiary)">Create Listing</a>
        </div>
      </div>
      <div>
        <p style="font-size:var(--fs-label-sm);font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:var(--clr-tertiary);margin-bottom:12px">Support</p>
        <div style="display:flex;flex-direction:column;gap:8px">
          <a href="#" style="font-size:var(--fs-label-md);color:var(--clr-tertiary)">Privacy Policy</a>
          <a href="#" style="font-size:var(--fs-label-md);color:var(--clr-tertiary)">Terms of Service</a>
        </div>
      </div>
    </div>
    <div style="border-top:1px solid var(--clr-outline);padding-top:16px">
      <p style="font-size:11px;color:var(--clr-tertiary)">© 2025 ThriftBid. All Rights Reserved.</p>
    </div>
  </div>
</footer>
<?php }

//  Helpers
function flash(string $key, string $msg = ''): string {
    if ($msg) { $_SESSION['flash'][$key] = $msg; return ''; }
    $m = $_SESSION['flash'][$key] ?? ''; unset($_SESSION['flash'][$key]); return $m;
}
function convertCurrency(float $php, string $cur = 'PHP'): string {
    $rates = ['PHP'=>1.0,'USD'=>0.0175,'KRW'=>23.5];
    $c = $php * ($rates[$cur] ?? 1.0);
    return match($cur) { 'USD'=>'$'.number_format($c,2), 'KRW'=>'₩'.number_format($c,0), default=>'₱'.number_format($c,2) };
}
function formatTimeLeft(string $end): string {
    $d = strtotime($end) - time();
    if ($d <= 0) return 'Ended';
    if ($d >= 86400) return floor($d/86400).'d '.floor(($d%86400)/3600).'h';
    $h=floor($d/3600); $m=floor(($d%3600)/60); $s=$d%60;
    return str_pad($h,2,'0',STR_PAD_LEFT).':'.str_pad($m,2,'0',STR_PAD_LEFT).':'.str_pad($s,2,'0',STR_PAD_LEFT);
}