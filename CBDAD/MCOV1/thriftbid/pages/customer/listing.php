<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$id = (int)($_GET['id'] ?? 0);
if (!$id) { header('Location: categories.php'); exit; }

$listing = DB::fetch(
    'SELECT l.*, c.name as cat_name, u.username as seller_name, u.user_id as seller_user_id,
            s.seller_id, s.store_loc,
            (SELECT AVG(rating) FROM REVIEWS WHERE seller_id=s.seller_id) as avg_rating,
            (SELECT COUNT(*) FROM REVIEWS WHERE seller_id=s.seller_id) as review_count
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s ON l.seller_id=s.seller_id
     JOIN USERS u ON s.user_id=u.user_id
     WHERE l.listing_id=? AND l.is_active=1',
    [$id]
);
if (!$listing) { header('Location: categories.php'); exit; }

// Redirect if active auction exists
$auction = DB::fetch('SELECT auction_id FROM AUCTIONS WHERE listing_id=? AND status="Active"', [$id]);
if ($auction) { header('Location: auction_room.php?id='.$auction['auction_id']); exit; }

$user    = currentUser();
$buyer   = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$user['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;
$uid     = $user['user_id'];

// Cart status
$inCart = DB::fetch('SELECT cart_item_id FROM CART_ITEMS WHERE user_id=? AND listing_id=?', [$uid, $id]);

// Related items
$related = DB::fetchAll(
    'SELECT l.listing_id, l.title, l.price, l.image_url, l.item_condition
     FROM LISTINGS l
     WHERE l.category_id=? AND l.listing_id!=? AND l.is_active=1
     AND l.listing_id NOT IN (SELECT listing_id FROM AUCTIONS WHERE status="Active")
     LIMIT 4',
    [$listing['category_id'], $id]
);

$errorMsg = '';

// Buy Now, create order immediately
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['buy_now'])) {
    if (!$buyerId) { $errorMsg = 'Only registered buyers can purchase items.'; }
    else {
        $orderId = DB::insert('INSERT INTO ORDERS (listing_id,buyer_id,seller_id) VALUES (?,?,?)', [$id, $buyerId, $listing['seller_id']]);
        DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$listing['seller_user_id'], 'New Order Received!', 'Someone purchased "'.$listing['title'].'".', 'ORDER']);
        DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$uid, 'Order Placed!', 'Your order for "'.$listing['title'].'" has been placed. Proceed to checkout.', 'ORDER']);
        header('Location: ../customer/checkout.php?order='.$orderId); exit;
    }
}

// Add to Cart
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add_to_cart'])) {
    if (!$inCart) {
        DB::query('INSERT INTO CART_ITEMS (user_id,listing_id) VALUES (?,?)', [$uid, $id]);
        $inCart = true;
    }
    header('Location: listing.php?id='.$id.'&added=1'); exit;
}

$added = isset($_GET['added']);
renderHead($listing['title']);
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('categories'); ?>

