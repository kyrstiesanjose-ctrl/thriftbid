<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('/pages/login.php');
requireRole(['seller','admin'],'/pages/login.php');

$user     = currentUser();
$seller   = DB::fetch('SELECT seller_id FROM SELLER WHERE user_id=?', [$user['user_id']]);
$sellerId = $seller['seller_id'] ?? 0;
 
$tab     = $_GET['tab'] ?? 'active';
$created = isset($_GET['created']);
 
// Close auction manually
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['close_auction'])) {
    $aid     = (int)$_POST['auction_id'];
    $auction = DB::fetch(
        'SELECT a.*,l.title,l.listing_id FROM AUCTIONS a
         JOIN LISTINGS l ON a.listing_id=l.listing_id
         WHERE a.auction_id=? AND l.seller_id=?',
        [$aid, $sellerId]
    );
    if ($auction) {
        DB::query('UPDATE AUCTIONS SET status="Closed" WHERE auction_id=?', [$aid]);
        $winner = DB::fetch(
            'SELECT b.buyer_id,b.bid_amount,u.user_id,u.username
             FROM BIDDINGS b
             JOIN BUYER by2 ON b.buyer_id=by2.buyer_id
             JOIN USERS u   ON by2.user_id=u.user_id
             WHERE b.auction_id=? ORDER BY b.bid_amount DESC LIMIT 1',
            [$aid]
        );
        if ($winner) {
            $oid = DB::insert(
                'INSERT INTO ORDERS (listing_id,buyer_id,seller_id) VALUES (?,?,?)',
                [$auction['listing_id'], $winner['buyer_id'], $sellerId]
            );
            DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
                [$winner['user_id'], 'You Won the Auction!',
                 'Congratulations! You won "'.htmlspecialchars($auction['title']).'" with a bid of '.convertCurrency((float)$winner['bid_amount']).'. Please proceed to checkout.',
                 'AUCTION']);
            DB::query('INSERT INTO NOTIFICATIONS (user_id,title,message,notification_type) VALUES (?,?,?,?)',
                [$user['user_id'], 'Auction Closed',
                 'Your auction for "'.$auction['title'].'" ended. Winner: @'.$winner['username'].'.',
                 'AUCTION']);
        }
    }
   
    header('Location: active-auctions.php?tab=closed');
    exit;
}
 
$activeAuctions = DB::fetchAll(
    'SELECT a.*,l.title,l.image_url,l.item_condition,l.listing_id,c.name as cat_name,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id) as bid_count
     FROM AUCTIONS a
     JOIN LISTINGS l   ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     WHERE l.seller_id=? AND a.status="Active"
     ORDER BY a.end_time ASC',
    [$sellerId]
);
$closedAuctions = DB::fetchAll(
    'SELECT a.*,l.title,l.image_url,c.name as cat_name,
            (SELECT COUNT(*) FROM BIDDINGS WHERE auction_id=a.auction_id) as bid_count
     FROM AUCTIONS a
     JOIN LISTINGS l   ON a.listing_id=l.listing_id
     JOIN CATEGORIES c ON l.category_id=c.category_id
     WHERE l.seller_id=? AND a.status="Closed"
     ORDER BY a.end_time DESC LIMIT 30',
    [$sellerId]
);
$fixedListings = DB::fetchAll(
    'SELECT l.*,c.name as cat_name
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id=c.category_id
     WHERE l.seller_id=? AND l.is_active=1
       AND l.listing_id NOT IN (SELECT listing_id FROM AUCTIONS)
     ORDER BY l.created_at DESC',
    [$sellerId]
);
 
