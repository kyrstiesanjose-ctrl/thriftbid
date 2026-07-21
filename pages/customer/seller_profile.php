<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$sellerId = (int)($_GET['id'] ?? 0);
if (!$sellerId) { header('Location: categories.php'); exit; }

$seller = DB::fetch(
    'SELECT s.*, s.created_at AS joined,
            (SELECT COUNT(*) FROM LISTINGS WHERE seller_id=s.seller_id AND is_active=1 AND deleted_at IS NULL) AS listing_count,
            (SELECT AVG(rating) FROM REVIEWS WHERE seller_id=s.seller_id AND deleted_at IS NULL) AS avg_rating,
            (SELECT COUNT(*) FROM REVIEWS WHERE seller_id=s.seller_id AND deleted_at IS NULL) AS review_count,
            (SELECT COUNT(*) FROM ORDERS WHERE seller_id=s.seller_id AND status="Delivered") AS completed_orders
     FROM SELLER s
     WHERE s.seller_id=?',
    [$sellerId]
);
if (!$seller) { header('Location: categories.php'); exit; }

$listings = DB::fetchAll(
    "SELECT l.*, c.name AS cat_name,
            a.auction_id, a.end_time, a.current_highest_bid, a.status AS auction_status,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     LEFT JOIN AUCTIONS a ON l.listing_id=a.listing_id AND a.status='Active'
     WHERE l.seller_id=? AND l.is_active=1 AND l.deleted_at IS NULL
     ORDER BY l.created_at DESC LIMIT 24",
    [$sellerId]
);

function loadReviews(int $sellerId): array {
    return DB::fetchAll(
        'SELECT r.*, bu.username AS buyer_name, l.title AS item_title
         FROM REVIEWS r
         JOIN BUYER bu ON r.buyer_id=bu.buyer_id
         JOIN ORDERS o ON r.order_id=o.order_id
         JOIN LISTINGS l ON o.listing_id=l.listing_id
         WHERE r.seller_id=? AND r.deleted_at IS NULL
         ORDER BY r.review_date DESC LIMIT 20',
        [$sellerId]
    );
}
$reviews = loadReviews($sellerId);

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? 0;

// Finds the buyer's most recent delivered order for this seller.
// Duplicate reviews are allowed; uses  the before_review_prevent_duplicate database trigger 
// handles the rejection and returns the appropriate error message.
$eligibleOrder = null;
if ($buyerId) {
    $eligibleOrder = DB::fetch(
        'SELECT order_id FROM ORDERS WHERE buyer_id=? AND seller_id=? AND status="Delivered" ORDER BY order_date DESC LIMIT 1',
        [$buyerId, $sellerId]
    );
}
$canReview = (bool)$eligibleOrder;

$reviewSuccess = $reviewError = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit_review']) && $canReview) {
    $rating = (int)($_POST['rating'] ?? 0);
    $text   = trim($_POST['review_text'] ?? '');
    if ($rating < 1 || $rating > 5) {
        $reviewError = 'Please select a rating between 1 and 5.';
    } else {
        try {
            DB::query('INSERT INTO REVIEWS (buyer_id, seller_id, order_id, rating, review_text) VALUES (?,?,?,?,?)',
                [$buyerId, $sellerId, $eligibleOrder['order_id'], $rating, $text ?: null]);
            $canReview     = false;
            $reviewSuccess = 'Your review has been submitted!';
            $reviews       = loadReviews($sellerId);
        } catch (\PDOException $e) {
            $reviewError = str_contains($e->getMessage(), '45000')
                ? 'You have already reviewed this order.'
                : 'Could not submit your review. Please try again.';
        }
    }
}

renderHead(($seller['shop_name'] ?: $seller['username']) . ' — Seller Profile');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('categories'); ?>

<main style="flex:1;max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px;width:100%">

  <div style="background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:28px 32px;margin-bottom:28px;display:flex;align-items:center;gap:24px;flex-wrap:wrap">
    <div style="width:88px;height:88px;border-radius:50%;background:var(--clr-surface-mid);display:flex;align-items:center;justify-content:center;flex-shrink:0;border:2px solid var(--clr-outline)">
      <span class="material-symbols-outlined filled" style="font-size:52px;color:var(--clr-outline)">account_circle</span>
    </div>
    <div style="flex:1;min-width:220px">
      <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px">
        <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text)"><?= htmlspecialchars($seller['shop_name'] ?: $seller['username']) ?></h1>
        <?php if ($seller['shop_name']): ?><p style="font-size:11px;color:var(--clr-tertiary)">@<?= htmlspecialchars($seller['username']) ?></p><?php endif; ?>
        <?php if ($seller['is_verified']): ?><span class="tb-badge tb-badge-active">Verified Seller</span><?php endif; ?>
        <?php if ($seller['seller_status'] !== 'Active'): ?><span class="tb-badge tb-badge-red"><?= $seller['seller_status'] ?></span><?php endif; ?>
      </div>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Member since <?= date('M Y', strtotime($seller['joined'])) ?></p>
    </div>
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

  <div class="tb-tabs" style="margin-bottom:24px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm)">
    <a href="#listings" class="tb-tab-link active" id="tab-listings" onclick="switchTab('listings')">Listings (<?= count($listings) ?>)</a>
    <a href="#reviews"  class="tb-tab-link"         id="tab-reviews"  onclick="switchTab('reviews')">Reviews (<?= count($reviews) ?>)</a>
  </div>

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
          <?php if ($l['cover_image']): ?><img src="<?= htmlspecialchars($l['cover_image']) ?>" alt=""><?php else: ?><span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span><?php endif; ?>
          <?php if ($l['auction_id']): ?><span class="tb-badge-float top-left" style="background:var(--badge-live-bg);color:var(--badge-live-text)">Live</span><?php endif; ?>
        </div>
        <div class="tb-listing-body">
          <div class="tb-listing-title"><?= htmlspecialchars($l['title']) ?></div>
          <?php if ($l['auction_id']): ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['current_highest_bid']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= formatTimeLeft($l['end_time']) ?></div>
          <?php else: ?>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['price']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= htmlspecialchars($l['condition_grade']) ?></div>
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

  <div id="section-reviews" style="display:none">

    <?php if ($reviewSuccess): ?><div class="tb-alert tb-alert-success show" style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($reviewSuccess) ?></div><?php endif; ?>
    <?php if ($reviewError):   ?><div class="tb-alert tb-alert-error show"   style="margin-bottom:16px"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($reviewError) ?></div><?php endif; ?>

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
if (location.hash === '#reviews') switchTab('reviews');
document.querySelectorAll('[href="#listings"],[href="#reviews"]').forEach(a => {
  a.addEventListener('click', e => { e.preventDefault(); switchTab(a.getAttribute('href').replace('#','')); });
});
</script>
</body></html>