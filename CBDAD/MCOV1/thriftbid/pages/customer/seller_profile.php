<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$sellerId = (int)($_GET['id'] ?? 0);
if (!$sellerId) { header('Location: categories.php'); exit; }

$seller = DB::fetch(
    'SELECT s.*,u.username,u.email,u.created_at as joined,
            (SELECT COUNT(*) FROM LISTINGS WHERE seller_id=s.seller_id AND is_active=1) as listing_count,
            (SELECT AVG(rating) FROM REVIEWS WHERE seller_id=s.seller_id) as avg_rating,
            (SELECT COUNT(*) FROM REVIEWS WHERE seller_id=s.seller_id) as review_count,
            (SELECT COUNT(*) FROM ORDERS WHERE seller_id=s.seller_id AND status="Delivered") as completed_orders
     FROM SELLER s
     JOIN USERS u ON s.user_id=u.user_id
     WHERE s.seller_id=?',
    [$sellerId]
);
if (!$seller) { header('Location: categories.php'); exit; }

// Seller listings
$listings = DB::fetchAll(
    'SELECT l.*,c.name as cat_name,
            a.auction_id, a.end_time, a.current_highest_bid, a.status as auction_status
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     LEFT JOIN AUCTIONS a ON l.listing_id=a.listing_id AND a.status="Active"
     WHERE l.seller_id=? AND l.is_active=1
     ORDER BY l.created_at DESC LIMIT 24',
    [$sellerId]
);

// Reviews
$reviews = DB::fetchAll(
    'SELECT r.*,u.username as buyer_name,l.title as item_title
     FROM REVIEWS r
     JOIN BUYER by2 ON r.buyer_id=by2.buyer_id
     JOIN USERS u ON by2.user_id=u.user_id
     JOIN ORDERS o ON r.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     WHERE r.seller_id=?
     ORDER BY r.review_date DESC LIMIT 20',
    [$sellerId]
);

$currentUser = currentUser();
$buyer = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$currentUser['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;

// Can leave review check
$canReview = false;
if ($buyerId) {
    $completedOrder = DB::fetch(
        'SELECT o.order_id FROM ORDERS o
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         WHERE o.buyer_id=? AND l.seller_id=? AND o.status="Delivered"
         AND o.order_id NOT IN (SELECT order_id FROM REVIEWS WHERE buyer_id=?)
         LIMIT 1',
        [$buyerId, $sellerId, $buyerId]
    );
    $canReview = (bool)$completedOrder;
    $reviewOrderId = $completedOrder['order_id'] ?? 0;
}

$reviewSuccess = $reviewError = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit_review']) && $canReview) {
    $rating = (int)($_POST['rating'] ?? 0);
    $text   = trim($_POST['review_text'] ?? '');
    if ($rating < 1 || $rating > 5) { $reviewError = 'Please select a rating between 1 and 5.'; }
    else {
        DB::query('INSERT INTO REVIEWS (buyer_id,seller_id,order_id,rating,review_text) VALUES (?,?,?,?,?)',
            [$buyerId, $sellerId, $reviewOrderId, $rating, $text ?: null]);
        $canReview    = false;
        $reviewSuccess = 'Your review has been submitted!';
        $reviews = DB::fetchAll('SELECT r.*,u.username as buyer_name,l.title as item_title FROM REVIEWS r JOIN BUYER by2 ON r.buyer_id=by2.buyer_id JOIN USERS u ON by2.user_id=u.user_id JOIN ORDERS o ON r.order_id=o.order_id JOIN LISTINGS l ON o.listing_id=l.listing_id WHERE r.seller_id=? ORDER BY r.review_date DESC LIMIT 20', [$sellerId]);
    }
}

renderHead('@' . $seller['username'] . ' — Seller Profile');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('categories'); ?>

