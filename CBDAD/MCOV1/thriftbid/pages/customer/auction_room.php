<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$auctionId = (int)($_GET['id'] ?? 0);
if (!$auctionId) { header('Location: live-bids.php'); exit; }

$auction = DB::fetch(
    'SELECT a.*,l.title,l.description,l.item_condition,l.image_url,l.seller_id,l.listing_id,
            c.name as cat_name,u.username as seller_name,s.seller_id as sid
     FROM AUCTIONS a
     JOIN LISTINGS l ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     JOIN SELLER s ON l.seller_id=s.seller_id
     JOIN USERS u ON s.user_id=u.user_id
     WHERE a.auction_id=?',
    [$auctionId]
);
if (!$auction) { header('Location: live-bids.php'); exit; }

$user    = currentUser();
$buyer   = DB::fetch('SELECT buyer_id FROM BUYER WHERE user_id=?', [$user['user_id']]);
$buyerId = $buyer['buyer_id'] ?? 0;

$bids = DB::fetchAll(
    'SELECT b.bid_amount,b.bid_time,u.username
     FROM BIDDINGS b
     JOIN BUYER by2 ON b.buyer_id=by2.buyer_id
     JOIN USERS u ON by2.user_id=u.user_id
     WHERE b.auction_id=?
     ORDER BY b.bid_amount DESC LIMIT 20',
    [$auctionId]
);
$bidCount    = DB::fetch('SELECT COUNT(*) c FROM BIDDINGS WHERE auction_id=?', [$auctionId])['c'] ?? 0;
$minNextBid  = max((float)$auction['current_highest_bid'] + (float)$auction['min_increment'], (float)$auction['start_bid']);

$bidError = $bidSuccess = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['bid_amount'])) {
    $bidAmount = (float)$_POST['bid_amount'];
    if ($auction['status'] !== 'Active') {
        $bidError = 'This auction has ended.';
    } elseif (!$buyerId) {
        $bidError = 'Only registered buyers can place bids.';
    } elseif ($bidAmount < $minNextBid) {
        $bidError = 'Your bid must be at least ' . convertCurrency($minNextBid) . '.';
    } else {
        DB::query('INSERT INTO BIDDINGS (bid_amount,auction_id,buyer_id) VALUES (?,?,?)', [$bidAmount, $auctionId, $buyerId]);
        // Notify outbid user
        if (!empty($bids)) {
            $prev = DB::fetch('SELECT by2.user_id FROM BIDDINGS b JOIN BUYER by2 ON b.buyer_id=by2.buyer_id WHERE b.auction_id=? ORDER BY b.bid_amount DESC LIMIT 1 OFFSET 1', [$auctionId]);
            if ($prev && $prev['user_id'] !== $user['user_id']) {
                DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
                    [$prev['user_id'], 'You have been outbid!', 'Someone placed a higher bid on "'.$auction['title'].'".', 'BID']);
            }
        }
        // Notify seller
        $sellerUser = DB::fetch('SELECT u.user_id FROM SELLER s JOIN USERS u ON s.user_id=u.user_id WHERE s.seller_id=?', [$auction['sid']]);
        if ($sellerUser) DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
            [$sellerUser['user_id'], 'New bid on your listing!', 'A bid of '.convertCurrency($bidAmount).' was placed on "'.$auction['title'].'".', 'BID']);

        $bidSuccess = 'Bid of ' . convertCurrency($bidAmount) . ' placed successfully!';
        // Refresh data
        $auction  = DB::fetch('SELECT a.*,l.title,l.description,l.item_condition,l.image_url,l.seller_id,l.listing_id,c.name as cat_name,u.username as seller_name,s.seller_id as sid FROM AUCTIONS a JOIN LISTINGS l ON a.listing_id=l.listing_id JOIN CATEGORIES c ON l.category_id=c.category_id JOIN SELLER s ON l.seller_id=s.seller_id JOIN USERS u ON s.user_id=u.user_id WHERE a.auction_id=?', [$auctionId]);
        $bids     = DB::fetchAll('SELECT b.bid_amount,b.bid_time,u.username FROM BIDDINGS b JOIN BUYER by2 ON b.buyer_id=by2.buyer_id JOIN USERS u ON by2.user_id=u.user_id WHERE b.auction_id=? ORDER BY b.bid_amount DESC LIMIT 20', [$auctionId]);
        $bidCount = DB::fetch('SELECT COUNT(*) c FROM BIDDINGS WHERE auction_id=?', [$auctionId])['c'] ?? 0;
        $minNextBid = max((float)$auction['current_highest_bid'] + (float)$auction['min_increment'], (float)$auction['start_bid']);
    }
}

renderHead($auction['title'] . ' — Auction Room');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('livebids'); ?>

