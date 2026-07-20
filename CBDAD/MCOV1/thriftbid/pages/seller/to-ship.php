<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';
requireLogin();
requireRole(['seller','admin']);

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id']; // session row IS the seller row now

$successMsg = $errorMsg = '';

if ($_SERVER['REQUEST_METHOD']==='POST' && isset($_POST['ship_order']) && verifyCsrf($_POST['csrf'] ?? '')) {
    $orderIds   = array_filter(array_map('intval', explode(',', $_POST['order_ids'] ?? '')));
    $courierId  = (int)$_POST['courier_id'];
    $trackingNo = trim($_POST['tracking_number'] ?? '');

    if (empty($orderIds)) {
        $errorMsg = 'Select at least one order to ship.';
    } elseif (!$trackingNo) {
        $errorMsg = 'Please enter a tracking number.';
    } elseif (!$courierId) {
        $errorMsg = 'Please select a courier.';
    } else {
        $placeholders = implode(',', array_fill(0, count($orderIds), '?'));
        $validOrders = DB::fetchAll(
            "SELECT order_id, buyer_id FROM ORDERS WHERE seller_id=? AND order_id IN ($placeholders)",
            array_merge([$sellerId], $orderIds)
        );
        $distinctBuyers = array_unique(array_column($validOrders, 'buyer_id'));

        if (count($validOrders) !== count($orderIds)) {
            $errorMsg = 'One or more selected orders could not be found.';
        } elseif (count($distinctBuyers) > 1) {
            /// Enforces that a single package/tracking number maps exclusively to one unique buyer shipping address.
            $errorMsg = 'Selected orders belong to different buyers, they can\'t share one tracking number.';
        } else {
            try {
                foreach ($orderIds as $oid) {
                    DB::callProc('sp_ship_order', [$oid, $courierId, $trackingNo]);
                }
                $successMsg = count($orderIds) > 1
                    ? count($orderIds) . ' orders marked as shipped under tracking number ' . $trackingNo . '.'
                    : 'Order #' . $orderIds[0] . ' marked as shipped!';
            } catch (\PDOException $e) {
                $errorMsg = str_contains($e->getMessage(), '45000')
                    ? preg_replace('/^.*45000\s*/', '', $e->getMessage())
                    : 'Could not update shipment status.';
            }
        }
    }
}

$subtab = $_GET['subtab'] ?? 'toship';
$validSubtabs = ['toship','transit','completed','refunded'];
if (!in_array($subtab, $validSubtabs, true)) $subtab = 'toship';

//  filter/sort control: "Today"/"Yesterday"/"2 Days Ago" 
$validFilters = ['today','yesterday','2days','oldest','newest'];
$filter = in_array($_GET['filter'] ?? '', $validFilters, true) ? $_GET['filter'] : ($subtab === 'toship' ? 'oldest' : 'newest');
$sortSql = $filter === 'oldest' ? 'ASC' : 'DESC';

// Which date column to filter/sort against depends on the tab.
$dateColByTab = ['toship' => 'o.order_date', 'transit' => 'sh.shipped_date', 'completed' => 'COALESCE(sh.delivered_date, o.order_date)'];
$dateCol = $dateColByTab[$subtab] ?? 'o.order_date';
$quickFilterSql = '';
if (in_array($filter, ['today','yesterday','2days'], true)) {
    $daysAgo = ['today' => 0, 'yesterday' => 1, '2days' => 2][$filter];
    $quickFilterSql = " AND DATE($dateCol) = DATE(DATE_SUB(NOW(), INTERVAL $daysAgo DAY))";
}

$imgSub = '(SELECT image_url FROM LISTING_IMAGES li WHERE li.listing_id=l.listing_id ORDER BY is_primary DESC, image_id ASC LIMIT 1) AS cover_image';

// To Ship: paid, no shipment yet
$toShip = DB::fetchAll(
    "SELECT o.*, l.title, l.listing_id, bu.buyer_id, bu.username AS buyer_name, p.amount_paid, p.payment_method, $imgSub
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER bu   ON o.buyer_id=bu.buyer_id
     JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status='Completed'
     LEFT JOIN SHIPMENTS sh ON o.order_id=sh.order_id
     WHERE o.seller_id=? AND o.status='Preparing' AND sh.shipment_id IS NULL$quickFilterSql
     ORDER BY o.order_date $sortSql",
    [$sellerId]
);