renderHead('My Listings');
?>
<body style="height:100vh;overflow:hidden;display:flex;flex-direction:column">
<?php renderNavbar('auctions', true); ?>
<div style="display:flex;flex:1;overflow:hidden">
<?php renderSellerSidebar('auctions'); ?>
<main style="flex:1;overflow-y:auto;background:var(--clr-bg)">
<div style="max-width:1100px;margin:0 auto;padding:32px 40px 80px">
 
  <!-- Header -->
  <div style="display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:28px">
    <div>
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:700;color:var(--clr-text)">My Listings &amp; Auctions</h1>
      <p style="color:var(--clr-tertiary);margin-top:4px">Manage your active auctions, fixed-price items, and closed sales.</p>
    </div>
  
    <a href="create-listing.php" class="btn btn-primary">
      <span class="material-symbols-outlined icon-sm">add</span>New Listing
    </a>
  </div>
 
  <?php if ($created): ?>
  <div class="tb-alert tb-alert-success show" style="margin-bottom:16px">
    <span class="material-symbols-outlined icon-sm">check_circle</span>Listing published successfully!
  </div>
  <?php endif; ?>
 
  <!-- Tabs -->
  <div class="tb-tabs" style="margin-bottom:24px">
    <a href="?tab=active"  class="tb-tab-link <?= $tab==='active'?'active':'' ?>">Active Auctions (<?= count($activeAuctions) ?>)</a>
    <a href="?tab=fixed"   class="tb-tab-link <?= $tab==='fixed'?'active':'' ?>">Fixed Price (<?= count($fixedListings) ?>)</a>
    <a href="?tab=closed"  class="tb-tab-link <?= $tab==='closed'?'active':'' ?>">Closed (<?= count($closedAuctions) ?>)</a>
  </div>
 
  <!--  ACTIVE AUCTIONS  -->
  <?php if ($tab === 'active'): ?>
  <?php if (empty($activeAuctions)): ?>
  <div style="text-align:center;padding:64px;color:var(--clr-tertiary);background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm)">
    <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">gavel</span>
    <p style="font-weight:700;font-size:var(--fs-headline-sm)">No active auctions</p>
    <p style="margin-top:6px">Create a listing to start selling.</p>
    <!-- FIXED: relative path -->
    <a href="create-listing.php" class="btn btn-primary" style="margin-top:16px">Create Listing</a>
  </div>
  <?php else: ?>
  <div style="display:flex;flex-direction:column;gap:12px">
    <?php foreach ($activeAuctions as $a):
      $isUrgent = (strtotime($a['end_time']) - time()) < 3600;
    ?>
    <div class="tb-card" style="display:flex;align-items:center;gap:20px;padding:18px 20px">
      <!-- Thumbnail -->
      <div style="width:72px;height:72px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
        <?php if ($a['image_url']): ?>
          <img src="<?= htmlspecialchars($a['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover">
        <?php else: ?>
          <span class="material-symbols-outlined" style="color:var(--clr-outline)">checkroom</span>
        <?php endif; ?>
      </div>
 
      <!-- Info -->
      <div style="flex:1;min-width:0">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px">
          <span class="tb-badge <?= $isUrgent ? 'tb-badge-red' : 'tb-badge-active' ?>"><?= $isUrgent ? 'Ending Soon' : 'Active' ?></span>
          <span class="tb-badge tb-badge-gray"><?= htmlspecialchars($a['cat_name']) ?></span>
        </div>
        <h3 style="font-weight:700;font-size:var(--fs-body-md);color:var(--clr-text);overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($a['title']) ?></h3>
        <div style="display:flex;flex-wrap:wrap;gap:14px;margin-top:6px;font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
          <span>Highest Bid: <strong style="color:var(--clr-text)"><?= convertCurrency((float)$a['current_highest_bid']) ?></strong></span>
          <span><?= $a['bid_count'] ?> bid<?= $a['bid_count'] !== 1 ? 's' : '' ?></span>
          <span style="color:<?= $isUrgent ? 'var(--clr-error)' : 'inherit' ?>">Ends: <?= formatTimeLeft($a['end_time']) ?></span>
          <span>Min increment: <?= convertCurrency((float)$a['min_increment']) ?></span>
        </div>
      </div>
 
      <!-- Actions -->
      <div style="display:flex;flex-direction:column;gap:8px;flex-shrink:0;min-width:140px">
        <a href="../customer/auction_room.php?id=<?= $a['auction_id'] ?>" class="btn btn-outline btn-sm">View Live Room</a>
        <a href="edit-listing.php?id=<?= $a['listing_id'] ?>" class="btn btn-ghost btn-sm" style="text-align:center">Edit Details</a>
        <form method="POST" onsubmit="return confirm('Close this auction and declare a winner?')">
          <input type="hidden" name="close_auction" value="1">
          <input type="hidden" name="auction_id" value="<?= $a['auction_id'] ?>">
          <button type="submit" class="btn btn-ghost btn-sm" style="width:100%">Close Now</button>
        </form>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>
 
  <!--  FIXED PRICE  -->
  <?php elseif ($tab === 'fixed'): ?>
  <?php if (empty($fixedListings)): ?>
  <div style="text-align:center;padding:64px;color:var(--clr-tertiary);background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm)">
    <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">sell</span>
    <p style="font-weight:700">No fixed-price listings</p>
   
    <a href="create-listing.php" class="btn btn-primary" style="margin-top:16px">Create Listing</a>
  </div>
  <?php else: ?>
  <div class="tb-table-wrapper">
    <table class="tb-table">
      <thead>
        <tr>
          <th>Item</th><th>Category</th><th>Condition</th><th>Price</th><th>Listed</th><th>Action</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($fixedListings as $l): ?>
        <tr>
          <td>
            <div style="display:flex;align-items:center;gap:12px">
              <div style="width:44px;height:44px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
                <?php if ($l['image_url']): ?>
                  <img src="<?= htmlspecialchars($l['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover">
                <?php else: ?>
                  <span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span>
                <?php endif; ?>
              </div>
              <span style="font-weight:600;color:var(--clr-text)"><?= htmlspecialchars($l['title']) ?></span>
            </div>
          </td>
          <td><span class="tb-badge tb-badge-gray"><?= htmlspecialchars($l['cat_name']) ?></span></td>
          <td style="color:var(--clr-tertiary)"><?= htmlspecialchars($l['item_condition']) ?></td>
          <td style="font-weight:700"><?= convertCurrency((float)$l['price']) ?></td>
          <td style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)"><?= date('M d, Y', strtotime($l['created_at'])) ?></td>
          <td>
          
            <a href="edit-listing.php?id=<?= $l['listing_id'] ?>" class="btn btn-outline btn-sm">Edit Listing</a>
          </td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
 
  <!--  CLOSED  -->
  <?php elseif ($tab === 'closed'): ?>
  <?php if (empty($closedAuctions)): ?>
  <div style="text-align:center;padding:64px;color:var(--clr-tertiary)">No closed auctions yet.</div>
  <?php else: ?>
  <div class="tb-table-wrapper">
    <table class="tb-table">
      <thead>
        <tr><th>Item</th><th>Category</th><th>Final Bid</th><th>Bids</th><th>Closed</th></tr>
      </thead>
      <tbody>
        <?php foreach ($closedAuctions as $a): ?>
        <tr>
          <td>
            <div style="display:flex;align-items:center;gap:10px">
              <div style="width:36px;height:36px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
                <?php if ($a['image_url']): ?>
                  <img src="<?= htmlspecialchars($a['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover">
                <?php else: ?>
                  <span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span>
                <?php endif; ?>
              </div>
              <span style="font-weight:600"><?= htmlspecialchars($a['title']) ?></span>
            </div>
          </td>
          <td><span class="tb-badge tb-badge-gray"><?= htmlspecialchars($a['cat_name']) ?></span></td>
          <td style="font-weight:700;color:var(--clr-coral)"><?= convertCurrency((float)$a['current_highest_bid']) ?></td>
          <td style="color:var(--clr-tertiary)"><?= $a['bid_count'] ?></td>
          <td style="color:var(--clr-tertiary);font-size:var(--fs-label-sm)"><?= date('M d, Y', strtotime($a['end_time'])) ?></td>
        </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
  <?php endif; ?>
  <?php endif; ?>
 
</div>
</main>
</div>
</body></html>