<main style="flex:1;max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px;width:100%">

  <!-- Breadcrumb -->
  <nav style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:20px;display:flex;align-items:center;gap:6px">
    <a href="home.php" style="color:var(--clr-tertiary)">Home</a>
    <span class="material-symbols-outlined icon-sm">chevron_right</span>
    <a href="live-bids.php" style="color:var(--clr-tertiary)">Live Bids</a>
    <span class="material-symbols-outlined icon-sm">chevron_right</span>
    <span style="color:var(--clr-text)"><?= htmlspecialchars($auction['title']) ?></span>
  </nav>

  <!-- Auction Room  -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

    <!-- LEFT: Item details -->
    <div style="display:flex;flex-direction:column;gap:20px">

      <!-- Image -->
      <div style="background:var(--clr-surface-mid);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);aspect-ratio:4/5;display:flex;align-items:center;justify-content:center;overflow:hidden">
        <?php if ($auction['image_url']): ?>
        <img src="<?= htmlspecialchars($auction['image_url']) ?>" alt="<?= htmlspecialchars($auction['title']) ?>" style="width:100%;height:100%;object-fit:cover">
        <?php else: ?>
        <span class="material-symbols-outlined" style="font-size:80px;color:var(--clr-outline)">checkroom</span>
        <?php endif; ?>
      </div>

      <!-- Item meta -->
      <div class="tb-card tb-card-body">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:12px">
          <div>
            <span class="tb-badge tb-badge-gray" style="margin-bottom:8px"><?= htmlspecialchars($auction['cat_name']) ?></span>
            <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text)"><?= htmlspecialchars($auction['title']) ?></h1>
            <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-top:6px">
              Sold by
              <a href="seller_profile.php?id=<?= $auction['sid'] ?>" style="color:var(--clr-coral);font-weight:700">@<?= htmlspecialchars($auction['seller_name']) ?></a>
              &bull; Condition: <strong style="color:var(--clr-text)"><?= htmlspecialchars($auction['item_condition']) ?></strong>
            </p>
          </div>
          <?php if ($auction['status'] === 'Active'): ?>
          <span class="tb-badge tb-badge-live">Live</span>
          <?php else: ?>
          <span class="tb-badge tb-badge-ended">Ended</span>
          <?php endif; ?>
        </div>
        <?php if ($auction['description']): ?>
        <p style="font-size:var(--fs-label-md);color:var(--clr-text-variant);line-height:1.7;border-top:1px solid var(--clr-outline);padding-top:12px"><?= nl2br(htmlspecialchars($auction['description'])) ?></p>
        <?php endif; ?>
      </div>
    </div>

    <!-- RIGHT: Bid panel + feed -->
    <div style="display:flex;flex-direction:column;gap:16px">

      <!-- Current bid + countdown -->
      <div class="tb-card tb-card-body">
        <div class="grid grid-cols-2 gap-4 mb-4">
          <div>
            <p class="tb-section-label">Current Highest Bid</p>
            <p style="font-family:'Hanken Grotesk',sans-serif;font-size:36px;font-weight:800;color:var(--clr-text)">
              <?= convertCurrency((float)$auction['current_highest_bid']) ?>
            </p>
          </div>
          <div>
            <p class="tb-section-label">Time Remaining</p>
            <p style="font-family:'Hanken Grotesk',sans-serif;font-size:22px;font-weight:800;color:var(--clr-coral)" id="countdown" data-end="<?= strtotime($auction['end_time']) ?>">
              <?= $auction['status'] === 'Active' ? formatTimeLeft($auction['end_time']) : 'Auction Ended' ?>
            </p>
          </div>
        </div>
        <div style="display:flex;gap:16px;font-size:var(--fs-label-sm);color:var(--clr-tertiary);padding-top:10px;border-top:1px solid var(--clr-outline)">
          <span><?= $bidCount ?> bid<?= $bidCount!==1?'s':'' ?></span>
          <span>&bull;</span>
          <span>Min increment: <?= convertCurrency((float)$auction['min_increment']) ?></span>
          <span>&bull;</span>
          <span>Start bid: <?= convertCurrency((float)$auction['start_bid']) ?></span>
        </div>
      </div>

      <!-- Alerts -->
      <?php if ($bidError):   ?><div class="tb-alert tb-alert-error show"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($bidError) ?></div><?php endif; ?>
      <?php if ($bidSuccess): ?><div class="tb-alert tb-alert-success show"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($bidSuccess) ?></div><?php endif; ?>

      <!-- Place Bid form page -->
      <?php if ($auction['status'] === 'Active'): ?>
      <div class="tb-card tb-card-body">
        <h3 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:16px">Place Your Bid</h3>
        <form method="POST" style="display:flex;flex-direction:column;gap:12px">
          <div>
            <label class="tb-label">Bid Amount (minimum <?= convertCurrency($minNextBid) ?>)</label>
            <div style="display:flex;gap:8px">
              <div style="position:relative;flex:1">
                <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-weight:700;color:var(--clr-tertiary)">₱</span>
                <input class="tb-input" type="number" name="bid_amount" min="<?= $minNextBid ?>" step="<?= $auction['min_increment'] ?>" value="<?= $minNextBid ?>" style="padding-left:28px;font-size:18px;font-weight:700" required>
              </div>
              <button type="submit" class="btn btn-primary btn-lg" style="white-space:nowrap">Place Bid</button>
            </div>
          </div>
          <!-- Quick bid amounts -->
          <div style="display:flex;gap:6px">
            <?php for ($i = 0; $i <= 2; $i++): $suggested = $minNextBid + ($i * (float)$auction['min_increment']); ?>
            <button type="button" class="btn btn-ghost btn-sm" onclick="document.querySelector('[name=bid_amount]').value='<?= $suggested ?>'" style="flex:1">
              <?= convertCurrency($suggested) ?>
            </button>
            <?php endfor; ?>
          </div>
        </form>
        <!-- Currency toggle -->
        <div style="display:flex;align-items:center;gap:8px;margin-top:14px;padding-top:14px;border-top:1px solid var(--clr-outline)">
          <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">View in:</span>
          <?php foreach (['PHP','USD','KRW'] as $cur): ?>
          <button onclick="showCur('<?= $cur ?>', <?= (float)$auction['current_highest_bid'] ?>)" class="btn btn-ghost btn-sm"><?= $cur ?></button>
          <?php endforeach; ?>
          <span id="convertedPrice" style="font-size:var(--fs-label-md);font-weight:700;color:var(--clr-coral)"></span>
        </div>
      </div>
      <?php else: ?>
      <div class="tb-card tb-card-body" style="text-align:center;color:var(--clr-tertiary)">
        <span class="tb-badge tb-badge-ended" style="font-size:13px;padding:6px 16px">Auction Ended</span>
        <p style="margin-top:10px;font-size:var(--fs-label-md)">This auction has closed. No further bids accepted.</p>
      </div>
      <?php endif; ?>

      <!-- Live Bid Feed -->
      <div class="tb-card">
        <div class="tb-card-header" style="background:var(--clr-surface-low)">
          <span>Live Bid Feed</span>
          <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $bidCount ?> total bids</span>
        </div>
        <?php if (empty($bids)): ?>
        <div style="padding:24px;text-align:center;color:var(--clr-tertiary);font-size:var(--fs-label-md)">No bids yet — be the first!</div>
        <?php else: ?>
        <div class="tb-bid-feed" style="padding:10px">
          <?php foreach ($bids as $i => $b): ?>
          <div class="tb-bid-feed-row <?= $i===0?'leader':'' ?>">
            <div>
              <span class="tb-bid-feed-user">@<?= htmlspecialchars($b['username']) ?></span>
              <?php if ($i === 0): ?><span class="tb-badge tb-badge-live" style="margin-left:6px;font-size:9px">Leading</span><?php endif; ?>
            </div>
            <div style="display:flex;align-items:center;gap:10px">
              <span class="tb-bid-feed-amount"><?= convertCurrency((float)$b['bid_amount']) ?></span>
              <span class="tb-bid-feed-time"><?= date('H:i', strtotime($b['bid_time'])) ?></span>
            </div>
          </div>
          <?php endforeach; ?>
        </div>
        <?php endif; ?>
      </div>

    </div><!-- /right -->
  </div><!-- /grid -->

</main>
<?php renderFooter(); ?>
<script>
// Countdown
const cdEl = document.getElementById('countdown');
if (cdEl) {
  const endTs = parseInt(cdEl.dataset.end);
  function tick() {
    const d = endTs - Math.floor(Date.now()/1000);
    if (d <= 0) { cdEl.textContent='Ended'; return; }
    const h=Math.floor(d/3600),m=Math.floor((d%3600)/60),s=d%60;
    cdEl.textContent = d>=86400 ? Math.floor(d/86400)+'d '+h+'h' : String(h).padStart(2,'0')+':'+String(m).padStart(2,'0')+':'+String(s).padStart(2,'0');
    if (d < 3600) cdEl.style.color='var(--clr-error)';
  }
  setInterval(tick, 1000); tick();
}
// Currency
const rates={PHP:1,USD:0.0175,KRW:23.5},syms={PHP:'₱',USD:'$',KRW:'₩'};
function showCur(c,v){const r=v*rates[c];document.getElementById('convertedPrice').textContent=syms[c]+(c==='KRW'?Math.round(r).toLocaleString():r.toFixed(2))+' '+c;}
</script>
</body></html>