// In Transit: Shipped / Out for Delivery
$inTransit = DB::fetchAll(
    "SELECT o.*, l.title, l.listing_id, bu.username AS buyer_name, sh.tracking_number, sh.status AS ship_status, sh.shipped_date, co.courier_name, $imgSub
     FROM ORDERS o
     JOIN LISTINGS l   ON o.listing_id=l.listing_id
     JOIN BUYER bu     ON o.buyer_id=bu.buyer_id
     JOIN SHIPMENTS sh ON o.order_id=sh.order_id
     JOIN COURIERS co  ON sh.courier_id=co.courier_id
     WHERE o.seller_id=? AND o.status IN ('Shipped','Out for Delivery')$quickFilterSql
     ORDER BY sh.shipped_date $sortSql",
    [$sellerId]
);

// Completed: Delivered
$completedOrders = DB::fetchAll(
    "SELECT o.*, l.title, l.listing_id, bu.username AS buyer_name, p.amount_paid, sh.delivered_date,
            COALESCE(sh.delivered_date, o.order_date) AS group_date, $imgSub
     FROM ORDERS o
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER bu   ON o.buyer_id=bu.buyer_id
     LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status='Completed'
     LEFT JOIN SHIPMENTS sh ON o.order_id=sh.order_id
     WHERE o.seller_id=? AND o.status='Delivered'$quickFilterSql
     ORDER BY COALESCE(sh.delivered_date, o.order_date) $sortSql",
    [$sellerId]
);

// Refunded: this seller's orders where a dispute was resolved with a refund
$refundedOrders = DB::fetchAll(
    "SELECT o.*, l.title, bu.username AS buyer_name, p.amount_paid, $imgSub,
            d.dispute_id, d.reason, d.resolution_type, d.resolved_at
     FROM DISPUTES d
     JOIN ORDERS o   ON d.order_id=o.order_id
     JOIN LISTINGS l ON o.listing_id=l.listing_id
     JOIN BUYER bu   ON o.buyer_id=bu.buyer_id
     LEFT JOIN PAYMENTS p ON o.order_id=p.order_id AND p.payment_status='Completed'
     WHERE d.seller_id=? AND d.status='Resolved' AND d.resolution_type IS NOT NULL
     ORDER BY d.resolved_at DESC",
    [$sellerId]
);

$couriers = DB::fetchAll('SELECT * FROM COURIERS ORDER BY courier_name');