<main style="flex:1">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px">

    <!-- Breadcrumb -->
    <nav style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:20px;display:flex;align-items:center;gap:6px">
      <a href="home.php" style="color:var(--clr-tertiary)">Home</a>
      <span class="material-symbols-outlined icon-sm">chevron_right</span>
      <a href="categories.php?cat=<?= $listing['category_id'] ?>" style="color:var(--clr-tertiary)"><?= htmlspecialchars($listing['cat_name']) ?></a>
      <span class="material-symbols-outlined icon-sm">chevron_right</span>
      <span class="line-clamp-1" style="color:var(--clr-text)"><?= htmlspecialchars($listing['title']) ?></span>
    </nav>

    <?php if ($added): ?>
    <div class="tb-alert tb-alert-success show" style="margin-bottom:20px">
      <span class="material-symbols-outlined icon-sm">check_circle</span>
      Item added to your cart. <a href="../customer/orders.php" style="color:var(--clr-success);font-weight:700;text-decoration:underline">View Cart</a>
    </div>
    <?php endif; ?>
    <?php if ($errorMsg): ?>
    <div class="tb-alert tb-alert-error show" style="margin-bottom:20px">
      <span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?>
    </div>
    <?php endif; ?>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-10">

      <!-- Image -->
      <div>
        <div style="background:var(--clr-surface-mid);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);aspect-ratio:4/5;display:flex;align-items:center;justify-content:center;overflow:hidden">
          <?php if ($listing['image_url']): ?>
          <img src="<?= htmlspecialchars($listing['image_url']) ?>" alt="<?= htmlspecialchars($listing['title']) ?>" style="width:100%;height:100%;object-fit:cover">
          <?php else: ?>
          <span class="material-symbols-outlined" style="font-size:80px;color:var(--clr-outline)">checkroom</span>
          <?php endif; ?>
        </div>
      </div>

      <!-- Details -->
      <div style="display:flex;flex-direction:column;gap:18px">

        <!-- Title & seller -->
        <div>
          <span class="tb-badge tb-badge-gray"><?= htmlspecialchars($listing['cat_name']) ?></span>
          <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:800;color:var(--clr-text);margin-top:10px;line-height:1.15"><?= htmlspecialchars($listing['title']) ?></h1>
          <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-top:6px">
            Sold by
            <!-- Seller name → seller_profile.php -->
            <a href="seller_profile.php?id=<?= $listing['seller_id'] ?>" style="color:var(--clr-coral);font-weight:700">@<?= htmlspecialchars($listing['seller_name']) ?></a>
            <?php if ($listing['store_loc']): ?>&bull; <?= htmlspecialchars($listing['store_loc']) ?><?php endif; ?>
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

        <!-- Price block -->
        <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:18px 20px">
          <div style="display:flex;align-items:flex-end;justify-content:space-between;flex-wrap:wrap;gap:12px">
            <div>
              <p class="tb-section-label">Price</p>
              <p style="font-family:'Hanken Grotesk',sans-serif;font-size:38px;font-weight:800;color:var(--clr-text);line-height:1"><?= convertCurrency((float)$listing['price']) ?></p>
              <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:4px">Fixed Price &bull; Free Platform Fee</p>
            </div>
            <div>
              <p class="tb-section-label">View in currency</p>
              <div style="display:flex;gap:6px">
                <?php foreach (['PHP','USD','KRW'] as $cur): ?>
                <button onclick="showCur('<?=$cur?>',<?=(float)$listing['price']?>)" class="btn btn-ghost btn-sm"><?=$cur?></button>
                <?php endforeach; ?>
              </div>
              <p id="converted" style="font-size:var(--fs-label-md);color:var(--clr-coral);font-weight:700;margin-top:6px;min-height:20px"></p>
            </div>
          </div>
        </div>

        <!-- Condition + details grid -->
        <div class="grid grid-cols-3 gap-3">
          <?php $meta = [['label'=>'Condition','val'=>$listing['item_condition']],['label'=>'Category','val'=>$listing['cat_name']],['label'=>'Size','val'=>$listing['size']??'N/A']]; ?>
          <?php foreach ($meta as $m): ?>
          <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:10px 12px">
            <p class="tb-section-label" style="font-size:10px;margin-bottom:2px"><?= $m['label'] ?></p>
            <p style="font-weight:700;font-size:var(--fs-label-md);color:var(--clr-text)"><?= htmlspecialchars($m['val']) ?></p>
          </div>
          <?php endforeach; ?>
        </div>

        <!-- Description -->
        <?php if ($listing['description']): ?>
        <div>
          <p class="tb-section-label">Description</p>
          <p style="font-size:var(--fs-body-md);color:var(--clr-text-variant);line-height:1.7"><?= nl2br(htmlspecialchars($listing['description'])) ?></p>
        </div>
        <?php endif; ?>

        <!-- CTA: Add to Cart (left) + Buy Now (right)  -->
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

        <!-- Trust badges -->
        <div style="display:flex;flex-wrap:wrap;gap:14px;font-size:var(--fs-label-sm);color:var(--clr-tertiary);padding-top:4px">
          <span style="display:flex;align-items:center;gap:4px"><span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)">verified</span>Authenticated Thrift</span>
          <span style="display:flex;align-items:center;gap:4px"><span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)">lock</span>Secure Escrow</span>
          <span style="display:flex;align-items:center;gap:4px"><span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)">local_shipping</span>Ships within 48h</span>
        </div>

      </div><!-- /details -->
    </div><!-- /grid -->

    <!-- Related -->
    <?php if (!empty($related)): ?>
    <div style="margin-top:52px">
      <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:700;margin-bottom:18px">More from <?= htmlspecialchars($listing['cat_name']) ?></h2>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <?php foreach ($related as $r): ?>
        <a href="listing.php?id=<?= $r['listing_id'] ?>" class="tb-listing-card" style="text-decoration:none">
          <div class="tb-listing-thumb">
            <?php if ($r['image_url']): ?><img src="<?= htmlspecialchars($r['image_url']) ?>" alt=""><?php else: ?><span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span><?php endif; ?>
          </div>
          <div class="tb-listing-body">
            <div class="tb-listing-title"><?= htmlspecialchars($r['title']) ?></div>
            <div class="tb-listing-price"><?= convertCurrency((float)$r['price']) ?></div>
            <div class="tb-listing-meta"><?= htmlspecialchars($r['item_condition']) ?></div>
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
const rates={PHP:1,USD:0.0175,KRW:23.5},syms={PHP:'₱',USD:'$',KRW:'₩'};
function showCur(c,v){const r=v*rates[c];document.getElementById('converted').textContent=syms[c]+(c==='KRW'?Math.round(r).toLocaleString():r.toFixed(2))+' '+c;}
</script>
</body></html>