<main style="flex:1;max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px;width:100%">

  <!-- Seller header card  -->
  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:28px 32px;margin-bottom:28px;display:flex;align-items:center;gap:24px;flex-wrap:wrap">
    <!-- Avatar -->
    <div style="width:88px;height:88px;border-radius:50%;background:var(--clr-surface-mid);display:flex;align-items:center;justify-content:center;flex-shrink:0;border:2px solid var(--clr-outline)">
      <span class="material-symbols-outlined filled" style="font-size:52px;color:var(--clr-outline)">account_circle</span>
    </div>
    <!-- Info -->
    <div style="flex:1;min-width:220px">
      <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px">
        <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text)">@<?= htmlspecialchars($seller['username']) ?></h1>
        <span class="tb-badge tb-badge-active">Verified Seller</span>
      </div>
      <?php if ($seller['store_loc']): ?>
      <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:8px">
        <span class="material-symbols-outlined icon-sm" style="color:var(--clr-coral)">location_on</span>
        <?= htmlspecialchars($seller['store_loc']) ?>
      </p>
      <?php endif; ?>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Member since <?= date('M Y', strtotime($seller['joined'])) ?></p>
    </div>
    <!-- Stats strip -->
    <div style="display:flex;gap:28px;flex-wrap:wrap">
      <?php $stats = [
        ['val'=>$seller['listing_count'],'label'=>'Listings'],
        ['val'=>$seller['completed_orders'],'label'=>'Completed Orders'],
        ['val'=>$seller['avg_rating'] ? number_format($seller['avg_rating'],1).'/5' : 'N/A','label'=>'Avg Rating'],
        ['val'=>$seller['review_count'],'label'=>'Reviews'],
        ['val'=>$seller['offense_count'],'label'=>'Offense Count'],
      ]; foreach ($stats as $st): ?>
      <div style="text-align:center">
        <p style="font-family:'Hanken Grotesk',sans-serif;font-size:22px;font-weight:800;color:var(--clr-text)"><?= $st['val'] ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $st['label'] ?></p>
      </div>
      <?php endforeach; ?>
    </div>
  </div>

  <!-- Tabs: Listings | Reviews -->
  <div class="tb-tabs" style="margin-bottom:24px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm)">
    <a href="#listings" class="tb-tab-link active" id="tab-listings" onclick="switchTab('listings')">Listings (<?= count($listings) ?>)</a>
    <a href="#reviews"  class="tb-tab-link"         id="tab-reviews"  onclick="switchTab('reviews')">Reviews (<?= count($reviews) ?>)</a>
  </div>

  <!-- LISTINGS tab -->
  <div id="section-listings">
    <?php if (empty($listings)): ?>
    <div style="text-align:center;padding:48px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
      <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline)">storefront</span>
      <p style="margin-top:10px;font-weight:600">This seller has no active listings.</p>
    </div>
    <?php else: ?>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <?php foreach ($listings as $l): ?>
      <div class="tb-listing-card">
        <div class="tb-listing-thumb">
          <?php if ($l['image_url']): ?><img src="<?= htmlspecialchars($l['image_url']) ?>" alt=""><?php else: ?><span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span><?php endif; ?>
          <?php if ($l['auction_id']): ?><span class="tb-badge-float top-left" style="background:var(--badge-live-bg);color:var(--badge-live-text)">Live</span><?php endif; ?>
        </div>
        <div class="tb-listing-body">
          <div class="tb-listing-title"><?= htmlspecialchars($l['title']) ?></div>
          <?php if ($l['auction_id']): ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['current_highest_bid']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= formatTimeLeft($l['end_time']) ?></div>
          <?php else: ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['price']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= htmlspecialchars($l['item_condition']) ?></div>
          <?php endif; ?>
          <div class="tb-listing-cta">
            <?php if ($l['auction_id']): ?>
            <a href="auction_room.php?id=<?= $l['auction_id'] ?>" class="btn btn-yellow btn-sm btn-full">Join Bid</a>
            <?php else: ?>
            <a href="listing.php?id=<?= $l['listing_id'] ?>" class="btn btn-primary btn-sm btn-full">View Item</a>
            <?php endif; ?>
          </div>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>
  </div>

  <!-- REVIEWS tab -->
  <div id="section-reviews" style="display:none">

    <?php if ($reviewSuccess): ?><div class="tb-alert tb-alert-success show" style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($reviewSuccess) ?></div><?php endif; ?>
    <?php if ($reviewError):   ?><div class="tb-alert tb-alert-error show"   style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($reviewError) ?></div><?php endif; ?>

    <!-- Leave a review  -->
    <?php if ($canReview): ?>
    <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:20px;margin-bottom:20px">
      <h3 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:14px">Leave a Review</h3>
      <form method="POST" style="display:flex;flex-direction:column;gap:12px">
        <input type="hidden" name="submit_review" value="1">
        <div>
          <label class="tb-label">Rating</label>
          <div style="display:flex;gap:6px" id="starPicker">
            <?php for ($i=1;$i<=5;$i++): ?>
            <label style="cursor:pointer;font-size:28px;color:var(--clr-outline);" id="star<?=$i?>">
              <input type="radio" name="rating" value="<?=$i?>" style="display:none" onchange="setStars(<?=$i?>)">★
            </label>
            <?php endfor; ?>
          </div>
        </div>
        <div>
          <label class="tb-label">Review <span class="opt">(optional)</span></label>
          <textarea name="review_text" class="tb-textarea" placeholder="Share your experience with this seller..."></textarea>
        </div>
        <button type="submit" class="btn btn-primary" style="align-self:flex-start">Submit Review</button>
      </form>
    </div>
    <?php endif; ?>

    <!-- Review list -->
    <?php if (empty($reviews)): ?>
    <div style="text-align:center;padding:48px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
      <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline)">rate_review</span>
      <p style="margin-top:10px;font-weight:600">No reviews yet.</p>
    </div>
    <?php else: ?>
    <div style="display:flex;flex-direction:column;gap:10px">
      <?php foreach ($reviews as $rv): ?>
      <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:18px 20px">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:8px">
          <div>
            <p style="font-weight:700;font-size:var(--fs-label-md);color:var(--clr-text)">@<?= htmlspecialchars($rv['buyer_name']) ?></p>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px">for: <?= htmlspecialchars($rv['item_title']) ?></p>
          </div>
          <div style="text-align:right;flex-shrink:0">
            <!-- Star rating -->
            <div style="display:flex;gap:2px">
              <?php for ($i=1;$i<=5;$i++): ?>
              <span style="color:<?= $i<=$rv['rating']?'#ffc107':'var(--clr-outline)' ?>;font-size:16px">★</span>
              <?php endfor; ?>
            </div>
            <p style="font-size:11px;color:var(--clr-tertiary);margin-top:2px"><?= date('M d, Y', strtotime($rv['review_date'])) ?></p>
          </div>
        </div>
        <?php if ($rv['review_text']): ?>
        <p style="font-size:var(--fs-label-md);color:var(--clr-text-variant);line-height:1.6;border-top:1px solid var(--clr-outline);padding-top:10px;margin-top:4px"><?= nl2br(htmlspecialchars($rv['review_text'])) ?></p>
        <?php endif; ?>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>
  </div>

</main>
<?php renderFooter(); ?>
<script>
function switchTab(name) {
  document.getElementById('section-listings').style.display = name==='listings' ? '' : 'none';
  document.getElementById('section-reviews').style.display  = name==='reviews'  ? '' : 'none';
  document.getElementById('tab-listings').classList.toggle('active', name==='listings');
  document.getElementById('tab-reviews').classList.toggle('active',  name==='reviews');
  return false;
}
function setStars(n) {
  for (let i=1;i<=5;i++) {
    document.getElementById('star'+i).style.color = i<=n ? '#ffc107' : 'var(--clr-outline)';
  }
}
// Check URL hash for tab
if (location.hash === '#reviews') switchTab('reviews');
document.querySelectorAll('[href="#listings"],[href="#reviews"]').forEach(a => {
  a.addEventListener('click', e => { e.preventDefault(); switchTab(a.getAttribute('href').replace('#','')); });
});
</script>
</body></html>