renderHead('Orders');
?>
<body class="flex flex-col" style="height:100vh;overflow:hidden">
<?php renderNavbar('ship', true); ?>
<div class="tb-app-shell">
<?php renderSellerSidebar('ship'); ?>
<main class="tb-main-content">
<div class="tb-page-inner">

  <h1 class="tb-page-title mb-2">Orders</h1>
  <p class="tb-page-subtitle mb-6">Track every order from payment through delivery, including refunds from resolved disputes.</p>

  <?php if ($successMsg): ?><div class="tb-alert tb-alert-success show mb-6"><span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?></div><?php endif; ?>
  <?php if ($errorMsg):   ?><div class="tb-alert tb-alert-error show mb-6"><span class="material-symbols-outlined icon-sm">error</span><?= htmlspecialchars($errorMsg) ?></div><?php endif; ?>

  <div class="tb-tabs mb-6">
    <a href="?subtab=toship"    class="tb-tab-link <?= $subtab==='toship'?'active':'' ?>">To Ship (<?= count($toShip) ?>)</a>
    <a href="?subtab=transit"   class="tb-tab-link <?= $subtab==='transit'?'active':'' ?>">In Transit (<?= count($inTransit) ?>)</a>
    <a href="?subtab=completed" class="tb-tab-link <?= $subtab==='completed'?'active':'' ?>">Completed (<?= count($completedOrders) ?>)</a>
    <a href="?subtab=refunded"  class="tb-tab-link <?= $subtab==='refunded'?'active':'' ?>">Refunded (<?= count($refundedOrders) ?>)</a>
  </div>

  <?php if (in_array($subtab, ['toship','transit','completed'], true)): ?>
  <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px">
    <label style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);font-weight:600">Filter:</label>
    <select onchange="window.location.href='?subtab=<?= $subtab ?>&filter='+this.value" class="tb-select" style="width:auto;min-width:170px">
      <option value="today"     <?= $filter==='today'?'selected':'' ?>>Today</option>
      <option value="yesterday" <?= $filter==='yesterday'?'selected':'' ?>>Yesterday</option>
      <option value="2days"     <?= $filter==='2days'?'selected':'' ?>>2 Days Ago</option>
      <option value="oldest"    <?= $filter==='oldest'?'selected':'' ?>><?= $subtab==='toship' ? 'Oldest First (Priority)' : 'Oldest First' ?></option>
      <option value="newest"    <?= $filter==='newest'?'selected':'' ?>>Newest First</option>
    </select>
    <?php if (in_array($filter, ['today','yesterday','2days'], true)): ?>
    <a href="?subtab=<?= $subtab ?>&filter=<?= $subtab==='toship'?'oldest':'newest' ?>" class="btn btn-ghost btn-sm">Clear</a>
    <?php endif; ?>
  </div>
  <?php endif; ?>

  <?php if ($subtab === 'toship'): ?>
  <div class="tb-alert tb-alert-warning show mb-6">
    <span class="material-symbols-outlined icon-sm">warning</span>
    <div>
      <strong>Shipping Policy:</strong> Failure to ship within 48 hours starts the escalating penalty process (1st: flagged, 2nd: 30-day suspension, 3rd: permanent ban with automatic refund).
    </div>
  </div>

  <?php if (empty($toShip)): ?>
  <div class="tb-card tb-card-body text-center" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">local_shipping</span>
    No orders waiting to be shipped.
  </div>
  <?php else: $dateIdx = 0; foreach (groupByDate($toShip, 'order_date') as $dateLabel => $dateRows): $dateIdx++; renderDateHeader($dateLabel); ?>
  <?php
   
