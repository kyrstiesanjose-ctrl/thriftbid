<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$auctions = DB::fetchAll(
    'SELECT a.*,l.title,l.description,l.item_condition,l.image_url,l.listing_id,
            c.name as cat_name,u.username as seller_name,s.seller_id,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id) as bid_count
     FROM AUCTIONS a
     JOIN LISTINGS l  ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s ON l.seller_id=s.seller_id
     JOIN USERS u  ON s.user_id=u.user_id
     WHERE a.status="Active" AND a.end_time>NOW()
     ORDER BY a.end_time ASC'
);

renderHead('Live Auctions');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('livebids'); ?>

<!-- Hero strip -->
<div style="background:var(--clr-coral);padding:24px var(--sp-margin-desktop)">
  <div style="max-width:var(--sp-container);margin:0 auto;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:14px">
    <div>
      <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px">
        <span class="tb-badge" style="background:rgba(255,255,255,0.22);color:#fff;border:1px solid rgba(255,255,255,0.35)">
          <span style="width:6px;height:6px;border-radius:50%;background:#fff;display:inline-block;margin-right:4px"></span>LIVE NOW
        </span>
        <span style="color:rgba(255,255,255,0.9);font-size:var(--fs-label-md);font-weight:600"><?= count($auctions) ?> Active Auction<?= count($auctions)!==1?'s':'' ?></span>
      </div>
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);color:#fff;font-weight:800">Live Bidding Room</h1>
      <p style="color:rgba(255,255,255,0.82);margin-top:4px;font-size:var(--fs-label-md)">Anti-snipe protection active. Place bids before time runs out.</p>
    </div>
    <a href="categories.php?type=auction" class="btn btn-white">Browse All Auctions</a>
  </div>
</div>

<main style="flex:1">
  <div style="max-width:var(--sp-container);margin:0 auto;padding:32px var(--sp-margin-desktop) 80px">

    <?php if (empty($auctions)): ?>
    <div style="text-align:center;padding:64px 20px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
      <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">gavel</span>
      <p style="font-weight:700;font-size:var(--fs-headline-sm)">No live auctions right now</p>
      <p style="margin-top:6px">New auctions are posted daily. Check back soon!</p>
      <a href="categories.php" class="btn btn-outline" style="margin-top:20px">Browse All Listings</a>
    </div>
    <?php else: ?>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
      <?php foreach ($auctions as $a):
        $isUrgent  = (strtotime($a['end_time']) - time()) < 3600;
        $timeLeft  = formatTimeLeft($a['end_time']);
      ?>
      <div class="tb-card" style="display:flex;flex-direction:column;transition:box-shadow var(--transition)">
        <!-- Image -->
        <div style="position:relative;aspect-ratio:4/3;background:var(--clr-surface-mid);display:flex;align-items:center;justify-content:center;overflow:hidden">
          <?php if ($a['image_url']): ?>
          <img src="<?= htmlspecialchars($a['image_url']) ?>" alt="<?= htmlspecialchars($a['title']) ?>" style="width:100%;height:100%;object-fit:cover">
          <?php else: ?>
          <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline)">checkroom</span>
          <?php endif; ?>
          <!-- Badge: LIVE=yellow, urgent=red -->
          <?php if ($isUrgent): ?>
          <span class="tb-badge-float top-left" style="background:var(--clr-error);color:#fff">Ending Soon</span>
          <?php else: ?>
          <span class="tb-badge-float top-left" style="background:var(--badge-live-bg);color:var(--badge-live-text)">Live</span>
          <?php endif; ?>
        </div>

        <!-- Body -->
        <div style="padding:16px 18px;flex:1;display:flex;flex-direction:column;gap:10px">
          <div>
            <span class="tb-badge tb-badge-gray" style="margin-bottom:6px"><?= htmlspecialchars($a['cat_name']) ?></span>
            <h3 style="font-weight:700;font-size:var(--fs-body-md);color:var(--clr-text);line-height:1.3;margin-bottom:2px"><?= htmlspecialchars($a['title']) ?></h3>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
              by <a href="seller_profile.php?id=<?= $a['seller_id'] ?>" style="color:var(--clr-coral);font-weight:600">@<?= htmlspecialchars($a['seller_name']) ?></a>
              &bull; <?= htmlspecialchars($a['item_condition']) ?>
            </p>
          </div>

          <!-- Stats row -->
          <div class="grid grid-cols-2 gap-2" style="background:var(--clr-bg);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:10px 12px">
            <div>
              <p style="font-size:10px;font-weight:700;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:2px">Current Bid</p>
              <p style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:800;color:var(--clr-text)"><?= convertCurrency((float)$a['current_highest_bid']) ?></p>
            </div>
            <div>
              <p style="font-size:10px;font-weight:700;color:var(--clr-tertiary);text-transform:uppercase;letter-spacing:0.06em;margin-bottom:2px">Time Left</p>
              <p style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-label-md);font-weight:800;color:<?= $isUrgent?'var(--clr-error)':'var(--clr-coral)' ?>" data-end="<?= strtotime($a['end_time']) ?>"><?= $timeLeft ?></p>
            </div>
          </div>

          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $a['bid_count'] ?> bid<?= $a['bid_count']!==1?'s':'' ?> &bull; Min. increment: <?= convertCurrency((float)$a['min_increment']) ?></p>

          <!-- JOIN BID ,  goes to auction_room.php -->
          <a href="auction_room.php?id=<?= $a['auction_id'] ?>" class="btn btn-yellow btn-full" style="margin-top:auto">
            <span class="material-symbols-outlined icon-sm">gavel</span>Join Bid
          </a>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>

  </div>
</main>
<?php renderFooter(); ?>
<script>
// Live countdowns
document.querySelectorAll('[data-end]').forEach(el => {
  function upd() {
    const d = parseInt(el.dataset.end) - Math.floor(Date.now()/1000);
    if (d <= 0) { el.textContent='Ended'; el.style.color='var(--clr-tertiary)'; return; }
    const h=Math.floor(d/3600),m=Math.floor((d%3600)/60),s=d%60;
    el.textContent = d>=86400 ? Math.floor(d/86400)+'d '+h+'h '+m+'m'
                               : String(h).padStart(2,'0')+':'+String(m).padStart(2,'0')+':'+String(s).padStart(2,'0');
    if (d<3600) el.style.color='var(--clr-error)';
  }
  setInterval(upd,1000); upd();
});
</script>
</body></html>
