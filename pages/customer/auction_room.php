<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');

$auctionId = (int)($_GET['id'] ?? 0);
if (!$auctionId) { header('Location: live-bids.php'); exit; }

function loadAuction(int $auctionId): array|false {
    return DB::fetch(
        "SELECT a.*, l.title, l.description, l.condition_grade, l.seller_id, l.listing_id, l.original_price,
                c.name AS cat_name, COALESCE(se.shop_name, se.username) AS seller_name, se.seller_id AS sid,
                (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image
         FROM AUCTIONS a
         JOIN LISTINGS l ON a.listing_id=l.listing_id
         JOIN CATEGORIES c ON l.category_id=c.category_id
         JOIN SELLER se ON l.seller_id=se.seller_id
         WHERE a.auction_id=?",
        [$auctionId]
    );
}
function loadBids(int $auctionId, int $limit = 20): array {
    return DB::fetchAll(
        "SELECT b.bid_amount, b.bid_time, bu.username
         FROM BIDDINGS b
         JOIN BUYER bu ON b.buyer_id=bu.buyer_id
         WHERE b.auction_id=? AND b.is_deleted=0
         ORDER BY b.bid_amount DESC LIMIT $limit",
        [$auctionId]
    );
}

$auction = loadAuction($auctionId);
if (!$auction) { header('Location: live-bids.php'); exit; }

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? 0; // session row IS the buyer row now (0 if an admin/seller is just viewing)

// The seller who owns this listing (or an admin) gets a read-only
// management view instead of the buyer's bid form: they can see every
// bidder (not capped at 20) and edit the listing, but cannot bid on
// their own auction.
$isOwnerSeller = ($user['role'] === 'seller' && (int)($user['seller_id'] ?? 0) === (int)$auction['sid'])
              || $user['role'] === 'admin';
// Narrower than $isOwnerSeller above: true only for the actual seller who
// owns this listing, never for admin. Admins shouldn't get routed into
// the seller's own edit-listing.php as if they own the item, they have
// their own moderation tools for that (admin/listings.php, etc.).
$isActualOwnerSeller = $user['role'] === 'seller' && (int)($user['seller_id'] ?? 0) === (int)$auction['sid'];

$bids       = loadBids($auctionId, $isOwnerSeller ? 1000 : 20);
$bidCount   = DB::fetch('SELECT COUNT(*) c FROM BIDDINGS WHERE auction_id=? AND is_deleted=0', [$auctionId])['c'] ?? 0;
$minNextBid = max((float)$auction['current_highest_bid'] + (float)$auction['min_increment'], (float)$auction['start_bid']);

$bidError = $bidSuccess = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['bid_amount'])) {
    $bidAmount = (float)$_POST['bid_amount'];

    if ($isOwnerSeller) {
        $bidError = 'Sellers cannot bid on their own listing.';
    } elseif (!$buyerId) {
        $bidError = 'Only registered buyers can place bids.';
    } else {
        // ------------------------------------------------------------
        // We deliberately do NOT re-implement the auction rules here.
        // before_bid_validate_amount (auction must be Active & amount
        // must clear current_highest_bid + min_increment) and
        // after_bid_update_auction (bumps current_highest_bid, applies
        // the anti-snipe +2min/10x extension, logs BROWSING_HISTORY)
        // are DB triggers, see database/triggers.sql. The INSERT below
        // is the ONLY statement this page runs; everything else is the
        // trigger's job. We just catch the SIGNAL it raises on failure.
        // ------------------------------------------------------------
        try {
            DB::query('INSERT INTO BIDDINGS (bid_amount, bid_time, auction_id, buyer_id) VALUES (?, NOW(), ?, ?)',
                [$bidAmount, $auctionId, $buyerId]);

            // Outbid notice to the previous top bidder (not a trigger
            // concern, this is a courtesy notification, not a rule).
            $prev = DB::fetch(
                'SELECT bu.buyer_id FROM BIDDINGS b JOIN BUYER bu ON b.buyer_id=bu.buyer_id
                 WHERE b.auction_id=? AND b.is_deleted=0 ORDER BY b.bid_amount DESC LIMIT 1 OFFSET 1',
                [$auctionId]
            );
            if ($prev && (int)$prev['buyer_id'] !== $buyerId) {
                DB::query('INSERT INTO NOTIFICATIONS (buyer_id, title, message, notification_type) VALUES (?,?,?,?)',
                    [$prev['buyer_id'], 'You have been outbid!', 'Someone placed a higher bid on "' . $auction['title'] . '".', 'BID']);
            }
            DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
                [$auction['sid'], 'New bid on your listing!', 'A bid of ' . convertCurrency($bidAmount) . ' was placed on "' . $auction['title'] . '".', 'BID']);

            $bidSuccess = 'Bid of ' . convertCurrency($bidAmount) . ' placed successfully!';

            // Re-pull fresh state, current_highest_bid/end_time/extension_count
            // were just mutated by the trigger, not by this script.
            $auction    = loadAuction($auctionId);
            $bids       = loadBids($auctionId, $isOwnerSeller ? 1000 : 20);
            $bidCount   = DB::fetch('SELECT COUNT(*) c FROM BIDDINGS WHERE auction_id=? AND is_deleted=0', [$auctionId])['c'] ?? 0;
            $minNextBid = max((float)$auction['current_highest_bid'] + (float)$auction['min_increment'], (float)$auction['start_bid']);
        } catch (\PDOException $e) {
            // SQLSTATE 45000 = the SIGNAL raised by before_bid_validate_amount
            // ("auction closed" or "bid too low"). Surface it plainly.
            $bidError = str_contains($e->getMessage(), '45000')
                ? preg_replace('/^.*45000\s*/', '', $e->getMessage())
                : 'Could not place bid. Please try again.';
        }
    }
}