// Groups by buyer within this date to consolidate multiple items into a single shipment and tracking number.

    $toShipByBuyer = [];
    foreach ($dateRows as $o) { $toShipByBuyer[$o['buyer_id']]['buyer_name'] = $o['buyer_name']; $toShipByBuyer[$o['buyer_id']]['items'][] = $o; }
  ?>
  <div class="flex flex-col gap-5 mb-2">
    <?php foreach ($toShipByBuyer as $buyerId => $group): $groupId = 'grp' . $dateIdx . '_' . $buyerId; ?>
    <div class="tb-card">
      <div style="padding:12px 20px;border-bottom:1px solid var(--clr-outline);display:flex;align-items:center;gap:10px;background:var(--clr-surface-low)">
        <span class="material-symbols-outlined icon-sm" style="color:var(--clr-tertiary)">person</span>
        <span style="font-weight:700">Buyer: @<?= htmlspecialchars($group['buyer_name']) ?></span>
        <span class="tb-badge tb-badge-gray"><?= count($group['items']) ?> item<?= count($group['items'])!==1?'s':'' ?> ready</span>
        <?php if (count($group['items']) > 1): ?>
        <span style="font-size:11px;color:var(--clr-tertiary);margin-left:auto">Pack together? Check the ones going in one box and ship them under one tracking number.</span>
        <?php endif; ?>
      </div>
      <div class="tb-card-body" style="display:flex;flex-direction:column;gap:14px">
        <?php foreach ($group['items'] as $o):
          $hoursLeft = 48 - (time() - strtotime($o['order_date'])) / 3600;
        ?>
        <label style="display:flex;gap:14px;align-items:flex-start;cursor:pointer">
          <input type="checkbox" class="ship-item-checkbox" data-group="<?= $groupId ?>" data-order="<?= $o['order_id'] ?>" onchange="recalcShipGroup('<?= $groupId ?>')" style="margin-top:6px;width:18px;height:18px;accent-color:var(--clr-coral);flex-shrink:0">
          <div style="width:64px;height:64px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0">
            <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline-variant);margin:20px">checkroom</span><?php endif; ?>
          </div>
          <div style="flex:1;min-width:220px">
            <h3 style="font-weight:700;font-size:var(--fs-body-md)"><?= htmlspecialchars($o['title']) ?></h3>
            <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:4px">
              Order #<?= $o['order_id'] ?> &bull; Paid: <?= convertCurrency((float)$o['amount_paid']) ?> via <?= htmlspecialchars($o['payment_method']) ?>
            </p>
            <p style="font-size:var(--fs-label-sm);color:<?= $hoursLeft<0?'var(--clr-error)':'var(--clr-tertiary)' ?>">
              Ordered: <?= date('M d, Y H:i', strtotime($o['order_date'])) ?>
              &bull; <?= $hoursLeft<0 ? 'Overdue by '.abs(round($hoursLeft,1)).'h' : round($hoursLeft,1).'h left to ship' ?>
            </p>
          </div>
        </label>
        <?php endforeach; ?>

        <form method="POST" class="flex flex-wrap items-end gap-3" style="border-top:1px solid var(--clr-outline);padding-top:14px" onsubmit="return prepShipGroup('<?= $groupId ?>', this)">
          <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
          <input type="hidden" name="ship_order" value="1">
          <input type="hidden" name="order_ids" id="orderIds_<?= $groupId ?>" value="">
          <div>
            <label class="tb-label">Courier</label>
            <select name="courier_id" class="tb-select" required>
              <option value="">Select Courier</option>
              <?php foreach ($couriers as $c): ?><option value="<?= $c['courier_id'] ?>"><?= htmlspecialchars($c['courier_name']) ?></option><?php endforeach; ?>
            </select>
          </div>
          <div>
            <label class="tb-label">Tracking Number</label>
            <input type="text" name="tracking_number" class="tb-input" placeholder="Tracking number" required>
          </div>
          <button type="submit" class="btn btn-primary btn-sm">
            <span class="material-symbols-outlined icon-sm">local_shipping</span>
            Mark <span id="shipCount_<?= $groupId ?>"><?= count($group['items']) ?></span> Item<span id="shipCountS_<?= $groupId ?>"><?= count($group['items'])!==1?'s':'' ?></span>as Shipped
          </button>
        </form>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endforeach; ?>
  <?php endif; ?>

  <?php elseif ($subtab === 'transit'): ?>
  <?php if (empty($inTransit)): ?>
  <div class="tb-card tb-card-body text-center" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">conveyor_belt</span>
    No orders currently in transit.
  </div>
  <?php else: foreach (groupByDate($inTransit, 'shipped_date') as $dateLabel => $rows): renderDateHeader($dateLabel); ?>
  <div class="flex flex-col gap-3 mb-2">
    <?php foreach ($rows as $o): ?>
    <div class="tb-card tb-card-body" style="display:flex;align-items:center;gap:16px;flex-wrap:wrap">
      <div style="width:56px;height:56px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0">
        <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline-variant);margin:14px">checkroom</span><?php endif; ?>
      </div>
      <div style="flex:1;min-width:200px">
        <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Buyer: @<?= htmlspecialchars($o['buyer_name']) ?> &bull; Order #<?= $o['order_id'] ?></p>
      </div>
      <div style="text-align:right;flex-shrink:0">
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= htmlspecialchars($o['courier_name']) ?></p>
        <p style="font-family:monospace;font-size:var(--fs-label-sm);font-weight:600"><?= htmlspecialchars($o['tracking_number']) ?></p>
      </div>
      <span class="tb-badge tb-badge-blue" style="flex-shrink:0"><?= htmlspecialchars($o['ship_status']) ?></span>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endforeach; ?>
  <?php endif; ?>

  <?php elseif ($subtab === 'completed'): ?>
  <?php if (empty($completedOrders)): ?>
  <div class="tb-card tb-card-body text-center" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">task_alt</span>
    No completed orders yet.
  </div>
  <?php else: foreach (groupByDate($completedOrders, 'group_date') as $dateLabel => $rows): renderDateHeader($dateLabel); ?>
  <div class="flex flex-col gap-3 mb-2">
    <?php foreach ($rows as $o): ?>
    <div class="tb-card tb-card-body" style="display:flex;align-items:center;gap:16px;flex-wrap:wrap">
      <div style="width:56px;height:56px;border-radius:var(--radius-sm);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0">
        <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined icon-sm" style="color:var(--clr-outline-variant);margin:14px">checkroom</span><?php endif; ?>
      </div>
      <div style="flex:1;min-width:200px">
        <p style="font-weight:700;color:var(--clr-text)"><?= htmlspecialchars($o['title']) ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">Buyer: @<?= htmlspecialchars($o['buyer_name']) ?> &bull; Order #<?= $o['order_id'] ?></p>
      </div>
      <p style="font-weight:700;color:var(--clr-success);flex-shrink:0"><?= convertCurrency((float)$o['amount_paid']) ?></p>
      <span class="tb-badge tb-badge-green" style="flex-shrink:0">Delivered</span>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endforeach; ?>
  <?php endif; ?>

  <?php elseif ($subtab === 'refunded'): ?>
  <?php if (empty($refundedOrders)): ?>
  <div class="tb-card tb-card-body text-center" style="color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl mb-3 block" style="color:var(--clr-outline-variant)">currency_exchange</span>
    No refunded orders. This is where you'll see it if a buyer's dispute is resolved in their favor.
  </div>
  <?php else: ?>
  <div class="flex flex-col gap-4">
    <?php foreach ($refundedOrders as $o): ?>
    <div class="tb-card tb-card-body" style="display:flex;gap:16px;align-items:flex-start;flex-wrap:wrap">
      <div style="width:56px;height:56px;border-radius:var(--radius-lg);overflow:hidden;background:var(--clr-surface-mid);flex-shrink:0">
        <?php if ($o['cover_image']): ?><img src="<?= htmlspecialchars($o['cover_image']) ?>" alt="" style="width:100%;height:100%;object-fit:cover"><?php else: ?><span class="material-symbols-outlined" style="color:var(--clr-outline-variant);margin:14px">checkroom</span><?php endif; ?>
      </div>
      <div style="flex:1;min-width:220px">
        <span class="tb-badge tb-badge-red"><?= htmlspecialchars($o['resolution_type']) ?></span>
        <h3 style="font-weight:700;font-size:var(--fs-body-md);margin-top:6px"><?= htmlspecialchars($o['title']) ?></h3>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px">Buyer: @<?= htmlspecialchars($o['buyer_name']) ?> &bull; Order #<?= $o['order_id'] ?></p>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);font-style:italic;margin-top:4px">Dispute reason: <?= htmlspecialchars($o['reason']) ?></p>
      </div>
      <div style="text-align:right;flex-shrink:0">
        <p style="font-weight:800;color:var(--clr-error)">
          <?= convertCurrency((float)$o['amount_paid'] * ($o['resolution_type']==='Partial Refund' ? 0.5 : 1)) ?> refunded
        </p>
        <p style="font-size:11px;color:var(--clr-tertiary);margin-top:2px">Resolved: <?= date('M d, Y', strtotime($o['resolved_at'])) ?></p>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>
  <?php endif; ?>

