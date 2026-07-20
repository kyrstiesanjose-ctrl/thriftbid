<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$user = currentUser();

$imgSub = '(SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image';

$liveAuctions = DB::fetchAll(
    "SELECT a.*, l.title, l.condition_grade, l.listing_id, c.name AS cat_name, $imgSub
     FROM AUCTIONS a
     JOIN LISTINGS l ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     WHERE a.status='Active' AND a.end_time>NOW() AND l.deleted_at IS NULL
     ORDER BY a.end_time ASC LIMIT 8"
);

$fixedListings = DB::fetchAll(
    "SELECT l.*, c.name AS cat_name, $imgSub
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     WHERE l.is_active=1 AND l.deleted_at IS NULL
       AND l.listing_id NOT IN (SELECT listing_id FROM AUCTIONS WHERE status='Active')
     ORDER BY l.created_at DESC LIMIT 8"
);

// Parent categoriesin  "Browse by Category"
$parentCats = DB::fetchAll('SELECT DISTINCT parent_category FROM PARENT_CATEGORIES ORDER BY parent_category');
$catIcons   = [
    'Tops'=>'checkroom','Bottoms'=>'layers','Dresses & Co_ords'=>'dry_cleaning','Footwear'=>'footprint',
    'Bags & Purses'=>'shopping_bag','Accessories'=>'diamond','Others'=>'category',
];

renderHead('Home');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('home'); ?>

