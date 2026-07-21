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
    $user = currentUser();
    $col = match ($user['role'] ?? '') {
        'buyer'  => 'buyer_id',
        'seller' => 'seller_id',
        default  => null, // admins don't have NOTIFICATIONS rows in schema
    };
    if (!$col) return 0;
    try {
        require_once __DIR__ . '/db.php';
        return (int)(DB::fetch("SELECT COUNT(*) c FROM NOTIFICATIONS WHERE $col=? AND is_read=0", [$user['id']])['c'] ?? 0);
    } catch (\Exception $e) { return 0; }
}

// Cart item count (cart items + active bids), buyers only
function getCartCount(): int {
    if (!isLoggedIn()) return 0;
    $user = currentUser();
    if (($user['role'] ?? '') !== 'buyer') return 0;
    try {
        require_once __DIR__ . '/db.php';
        $buyerId = $user['buyer_id'] ?? $user['id'];
        $cart = (int)(DB::fetch('SELECT COUNT(*) c FROM CART_ITEMS WHERE buyer_id=?', [$buyerId])['c'] ?? 0);
        $bids = (int)(DB::fetch('SELECT COUNT(*) c FROM BIDDINGS b JOIN AUCTIONS a ON b.auction_id=a.auction_id WHERE b.buyer_id=? AND a.status="Active"', [$buyerId])['c'] ?? 0);
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
      <!-- Admin top-nav links  -->
    <?php elseif ($role === 'seller' || $sellerMode): ?>
      <!-- Seller top-nav links  -->
    <?php else: ?>
      <a href="../../pages/customer/home.php"       class="tb-nav-link <?= $active==='home'?'active':'' ?>">Home</a>
      <a href="../../pages/customer/categories.php" class="tb-nav-link <?= $active==='categories'?'active':'' ?>">Categories</a>
      <a href="../../pages/customer/live-bids.php"  class="tb-nav-link <?= $active==='livebids'?'active':'' ?>">Live Bids</a>
      <a href="../../pages/customer/orders.php"     class="tb-nav-link <?= $active==='orders'?'active':'' ?>">My Cart &amp; Orders</a>
    <?php endif; ?>
  </nav>

  <!-- Search bar  -->
  <?php if ($role === 'buyer'): ?>
  <div class="tb-nav-search">
    <span class="material-symbols-outlined search-icon">search</span>
    <input type="text" id="navSearchInput" placeholder="Search curated vintage..."
      onkeydown="if(event.key==='Enter' && this.value.trim())location.href='../../pages/customer/categories.php?q='+encodeURIComponent(this.value)">
  </div>
  <?php endif; ?>

  <!-- Right actions -->
  <div class="tb-nav-actions">

    <!-- Cart -->
    <?php if ($role === 'buyer'): ?>
    <a href="../../pages/customer/orders.php?tab=cart" class="tb-nav-icon-btn" title="Cart">
      <span class="material-symbols-outlined icon-sm">shopping_cart</span>
      <?php if ($cartCnt > 0): ?>
      <span class="badge-count"><?= $cartCnt ?></span>
      <?php endif; ?>
    </a>
    <?php endif; ?>

    <!-- Help -->
    <div style="position:relative" id="helpWrap">
      <button class="tb-nav-icon-btn" title="Help" onclick="togglePopup('helpMenu')">
        <span class="material-symbols-outlined icon-sm">help_outline</span>
      </button>
      <div id="helpMenu" style="position:absolute;right:0;top:100%;margin-top:4px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);box-shadow:var(--shadow-lg);min-width:220px;overflow:hidden;display:none;z-index:300">
        <div class="tb-dropdown-header">Help &amp; Support</div>
        <a href="javascript:void(0)" class="tb-dropdown-item" onclick="openHelpModal('bidding')">How Bidding Works</a>
        <a href="javascript:void(0)" class="tb-dropdown-item" onclick="openHelpModal('listing')">How to Create a Listing</a>
        <a href="javascript:void(0)" class="tb-dropdown-item" onclick="openHelpModal('payment')">Payment Guide</a>
        <a href="javascript:void(0)" class="tb-dropdown-item" onclick="openHelpModal('policies')">Policies, Penalties &amp; Reporting</a>
        <div class="tb-dropdown-sep"></div>
        <a href="javascript:void(0)" class="tb-dropdown-item" onclick="openHelpModal('contact')">Contact Support</a>
      </div>
    </div>

    <!-- Help & Support content modal -->
    <div id="helpModalOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.45);z-index:500;align-items:center;justify-content:center;padding:20px" onclick="if(event.target===this) closeHelpModal()">
      <div style="background:#fff;border-radius:var(--radius-lg);max-width:520px;width:100%;max-height:80vh;overflow-y:auto;box-shadow:var(--shadow-lg)">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:18px 22px;border-bottom:1px solid var(--clr-outline)">
          <h3 id="helpModalTitle" style="font-family:'Hanken Grotesk',sans-serif;font-weight:700;font-size:var(--fs-headline-sm);color:var(--clr-text)"></h3>
          <button onclick="closeHelpModal()" style="background:none;border:none;cursor:pointer;color:var(--clr-tertiary)"><span class="material-symbols-outlined">close</span></button>
        </div>
        <div id="helpModalBody" style="padding:22px;font-size:var(--fs-body-md);color:var(--clr-text-variant);line-height:1.7"></div>
      </div>
    </div>

    <script>
    const HELP_CONTENT = {
      bidding: {
        title: 'How Bidding Works',
        body: `<p>Buyers can place bids on active auction listings. Bids must exceed the current highest bid plus the minimum increment set by the seller.</p>
               <p style="margin-top:12px">Once the auction timer hits zero, the highest bidder wins, an order is automatically generated, and the item moves to their "To Pay" tab so they can complete payment.</p>`
      },
      listing: {
        title: 'How to Create a Listing',
        body: `<p>Sellers navigate to the Seller Center and click "Create Listing." From there, input the item title, description, size, category, condition, and brand.</p>
               <p style="margin-top:12px">Choose either "Fixed Price" or "Auction" as the listing type, upload real photos of the item, and publish. Luxury items also go through an authenticity review before they go live.</p>`
      },
      payment: {
        title: 'Payment Guide',
        body: `<p>Payments are processed securely at checkout. The money is held safely until the buyer marks the item as received or tracking confirms delivery.</p>
               <p style="margin-top:12px">This protects both sides of the transaction: sellers know a sale is real once payment clears, and buyers know their money isn't released until the item actually arrives.</p>`
      },
      policies: {
        title: 'Policies, Penalties &amp; Reporting',
        body: `<p>Users can flag fraudulent items or suspicious behavior using the "Report Listing" feature on any listing page.</p>
               <p style="margin-top:12px">Upheld fraud reports result in immediate listing removal and a Selling Suspension penalty applied to the seller's account. Repeated offenses escalate to longer suspensions and, eventually, a permanent ban.</p>`
      },
      contact: {
        title: 'Contact Support',
        body: `<p>Reach the ThriftBid administrative team directly:</p>
               <div style="margin-top:14px;display:flex;flex-direction:column;gap:10px">
                 <div style="padding:10px 14px;background:var(--clr-surface-low);border-radius:var(--radius-sm)"><strong>Dhens Espina</strong><br><a href="mailto:dhens_espina@dlsu.edu.ph" style="color:var(--clr-coral)">dhens_espina@dlsu.edu.ph</a></div>
                 <div style="padding:10px 14px;background:var(--clr-surface-low);border-radius:var(--radius-sm)"><strong>Leila Lumbao</strong><br><a href="mailto:leila_lumbao@dlsu.edu.ph" style="color:var(--clr-coral)">leila_lumbao@dlsu.edu.ph</a></div>
                 <div style="padding:10px 14px;background:var(--clr-surface-low);border-radius:var(--radius-sm)"><strong>Kyrstie San Jose</strong><br><a href="mailto:krystie_sanjose@dlsu.edu.ph" style="color:var(--clr-coral)">krystie_sanjose@dlsu.edu.ph</a></div>
               </div>`
      },
    };
    function openHelpModal(key){
      const c = HELP_CONTENT[key];
      if (!c) return;
      document.getElementById('helpModalTitle').innerHTML = c.title;
      document.getElementById('helpModalBody').innerHTML = c.body;
      document.getElementById('helpModalOverlay').style.display = 'flex';
      document.getElementById('helpMenu').style.display = 'none';
    }
    function closeHelpModal(){ document.getElementById('helpModalOverlay').style.display = 'none'; }
    </script>

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
// popup toggle for notif, profile, help 

function togglePopup(id) {

  if (id === 'notifPopup') {
    const el = document.getElementById(id);
    const isOpen = el.classList.contains('open');
    document.querySelectorAll('.tb-notif-popup').forEach(p => p.classList.remove('open'));
    ['profileMenu','helpMenu'].forEach(m => { const el2 = document.getElementById(m); if(el2) el2.style.display = 'none'; });
    if (!isOpen) { el.classList.add('open'); loadNotifs(); }
  } else {
    const el = document.getElementById(id);
    if (!el) return;
    const isOpen = el.style.display === 'block';
    document.querySelectorAll('.tb-notif-popup').forEach(p => p.classList.remove('open'));
    ['profileMenu','helpMenu'].forEach(m => { const el2 = document.getElementById(m); if(el2) el2.style.display = 'none'; });
    el.style.display = isOpen ? 'none' : 'block';
  }
}
// Close all popups on outside click
document.addEventListener('click', e => {
  const inside = ['notifWrap','profileWrap','helpWrap'];
  if (!inside.some(id => e.target.closest('#'+id))) {
    document.querySelectorAll('.tb-notif-popup').forEach(p => p.classList.remove('open'));
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
        'auctions'     => ['icon'=>'gavel',         'label'=>'My Listings & Auctions', 'href'=>'../../pages/seller/active-auctions.php'],
        'ship'         => ['icon'=>'local_shipping','label'=>'Orders',         'href'=>'../../pages/seller/to-ship.php'],
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

    $groups = [
        '' => [
            'dashboard' => ['icon'=>'dashboard', 'label'=>'Dashboard', 'href'=>'../../pages/admin/dashboard.php'],
        ],
        'Catalog' => [
            'listings'     => ['icon'=>'storefront', 'label'=>'Listings',     'href'=>'../../pages/admin/listings.php'],
            'auctions'     => ['icon'=>'gavel',       'label'=>'Auctions',    'href'=>'../../pages/admin/auctions.php'],
            'authenticity' => ['icon'=>'verified',    'label'=>'Authenticity','href'=>'../../pages/admin/authenticity.php'],
        ],
        'People' => [
            'users' => ['icon'=>'group', 'label'=>'User Management', 'href'=>'../../pages/admin/users.php'],
        ],
        'Trust & Safety' => [
            'moderation' => ['icon'=>'shield', 'label'=>'Moderation',        'href'=>'../../pages/admin/moderation.php'],
            'penalties'  => ['icon'=>'balance','label'=>'Rewards & Penalties','href'=>'../../pages/admin/penalties.php'],
        ],
        'Insights' => [
            'reports' => ['icon'=>'query_stats', 'label'=>'Platform Analytics', 'href'=>'../../pages/admin/reports.php'],
        ],
        'Account' => [
            'settings' => ['icon'=>'settings', 'label'=>'Settings', 'href'=>'../../pages/profile.php'],
        ],
    ]; ?>
<aside class="tb-sidebar" style="width:224px;min-width:224px">
  <div class="tb-sidebar-title" style="font-size:16px">Admin Panel</div>
  <nav class="tb-sidebar-nav" style="margin-top:12px">
    <?php foreach ($groups as $groupLabel => $links): ?>
    <?php if ($groupLabel): ?>
    <div style="font-size:10px;font-weight:700;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.08em;margin:16px 0 4px 12px"><?= $groupLabel ?></div>
    <?php endif; ?>
    <?php foreach ($links as $k => $l): ?>
    <a href="<?= $l['href'] ?>" class="tb-sidebar-link <?= $active===$k?'active':'' ?>">
      <span class="material-symbols-outlined"><?= $l['icon'] ?></span><?= $l['label'] ?>
    </a>
    <?php endforeach; ?>
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
        <p style="margin-top:10px;font-size:var(--fs-label-sm);color:var(--clr-tertiary);line-height:1.6">Curated second-hand pieces from trusted sellers.<br>Engineered by Team Dynamite.</p>
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
      <p style="font-size:11px;color:var(--clr-tertiary)">&copy; 2026 ThriftBid. Designed &amp; Engineered by BSITS DLSU Laguna Campus (ID 124), Dhens Espina, Leila Lumbao, Kyrstie San Jose. All Rights Reserved.</p>
    </div>
  </div>
</footer>
<?php }

//  Helpers
function groupByDate(array $rows, string $dateField, string $format = 'F j, Y'): array {
    $groups = [];
    foreach ($rows as $row) {
        $key = date($format, strtotime($row[$dateField]));
        $groups[$key][] = $row;
    }
    return $groups;
}

// Optional $subtotal displays a total next to the date ("Revenue: ₱12,450.00").
function renderDateHeader(string $label, ?string $subtotal = null): void {
    echo '<div style="display:flex;align-items:baseline;justify-content:space-between;margin:18px 0 10px;padding-bottom:6px;border-bottom:1px solid var(--clr-outline)">'
       . '<h3 style="font-size:var(--fs-label-sm);font-weight:800;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em">'
       . htmlspecialchars($label) . '</h3>';
    if ($subtotal !== null) {
        echo '<span style="font-size:var(--fs-label-md);font-weight:700;color:var(--clr-success)">' . $subtotal . '</span>';
    }
    echo '</div>';
}

function flash(string $key, string $msg = ''): string {
    if ($msg) { $_SESSION['flash'][$key] = $msg; return ''; }
    $m = $_SESSION['flash'][$key] ?? ''; unset($_SESSION['flash'][$key]); return $m;
}

// Handled by includes/currency.php via live exchange rates.
// Calling pages already import it, removing duplication here.
function formatTimeLeft(string $end): string {
    $d = strtotime($end) - time();
    if ($d <= 0) return 'Ended';
    if ($d >= 86400) return floor($d/86400).'d '.floor(($d%86400)/3600).'h';
    $h=floor($d/3600); $m=floor(($d%3600)/60); $s=$d%60;
    return str_pad($h,2,'0',STR_PAD_LEFT).':'.str_pad($m,2,'0',STR_PAD_LEFT).':'.str_pad($s,2,'0',STR_PAD_LEFT);
}