</div>
</main>
</div>
<?php if ($subtab === 'toship' && !empty($toShip)): ?>
<script>

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll('.ship-item-checkbox').forEach(cb => cb.checked = false);
  <?php foreach (array_keys($toShipByBuyer ?? []) as $buyerId): ?>
    recalcShipGroup('grp1_<?= $buyerId ?>'); 
  <?php endforeach; ?>
  
  document.querySelectorAll('form[onsubmit*="prepShipGroup"]').forEach(form => {
    const match = form.getAttribute('onsubmit').match(/'([^']+)'/);
    if(match) recalcShipGroup(match[1]);
  });
});

function recalcShipGroup(groupId) {
  const checked = document.querySelectorAll(`.ship-item-checkbox[data-group="${groupId}"]:checked`);
  const n = checked.length;
  document.getElementById('shipCount_' + groupId).textContent = n;
  document.getElementById('shipCountS_' + groupId).textContent = n !== 1 ? 's' : '';
  const form = document.getElementById('orderIds_' + groupId)?.closest('form');
  if (form) form.querySelector('button[type="submit"]').disabled = n === 0;
}
function prepShipGroup(groupId, formEl) {
  const checked = Array.from(document.querySelectorAll(`.ship-item-checkbox[data-group="${groupId}"]:checked`));
  if (!checked.length) { alert('Select at least one item to ship.'); return false; }
  document.getElementById('orderIds_' + groupId).value = checked.map(cb => cb.dataset.order).join(',');
  return true;
}
</script>
<?php endif; ?>
</body></html>