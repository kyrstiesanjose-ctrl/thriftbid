<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$id = (int)($_GET['id'] ?? 0);
if (!$id) { header('Location: categories.php'); exit; }

$user = currentUser();
$buyerIdForAccess = $user['buyer_id'] ?? 0;
$isPrivilegedViewer = in_array($user['role'] ?? '', ['admin','seller'], true)
    || ($buyerIdForAccess && DB::fetch('SELECT order_id FROM ORDERS WHERE listing_id=? AND buyer_id=? LIMIT 1', [$id, $buyerIdForAccess]));

$listing = DB::fetch(
    "SELECT l.*, c.name AS cat_name, sz.size_value, b.brand_name, pl.tier,
            COALESCE(se.shop_name, se.username) AS seller_name, se.seller_id, se.ig_follower_count,
            (SELECT AVG(rating) FROM REVIEWS WHERE seller_id=se.seller_id AND deleted_at IS NULL) AS avg_rating,
            (SELECT COUNT(*) FROM REVIEWS WHERE seller_id=se.seller_id AND deleted_at IS NULL) AS review_count
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN CATEGORY_SIZES sz ON l.size_id=sz.size_id
     JOIN PRODUCT_LINES pl ON l.product_line_id=pl.product_line_id
     JOIN BRANDS b ON pl.brand_id=b.brand_id
     JOIN SELLER se ON l.seller_id=se.seller_id
     WHERE l.listing_id=?" . ($isPrivilegedViewer ? '' : ' AND l.is_active=1') . " AND l.deleted_at IS NULL",
    [$id]
);
if (!$listing) { header('Location: categories.php'); exit; }
$isSold = !$listing['is_active'];
$isOwnListing = ($user['role']==='seller' && (int)($user['seller_id'] ?? 0) === (int)$listing['seller_id']);

$images = DB::fetchAll('SELECT * FROM LISTING_IMAGES WHERE listing_id=? ORDER BY is_primary DESC, image_id ASC', [$id]);

// Redirect if this listing is actually an active auction, not a buy-now item
$auction = DB::fetch('SELECT auction_id FROM AUCTIONS WHERE listing_id=? AND status="Active"', [$id]);
if ($auction) { header('Location: auction_room.php?id='.$auction['auction_id']); exit; }

$buyerId = $buyerIdForAccess; // session row IS the buyer row now

$inCart = $buyerId ? DB::fetch('SELECT cart_item_id FROM CART_ITEMS WHERE buyer_id=? AND listing_id=?', [$buyerId, $id]) : null;

$related = DB::fetchAll(
    "SELECT l.listing_id, l.title, l.price, l.condition_grade,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
     FROM LISTINGS l
     WHERE l.category_id=? AND l.listing_id!=? AND l.is_active=1 AND l.deleted_at IS NULL
       AND l.listing_id NOT IN (SELECT listing_id FROM AUCTIONS WHERE status='Active')
     LIMIT 4",
    [$listing['category_id'], $id]
);

$errorMsg = '';
$successMsg = isset($_GET['added']) ? 'Item added to your cart.' : (isset($_GET['reported']) ? 'Thanks, our team will review this listing.' : '');

// ------------------------------------------------------------
// Buy Now: Creates order. The database trigger handles listing
// deactivation and seller alerts. This script only sends the 
// buyer-facing confirmation.
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['buy_now'])) {
    if (!$buyerId) {
        $errorMsg = 'Only registered buyers can purchase items.';
    } else {
        $orderId = DB::insert('INSERT INTO ORDERS (listing_id,buyer_id,seller_id) VALUES (?,?,?)', [$id, $buyerId, $listing['seller_id']]);

        DB::query('INSERT INTO NOTIFICATIONS (buyer_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$buyerId, 'Order Placed!', 'Your order for "'.$listing['title'].'" has been placed. Proceed to checkout.', 'ORDER']);

        header('Location: ../customer/checkout.php?order='.$orderId); exit;
    }
}

// Add to Cart (CART_ITEMS is a temporary table per the schema, plain insert, no trigger involved)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_to_cart'])) {
    if (!$buyerId) {
        $errorMsg = 'Only registered buyers can use the cart.';
    } elseif (!$inCart) {
        DB::query('INSERT INTO CART_ITEMS (buyer_id,listing_id) VALUES (?,?)', [$buyerId, $id]);
        header('Location: listing.php?id='.$id.'&added=1'); exit;
    }
}