renderHead($auction['title'] . ' - Auction Room');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar('livebids'); ?>

<main style="flex:1;max-width:var(--sp-container);margin:0 auto;padding:28px var(--sp-margin-desktop) 80px;width:100%">

  <nav style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-bottom:20px;display:flex;align-items:center;gap:6px">
    <?php if ($isOwnerSeller): ?>
    <a href="<?= $user['role']==='admin' ? '../admin/dashboard.php' : '../seller/dashboard.php' ?>" style="color:var(--clr-tertiary)"><?= $user['role']==='admin' ? 'Admin' : 'Seller Center' ?></a>
    <span class="material-symbols-outlined icon-sm">chevron_right</span>
    <a href="<?= $user['role']==='admin' ? '../admin/auctions.php' : '../seller/active-auctions.php' ?>" style="color:var(--clr-tertiary)"><?= $user['role']==='admin' ? 'Auctions' : 'My Auctions' ?></a>
    <?php else: ?>
    <a href="home.php" style="color:var(--clr-tertiary)">Home</a>
    <span class="material-symbols-outlined icon-sm">chevron_right</span>
    <a href="live-bids.php" style="color:var(--clr-tertiary)">Live Bids</a>
    <?php endif; ?>
    <span class="material-symbols-outlined icon-sm">chevron_right</span>
    <span style="color:var(--clr-text)"><?= htmlspecialchars($auction['title']) ?></span>
  </nav>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

    <div style="display:flex;flex-direction:column;gap:20px">
      <div style="background:var(--clr-surface-mid);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);aspect-ratio:4/5;display:flex;align-items:center;justify-content:center;overflow:hidden">
        <?php if ($auction['cover_image']): ?>
        <img src="<?= htmlspecialchars($auction['cover_image']) ?>" alt="<?= htmlspecialchars($auction['title']) ?>" style="width:100%;height:100%;object-fit:cover">
        <?php else: ?>
        <span class="material-symbols-outlined" style="font-size:80px;color:var(--clr-outline)">checkroom</span>
        <?php endif; ?>
      </div>

      <div class="tb-card tb-card-body">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;margin-bottom:12px">
          <div>
            <span class="tb-badge tb-badge-gray" style="margin-bottom:8px"><?= htmlspecialchars($auction['cat_name']) ?></span>
            <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text)"><?= htmlspecialchars($auction['title']) ?></h1>
            <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-top:6px">
              Sold by
              <a href="seller_profile.php?id=<?= $auction['sid'] ?>" style="color:var(--clr-coral);font-weight:700"><?= htmlspecialchars($auction['seller_name']) ?></a>
              &bull; Condition: <strong style="color:var(--clr-text)"><?= htmlspecialchars($auction['condition_grade']) ?></strong>
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

    <div style="display:flex;flex-direction:column;gap:16px">

      <div class="tb-card tb-card-body">
        <div class="grid grid-cols-2 gap-4 mb-4">
          <div>
            <p class="tb-section-label">Current Highest Bid</p>
            <p style="font-family:'Hanken Grotesk',sans-serif;font-size:36px;font-weight:800;color:var(--clr-text)">
              <?= convertCurrency((float)$auction['current_highest_bid']) ?>
            </p>
            <?php if (!empty($auction['original_price'])): ?>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Retails new for <?= convertCurrency((float)$auction['original_price']) ?></p>
            <?php endif; ?>
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
          <?php if ((int)$auction['extension_count'] > 0): ?>
          <span>&bull;</span>
          <span title="Anti-snipe rule extended this auction">Extended <?= $auction['extension_count'] ?>&times;</span>
          <?php endif; ?>
        </div>
      </div>

      <?php if ($bidError):   ?><div class="tb-alert tb-alert-error show"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($bidError) ?></div><?php endif; ?>
      <?php if ($bidSuccess): ?><div class="tb-alert tb-alert-success show"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($bidSuccess) ?></div><?php endif; ?>

      <?php if ($auction['status'] === 'Active'): ?>
      <div class="tb-card tb-card-body">
        <?php if ($isActualOwnerSeller): ?>
        <h3 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:12px">Manage This Listing</h3>
        <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:16px">
          This is your listing, you're viewing the live auction room the same way buyers do, but you can't place a bid on your own item.
          Need to change the title, photos, or details? Edit it below (price and increment lock once bidding starts).
        </p>
        <a href="../seller/edit-listing.php?id=<?= $auction['listing_id'] ?>" class="btn btn-primary btn-full">
          <span class="material-symbols-outlined icon-sm">edit</span>Edit Listing Details
        </a>
        <?php elseif ($user['role'] === 'admin'): ?>
        <h3 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:12px">Admin View</h3>
        <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:16px">
          You're viewing this live auction as an admin. You can't bid, and editing the listing itself isn't part of the admin role, that belongs to the seller.
          If this listing needs action (a report, a dispute, a takedown), use Moderation or Listings from the admin panel.
        </p>
        <div style="display:flex;gap:10px">
          <a href="../admin/listings.php" class="btn btn-outline btn-full">
            <span class="material-symbols-outlined icon-sm">list_alt</span>Manage Listings
          </a>
          <a href="../admin/moderation.php" class="btn btn-outline btn-full">
            <span class="material-symbols-outlined icon-sm">gavel</span>Moderation
          </a>
        </div>
        <?php else: ?>
        <h3 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-sm);font-weight:700;margin-bottom:16px">Place Your Bid</h3>
        <form method="POST" style="display:flex;flex-direction:column;gap:12px">
          <div>
            <label class="tb-label">Bid Amount (minimum <?= convertCurrency($minNextBid) ?>)</label>
            <div style="display:flex;gap:8px">
              <div style="position:relative;flex:1">
                <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-weight:700;color:var(--clr-tertiary)">₱</span>
                <input class="tb-input" type="number" name="bid_amount" min="<?= $minNextBid ?>" step="0.01" value="<?= $minNextBid ?>" style="padding-left:28px;font-size:18px;font-weight:700" required>
              </div>
              <button type="submit" class="btn btn-primary btn-lg" style="white-space:nowrap">Place Bid</button>
            </div>
            <p style="font-size:11px;color:var(--clr-tertiary);margin-top:4px">The server has the final say on whether a bid is accepted, this is just a starting suggestion.</p>
          </div>
          <div style="display:flex;gap:6px">
            <?php for ($i = 0; $i <= 2; $i++): $suggested = $minNextBid + ($i * (float)$auction['min_increment']); ?>
            <button type="button" class="btn btn-ghost btn-sm" onclick="document.querySelector('[name=bid_amount]').value='<?= $suggested ?>'" style="flex:1">
              <?= convertCurrency($suggested) ?>
            </button>
            <?php endfor; ?>
          </div>
        </form>
        <?php endif; ?>
        <div style="display:flex;align-items:center;gap:8px;margin-top:14px;padding-top:14px;border-top:1px solid var(--clr-outline)">
          <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">View in:</span>
          <?php foreach (['PHP','USD','KRW'] as $cur): ?>
          <button type="button" onclick="showCur('<?= $cur ?>')" class="btn btn-ghost btn-sm"><?= $cur ?></button>
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

      <div class="tb-card">
        <div class="tb-card-header" style="background:var(--clr-surface-low)">
          <span>Live Bid Feed</span>
          <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= $bidCount ?> total bids</span>
        </div>
        <?php if (empty($bids)): ?>
        <div style="padding:24px;text-align:center;color:var(--clr-tertiary);font-size:var(--fs-label-md)">No bids yet, be the first!</div>
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

    </div>
  </div>

</main>
<?php renderFooter(); ?>
<script>
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
// Live rates from the server (open.er-api.com)
const LIVE_RATES = <?= json_encode(getLiveCurrencyRates()) ?>;
const SYMS = {PHP:'₱',USD:'$',KRW:'₩'};
const CURRENT_BID = <?= (float)$auction['current_highest_bid'] ?>;
function showCur(c){
  const r = CURRENT_BID * (LIVE_RATES[c] || 1);
  document.getElementById('convertedPrice').textContent = SYMS[c] + (c==='KRW' ? Math.round(r).toLocaleString() : r.toFixed(2)) + ' ' + c;
}
</script>
</body></html>