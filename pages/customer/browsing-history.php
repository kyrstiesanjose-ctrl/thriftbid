<?php
/* ThriftBid - pages/customer/browsing-history.php
   BROWSING_HISTORY was already being populated (every bid inserts a row
   via after_bid_update_auction, and other interaction types are defined
   in the ENUM), but nothing ever surfaced it to the buyer. This is that
   missing page - no schema changes needed, purely additive. */
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin('../login.php');
requireRole('buyer', '../login.php');

$user    = currentUser();
$buyerId = $user['buyer_id'] ?? $user['id'];

$filter = $_GET['type'] ?? 'all';
$validTypes = ['Viewed', 'Added_To_Cart', 'Bid', 'Outbid', 'Won', 'Lost'];
$where = 'bh.buyer_id = ?';
$params = [$buyerId];
if (in_array($filter, $validTypes, true)) {
    $where .= ' AND bh.interaction_type = ?';
    $params[] = $filter;
}

$history = DB::fetchAll(
    "SELECT bh.*, l.title, l.price, l.listing_id, l.is_active,
            (SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image,
            a.auction_id, a.status AS auction_status
     FROM BROWSING_HISTORY bh
     JOIN LISTINGS l ON bh.listing_id = l.listing_id
     LEFT JOIN AUCTIONS a ON l.listing_id = a.listing_id AND a.status = 'Active'
     WHERE $where
     ORDER BY bh.viewed_at DESC
     LIMIT 200",
    $params
);

$grouped = groupByDate($history, 'viewed_at');

$typeMeta = [
    'Viewed'        => ['icon' => 'visibility',     'label' => 'Viewed'],
    'Added_To_Cart' => ['icon' => 'shopping_cart',   'label' => 'Added to Cart'],
    'Bid'           => ['icon' => 'gavel',           'label' => 'Placed a Bid'],
    'Outbid'        => ['icon' => 'trending_down',   'label' => 'Outbid'],
    'Won'           => ['icon' => 'emoji_events',    'label' => 'Won'],
    'Lost'          => ['icon' => 'cancel',          'label' => 'Lost'],
];

renderHead('Browsing History');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar(''); ?>

<main style="flex:1;max-width:900px;margin:0 auto;padding:28px var(--sp-margin-desktop) 80px;width:100%">

  <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-md);font-weight:800;color:var(--clr-text);margin-bottom:6px">Browsing History</h1>
  <p style="font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:20px">What you've viewed, bid on, and tracked recently.</p>

  <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px">
    <a href="?type=all" class="btn btn-sm <?= $filter==='all'?'btn-primary':'btn-ghost' ?>">All</a>
    <?php foreach ($typeMeta as $t => $meta): ?>
    <a href="?type=<?= $t ?>" class="btn btn-sm <?= $filter===$t?'btn-primary':'btn-ghost' ?>"><?= $meta['label'] ?></a>
    <?php endforeach; ?>
  </div>

  <?php if (empty($history)): ?>
  <div style="text-align:center;padding:56px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline)">history</span>
    <p style="margin-top:10px;font-weight:600">No activity yet.</p>
  </div>
  <?php else: ?>
  <?php foreach ($grouped as $dateLabel => $rows): ?>
    <?php renderDateHeader($dateLabel); ?>
    <div style="display:flex;flex-direction:column;gap:8px;margin-bottom:8px">
      <?php foreach ($rows as $row): $meta = $typeMeta[$row['interaction_type']] ?? ['icon'=>'history','label'=>$row['interaction_type']]; ?>
      <a href="<?= $row['auction_id'] ? 'auction_room.php?id='.$row['auction_id'] : 'listing.php?id='.$row['listing_id'] ?>"
         style="display:flex;align-items:center;gap:14px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);padding:12px 16px;text-decoration:none;color:inherit">
        <div style="width:48px;height:48px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0;display:flex;align-items:center;justify-content:center">
          <?php if ($row['cover_image']): ?><img src="<?= htmlspecialchars($row['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline)">checkroom</span><?php endif; ?>
        </div>
        <div style="flex:1;min-width:0">
          <p style="font-weight:600;color:var(--clr-text);white-space:nowrap;overflow:hidden;text-overflow:ellipsis"><?= htmlspecialchars($row['title']) ?></p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= convertCurrency((float)$row['price']) ?><?= !$row['is_active'] ? ' · No longer available' : '' ?></p>
        </div>
        <span class="tb-badge tb-badge-blue" style="display:flex;align-items:center;gap:4px;white-space:nowrap">
          <span class="material-symbols-outlined icon-sm"><?= $meta['icon'] ?></span><?= $meta['label'] ?>
        </span>
        <span style="font-size:11px;color:var(--clr-tertiary);white-space:nowrap"><?= date('h:i A', strtotime($row['viewed_at'])) ?></span>
      </a>
      <?php endforeach; ?>
    </div>
  <?php endforeach; ?>
  <?php endif; ?>

</main>
<?php renderFooter(); ?>
</body></html>