// Report this listing -> FRAUD_FLAGS, reviewed by admin on reported-listings.php
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['report_listing'])) {
    $reportReason = trim($_POST['report_reason'] ?? '');
    if (!$buyerId) {
        $errorMsg = 'Please log in as a buyer to report a listing.';
    } elseif (!$reportReason) {
        $errorMsg = 'Please describe the issue before submitting a report.';
    } else {
        DB::query('INSERT INTO FRAUD_FLAGS (listing_id, buyer_id, seller_id, signals_detected) VALUES (?,?,?,?)',
            [$id, $buyerId, $listing['seller_id'], $reportReason]);
        header('Location: listing.php?id='.$id.'&reported=1'); exit;
    }
}

renderHead($listing['title']);
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('categories'); ?>

<main style="flex:1">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px">

    <nav style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:20px;display:flex;align-items:center;gap:6px">
      <?php if ($isPrivilegedViewer): ?>
      <a href="<?= $user['role']==='admin' ? '../admin/dashboard.php' : '../seller/dashboard.php' ?>" style="color:var(--clr-tertiary)"><?= $user['role']==='admin' ? 'Admin' : 'Seller Center' ?></a>
      <span class="material-symbols-outlined icon-sm">chevron_right</span>
      <a href="<?= $user['role']==='admin' ? '../admin/listings.php' : '../seller/active-auctions.php?tab=fixed' ?>" style="color:var(--clr-tertiary)"><?= $user['role']==='admin' ? 'Listings' : 'My Listings' ?></a>
      <?php else: ?>
      <a href="home.php" style="color:var(--clr-tertiary)">Home</a>
      <span class="material-symbols-outlined icon-sm">chevron_right</span>
      <a href="categories.php?cat=<?= $listing['category_id'] ?>" style="color:var(--clr-tertiary)"><?= htmlspecialchars($listing['cat_name']) ?></a>
      <?php endif; ?>
      <span class="material-symbols-outlined icon-sm">chevron_right</span>
      <span class="line-clamp-1" style="color:var(--clr-text)"><?= htmlspecialchars($listing['title']) ?></span>
    </nav>

    <?php if ($successMsg): ?>
    <div class="tb-alert tb-alert-success show" style="margin-bottom:20px"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div>
    <?php endif; ?>
    <?php if ($errorMsg): ?>
    <div class="tb-alert tb-alert-error show" style="margin-bottom:20px"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div>
    <?php endif; ?>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-10">

      <!-- Images -->
      <div>
        <div style="background:var(--clr-surface-mid);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);aspect-ratio:4/5;display:flex;align-items:center;justify-content:center;overflow:hidden;position:relative">
          <?php if (!empty($images)): ?>
          <img src="<?= htmlspecialchars($images[0]['image_url']) ?>" alt="<?= htmlspecialchars($listing['title']) ?>" style="width:100%;height:100%;object-fit:cover;<?= $isSold ? 'filter:grayscale(40%);opacity:0.75' : '' ?>" id="mainPhoto">
          <?php else: ?>
          <span class="material-symbols-outlined" style="font-size:80px;color:var(--clr-outline)">checkroom</span>
          <?php endif; ?>
          <?php if ($isSold): ?>
          <div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;pointer-events:none">
            <span style="background:#1a1a1a;color:#fff;font-size:20px;font-weight:800;letter-spacing:0.12em;padding:10px 32px;border-radius:6px;transform:rotate(-8deg);box-shadow:0 4px 16px rgba(0,0,0,0.3)">SOLD</span>
          </div>
          <?php endif; ?>
          <?php if ($listing['tier'] === 'High'): ?>
          <span class="tb-badge-float top-right" style="background:#1a1a1a;color:#fff">Luxury &bull; Authenticated</span>
          <?php endif; ?>
        </div>
        <?php if (count($images) > 1): ?>
        <div style="display:flex;gap:8px;margin-top:8px;overflow-x:auto">
          <?php foreach ($images as $img): ?>
          <img src="<?= htmlspecialchars($img['image_url']) ?>" onclick="document.getElementById('mainPhoto').src=this.src" style="width:60px;height:60px;object-fit:cover;border-radius:8px;cursor:pointer;border:1px solid var(--clr-outline)">
          <?php endforeach; ?>
        </div>
        <?php endif; ?>
      </div>

      <!-- Details -->
      <div style="display:flex;flex-direction:column;gap:18px">

        <div>
          <span class="tb-badge tb-badge-gray"><?= htmlspecialchars($listing['cat_name']) ?></span>
          <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:800;color:var(--clr-text);margin-top:10px;line-height:1.15"><?= htmlspecialchars($listing['title']) ?></h1>
          <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-top:6px">
            <?= htmlspecialchars($listing['brand_name']) ?> &bull; Sold by
            <a href="seller_profile.php?id=<?= $listing['seller_id'] ?>" style="color:var(--clr-coral);font-weight:700"><?= htmlspecialchars($listing['seller_name']) ?></a>
          </p>
          <?php if ($listing['avg_rating']): ?>
          <div style="display:flex;align-items:center;gap:4px;margin-top:8px">
            <?php for ($i=1;$i<=5;$i++): ?>
            <span class="material-symbols-outlined icon-sm" style="color:#ffc107;font-variation-settings:'FILL' <?= $i<=(int)round($listing['avg_rating'])?1:0 ?>,'wght' 400,'GRAD' 0,'opsz' 24">star</span>
            <?php endfor; ?>
            <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-left:4px"><?= number_format($listing['avg_rating'],1) ?> (<?= $listing['review_count'] ?> reviews)</span>
          </div>
          <?php endif; ?>
        </div>

        <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:18px 20px">
          <div style="display:flex;align-items:flex-end;justify-content:space-between;flex-wrap:wrap;gap:12px">
            <div>
              <p class="tb-section-label">Price</p>
              <div style="display:flex;align-items:baseline;gap:10px;flex-wrap:wrap">
                <p style="font-family:'Hanken Grotesk',sans-serif;font-size:38px;font-weight:800;color:var(--clr-text);line-height:1"><?= convertCurrency((float)$listing['price']) ?></p>
                <?php if (!empty($listing['original_price']) && $listing['original_price'] > $listing['price']): ?>
                <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);text-decoration:line-through"><?= convertCurrency((float)$listing['original_price']) ?></p>
                <?php
                  $offPct = round((1 - ($listing['price'] / $listing['original_price'])) * 100);
                ?>
                <span class="tb-badge tb-badge-green"><?= $offPct ?>% off retail</span>
                <?php endif; ?>
              </div>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:4px">Fixed Price &bull; Free Platform Fee</p>
            </div>
            <div>
              <p class="tb-section-label">View in currency</p>
              <div style="display:flex;gap:6px">
                <?php foreach (['PHP','USD','KRW'] as $cur): ?>
                <button type="button" onclick="showCur('<?=$cur?>')" class="btn btn-ghost btn-sm"><?=$cur?></button>
                <?php endforeach; ?>
              </div>
              <p id="converted" style="font-size:var(--fs-label-md);color:var(--clr-coral);font-weight:700;margin-top:6px;min-height:20px"></p>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-3 gap-3">
          <?php $meta = [['label'=>'Condition','val'=>$listing['condition_grade']],['label'=>'Category','val'=>$listing['cat_name']],['label'=>'Size','val'=>$listing['size_value']]]; ?>
          <?php foreach ($meta as $m): ?>
          <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:10px 12px">
            <p class="tb-section-label" style="font-size:10px;margin-bottom:2px"><?= $m['label'] ?></p>
            <p style="font-weight:700;font-size:var(--fs-label-md);color:var(--clr-text)"><?= htmlspecialchars($m['val']) ?></p>
          </div>
          <?php endforeach; ?>
        </div>

        <?php if ($listing['description']): ?>
        <div>
          <p class="tb-section-label">Description</p>
          <p style="font-size:var(--fs-body-md);color:var(--clr-text-variant);line-height:1.7"><?= nl2br(htmlspecialchars($listing['description'])) ?></p>
        </div>
        <?php endif; ?>

        <?php if ($isSold): ?>
        <div style="background:var(--clr-surface-low);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:16px;text-align:center;color:var(--clr-tertiary);font-weight:600">
          <span class="material-symbols-outlined icon-sm" style="vertical-align:middle;margin-right:6px">block</span>This item has already been sold.
        </div>
        <?php elseif ($isPrivilegedViewer): ?>
        <div style="background:var(--clr-info-bg);border:1px solid #b8d4e8;border-radius:var(--radius-sm);padding:16px;text-align:center;color:var(--clr-info);font-weight:600">
          <span class="material-symbols-outlined icon-sm" style="vertical-align:middle;margin-right:6px">visibility</span>
          <?= $isOwnListing
              ? 'This is your listing. You are viewing it exactly as buyers see it.'
              : 'Viewing as ' . ucfirst($user['role']) . '. Purchase actions are not available in this view.' ?>
        </div>
        <?php else: ?>
        <div style="display:flex;gap:10px">
          <form method="POST" style="flex:1">
            <input type="hidden" name="add_to_cart" value="1">
            <button type="submit" class="btn btn-outline btn-full btn-lg" <?= $inCart?'style="opacity:.6"':'' ?>>
              <span class="material-symbols-outlined icon-sm">shopping_cart</span>
              <?= $inCart ? 'In Cart' : 'Add to Cart' ?>
            </button>
          </form>
          <form method="POST" style="flex:1">
            <input type="hidden" name="buy_now" value="1">
            <button type="submit" class="btn btn-primary btn-full btn-lg">
              <span class="material-symbols-outlined icon-sm">bolt</span>Buy Now
            </button>
          </form>
        </div>
        <?php endif; ?>

        <div style="display:flex;flex-wrap:wrap;gap:14px;font-size:var(--fs-label-sm);color:var(--clr-tertiary);padding-top:4px;align-items:center">
          <span style="display:flex;align-items:center;gap:4px"><span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)">verified</span>Authenticated Thrift</span>
          <span style="display:flex;align-items:center;gap:4px"><span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)">lock</span>Secure Escrow</span>
          <span style="display:flex;align-items:center;gap:4px"><span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)">local_shipping</span>Ships within 48h</span>
          <button type="button" onclick="document.getElementById('reportBox').classList.toggle('hidden')" style="margin-left:auto;background:none;border:none;color:var(--clr-tertiary);font-size:var(--fs-label-sm);text-decoration:underline;cursor:pointer">
            <span class="material-symbols-outlined icon-sm" style="vertical-align:middle">flag</span>Report this listing
          </button>
        </div>

        <div id="reportBox" class="hidden" style="background:var(--clr-surface-low);border-radius:var(--radius-sm);padding:14px">
          <form method="POST" style="display:flex;flex-direction:column;gap:8px">
            <label class="tb-label">Why are you reporting this listing?</label>
            <textarea name="report_reason" class="tb-input" rows="3" placeholder="e.g. Suspected counterfeit, misleading photos, prohibited item..." required></textarea>
            <button type="submit" name="report_listing" value="1" class="btn btn-ghost btn-sm" style="align-self:flex-start" onclick="return confirm('Submit this report for admin review?')">Submit Report</button>
          </form>
        </div>

      </div>
    </div>

    <?php if (!empty($related)): ?>
    <div style="margin-top:52px">
      <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:700;margin-bottom:18px">More from <?= htmlspecialchars($listing['cat_name']) ?></h2>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <?php foreach ($related as $r): ?>
        <a href="listing.php?id=<?= $r['listing_id'] ?>" class="tb-listing-card" style="text-decoration:none">
          <div class="tb-listing-thumb">
            <?php if ($r['cover_image']): ?><img src="<?= htmlspecialchars($r['cover_image']) ?>" alt=""><?php else: ?><span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span><?php endif; ?>
          </div>
          <div class="tb-listing-body">
            <div class="tb-listing-title"><?= htmlspecialchars($r['title']) ?></div>
            <div class="tb-listing-price"><?= convertCurrency((float)$r['price']) ?></div>
            <div class="tb-listing-meta"><?= htmlspecialchars($r['condition_grade']) ?></div>
          </div>
        </a>
        <?php endforeach; ?>
      </div>
    </div>
    <?php endif; ?>

  </div>
</main>
<?php renderFooter(); ?>
<script>
const LIVE_RATES = <?= json_encode(getLiveCurrencyRates()) ?>;
const SYMS = {PHP:'₱',USD:'$',KRW:'₩'};
const PRICE = <?= (float)$listing['price'] ?>;
function showCur(c){
  const r = PRICE * (LIVE_RATES[c] || 1);
  document.getElementById('converted').textContent = SYMS[c] + (c==='KRW' ? Math.round(r).toLocaleString() : r.toFixed(2)) + ' ' + c;
}
</script>
</body></html>