<main style="flex:1;max-width:var(--sp-container);margin:0 auto;padding:32px var(--sp-margin-desktop) 80px;width:100%">

  <!-- Hero -->
  <section class="tb-hero" style="margin-bottom:40px">
    <div class="tb-hero-text">
      <span class="tb-badge tb-badge-coral" style="margin-bottom:14px;font-size:11px">New Arrivals Daily</span>
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-display-lg);font-weight:800;color:var(--clr-text);line-height:1.08;margin-bottom:14px">
        Hello, <?= htmlspecialchars($user['username']) ?>.<br>
        <span style="color:var(--clr-coral)">Find your next vintage gem.</span>
      </h1>
      <p style="font-size:var(--fs-body-lg);color:var(--clr-tertiary);margin-bottom:24px;max-width:460px;line-height:1.6">Authenticated pieces from trusted sellers. Join live bids, buy now, or browse all categories.</p>
      <div style="display:flex;gap:10px;flex-wrap:wrap">
        <a href="live-bids.php" class="btn btn-primary btn-lg">View Live Auctions</a>
        <a href="categories.php" class="btn btn-ghost btn-lg">Browse All</a>
      </div>
    </div>
    <div class="tb-hero-visual">
      <div style="text-align:center;color:var(--clr-tertiary)">
        <span class="material-symbols-outlined" style="font-size:72px;color:var(--clr-outline)">checkroom</span>
        <p style="font-size:var(--fs-label-md);font-weight:600;margin-top:8px">Luxury Thrift Picks</p>
        <p style="font-size:var(--fs-label-sm);margin-top:4px;color:var(--clr-tertiary)">Authenticated designer items</p>
      </div>
    </div>
  </section>

  <!-- Categories scroll (parent categories ) -->
  <section style="margin-bottom:40px">
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
      <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:700">Browse by Category</h2>
      <a href="categories.php" style="font-size:var(--fs-label-md);color:var(--clr-coral);font-weight:600">View All</a>
    </div>
    <div style="display:flex;gap:10px;overflow-x:auto;padding-bottom:6px" class="no-scroll">
      <?php foreach ($parentCats as $pc): $name = $pc['parent_category']; ?>
      <a href="categories.php?parent=<?= urlencode($name) ?>" class="tb-cat-pill">
        <span class="material-symbols-outlined"><?= $catIcons[$name] ?? 'category' ?></span>
        <span class="label"><?= htmlspecialchars($name) ?></span>
      </a>
      <?php endforeach; ?>
    </div>
  </section>

  <!-- Live Auctions Join Bid -->
  <section style="margin-bottom:40px">
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
      <div style="display:flex;align-items:center;gap:10px">
        <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:700">Live Auctions</h2>
        <span class="tb-badge tb-badge-live" style="animation:pulse-soft 2s infinite">
          <span style="width:6px;height:6px;border-radius:50%;background:var(--badge-live-text);display:inline-block;margin-right:3px"></span>LIVE
        </span>
      </div>
      <a href="live-bids.php" style="font-size:var(--fs-label-md);color:var(--clr-coral);font-weight:600">See All</a>
    </div>
    <?php if (empty($liveAuctions)): ?>
    <div style="text-align:center;padding:40px;color:var(--clr-tertiary);background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm)">
      <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline)">gavel</span>
      <p style="margin-top:8px;font-weight:600">No live auctions right now.</p>
    </div>
    <?php else: ?>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <?php foreach ($liveAuctions as $a):
        $isUrgent = (strtotime($a['end_time']) - time()) < 3600;
      ?>
      <div class="tb-listing-card">
        <div class="tb-listing-thumb">
          <?php if ($a['cover_image']): ?>
            <img src="<?= htmlspecialchars($a['cover_image']) ?>" alt="<?= htmlspecialchars($a['title']) ?>">
          <?php else: ?>
            <span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span>
          <?php endif; ?>
          <?php if ($isUrgent): ?>
          <span class="tb-badge-float top-left" style="background:var(--clr-error);color:#fff">Ending Soon</span>
          <?php else: ?>
          <span class="tb-badge-float top-left" style="background:var(--badge-live-bg);color:var(--badge-live-text)">Live</span>
          <?php endif; ?>
        </div>
        <div class="tb-listing-body">
          <div class="tb-listing-title"><?= htmlspecialchars($a['title']) ?></div>
          <p style="font-size:10px;color:var(--clr-tertiary);margin-bottom:2px;margin-top:2px">Current Bid</p>
          <div class="tb-listing-price"><?= convertCurrency((float)$a['current_highest_bid']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($a['cat_name']) ?> &bull; <?= formatTimeLeft($a['end_time']) ?></div>
          <div class="tb-listing-cta">
            <a href="auction_room.php?id=<?= $a['auction_id'] ?>" class="btn btn-yellow btn-sm btn-full">Join Bid</a>
          </div>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>
  </section>

  <!-- Buy Now Listings -->
  <section>
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:16px">
      <h2 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:700">Buy Now</h2>
      <a href="categories.php?type=fixed" style="font-size:var(--fs-label-md);color:var(--clr-coral);font-weight:600">See All</a>
    </div>
    <?php if (empty($fixedListings)): ?>
    <div style="text-align:center;padding:40px;color:var(--clr-tertiary);background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm)">No listings yet.</div>
    <?php else: ?>
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
      <?php foreach ($fixedListings as $l): ?>
      <div class="tb-listing-card">
        <div class="tb-listing-thumb">
          <?php if ($l['cover_image']): ?>
            <img src="<?= htmlspecialchars($l['cover_image']) ?>" alt="<?= htmlspecialchars($l['title']) ?>">
          <?php else: ?>
            <span class="material-symbols-outlined icon-xl tb-listing-placeholder">checkroom</span>
          <?php endif; ?>
        </div>
        <div class="tb-listing-body">
          <div class="tb-listing-title"><?= htmlspecialchars($l['title']) ?></div>
          <div class="tb-listing-price"><?= convertCurrency((float)$l['price']) ?></div>
          <div class="tb-listing-meta"><?= htmlspecialchars($l['cat_name']) ?> &bull; <?= htmlspecialchars($l['condition_grade']) ?></div>
          <div class="tb-listing-cta">
            <a href="listing.php?id=<?= $l['listing_id'] ?>" class="btn btn-primary btn-sm btn-full">View Item</a>
          </div>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>
  </section>

</main>
<?php renderFooter(); ?>
</body></html>