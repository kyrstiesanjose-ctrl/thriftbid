<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('../../pages/login.php');
requireRole(['seller','admin'], '../../pages/login.php');

$user      = currentUser();
$seller    = DB::fetch('SELECT seller_id FROM SELLER WHERE user_id=?', [$user['user_id']]);
$sellerId  = $seller['seller_id'] ?? 0;
$listingId = (int)($_GET['id'] ?? 0);

if (!$listingId) { header('Location: active-auctions.php?tab=fixed'); exit; }

// Fetch listing 
$listing = DB::fetch(
    'SELECT l.*, c.name as cat_name,
            a.auction_id, a.start_bid, a.min_increment, a.end_time,
            a.current_highest_bid, a.status as auction_status, a.listing_type
     FROM LISTINGS l
     JOIN CATEGORIES c ON l.category_id = c.category_id
     LEFT JOIN AUCTIONS a ON l.listing_id = a.listing_id
     WHERE l.listing_id = ? AND l.seller_id = ?',
    [$listingId, $sellerId]
);
if (!$listing) { header('Location: active-auctions.php?tab=fixed'); exit; }

$categories = DB::fetchAll('SELECT * FROM CATEGORIES ORDER BY category_id');
$hasAuction = !empty($listing['auction_id']);
$hasBids    = $hasAuction && DB::fetch('SELECT COUNT(*) c FROM BIDDINGS WHERE auction_id=?', [$listing['auction_id']])['c'] > 0;

$successMsg = '';
$errors     = [];

// Handle update
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save'])) {
    $title       = trim($_POST['title'] ?? '');
    $description = trim($_POST['description'] ?? '');
    $catId       = (int)($_POST['category_id'] ?? 0);
    $condition   = $_POST['item_condition'] ?? 'Good';
    $imageUrl    = trim($_POST['image_url'] ?? '');
    $price       = (float)($_POST['price'] ?? 0);
    $isActive    = isset($_POST['is_active']) ? 1 : 0;

    if (!$title)  $errors[] = 'Item title is required.';
    if (!$catId)  $errors[] = 'Please select a category.';
    if (!$hasAuction && $price <= 0) $errors[] = 'Enter a valid price.';

    if (empty($errors)) {
        DB::query(
            'UPDATE LISTINGS SET title=?, description=?, category_id=?, item_condition=?, image_url=?, price=?, is_active=? WHERE listing_id=? AND seller_id=?',
            [$title, $description ?: null, $catId, $condition, $imageUrl ?: null, $hasAuction ? $listing['price'] : $price, $isActive, $listingId, $sellerId]
        );
        // Refresh
        $listing = DB::fetch(
            'SELECT l.*, c.name as cat_name, a.auction_id, a.start_bid, a.min_increment, a.end_time, a.current_highest_bid, a.status as auction_status, a.listing_type
             FROM LISTINGS l JOIN CATEGORIES c ON l.category_id=c.category_id LEFT JOIN AUCTIONS a ON l.listing_id=a.listing_id WHERE l.listing_id=? AND l.seller_id=?',
            [$listingId, $sellerId]
        );
        $successMsg = 'Listing updated successfully.';
    }
}

// Handle deactivate / reactivate
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['toggle_active'])) {
    $newActive = $listing['is_active'] ? 0 : 1;
    DB::query('UPDATE LISTINGS SET is_active=? WHERE listing_id=? AND seller_id=?', [$newActive, $listingId, $sellerId]);
    header('Location: edit-listing.php?id='.$listingId.'&updated=1'); exit;
}

if (isset($_GET['updated'])) $successMsg = 'Listing updated.';

renderHead('Edit Listing — ' . htmlspecialchars($listing['title']));
?>
<body style="height:100vh;overflow:hidden;display:flex;flex-direction:column">
<?php renderNavbar('auctions', true); ?>
<div style="display:flex;flex:1;overflow:hidden">
<?php renderSellerSidebar('auctions'); ?>
<main style="flex:1;overflow-y:auto;background:var(--clr-bg)">
<div style="max-width:860px;margin:0 auto;padding:32px 40px 80px">

  <!-- Back -->
  <a href="active-auctions.php?tab=<?= $hasAuction ? 'active' : 'fixed' ?>" style="display:inline-flex;align-items:center;gap:6px;font-size:var(--fs-label-md);color:var(--clr-tertiary);margin-bottom:20px;text-decoration:none">
    <span class="material-symbols-outlined icon-sm">arrow_back</span>Back to My Listings
  </a>

  <!-- Page title row -->
  <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:16px;margin-bottom:24px;flex-wrap:wrap">
    <div>
      <h1 style="font-family:'Hanken Grotesk',sans-serif;font-size:var(--fs-headline-lg);font-weight:700;color:var(--clr-text)">Edit Listing</h1>
      <p style="color:var(--clr-tertiary);margin-top:4px">Update your listing details below.</p>
    </div>
    <!-- Status badge + toggle -->
    <div style="display:flex;align-items:center;gap:10px">
      <span class="tb-badge <?= $listing['is_active'] ? 'tb-badge-active' : 'tb-badge-gray' ?>">
        <?= $listing['is_active'] ? 'Active' : 'Inactive' ?>
      </span>
      <form method="POST">
        <input type="hidden" name="toggle_active" value="1">
        <button type="submit" class="btn btn-ghost btn-sm">
          <?= $listing['is_active'] ? 'Deactivate' : 'Reactivate' ?>
        </button>
      </form>
    </div>
  </div>

  <?php if ($successMsg): ?>
  <div class="tb-alert tb-alert-success show" style="margin-bottom:20px">
    <span class="material-symbols-outlined icon-sm">check_circle</span><?= htmlspecialchars($successMsg) ?>
  </div>
  <?php endif; ?>
  <?php if ($errors): ?>
  <div class="tb-alert tb-alert-error show" style="margin-bottom:20px">
    <span class="material-symbols-outlined icon-sm">error</span>
    <div><?php foreach ($errors as $e): ?><p><?= htmlspecialchars($e) ?></p><?php endforeach; ?></div>
  </div>
  <?php endif; ?>

  <div style="display:flex;flex-direction:column;gap:20px">

    <!-- Listing type / auction info banner -->
    <?php if ($hasAuction): ?>
    <div style="background:<?= ($listing['auction_status']==='Active') ? 'rgba(255,107,107,0.06)' : 'var(--clr-surface-low)' ?>;border:1px solid <?= ($listing['auction_status']==='Active') ? 'rgba(255,107,107,0.25)' : 'var(--clr-outline)' ?>;border-radius:var(--radius-sm);padding:16px 20px">
      <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
        <span class="tb-badge <?= $listing['auction_status']==='Active' ? 'tb-badge-live' : 'tb-badge-ended' ?>">
          <?= $listing['listing_type'] === 'live' ? 'Live Auction' : 'Auction' ?> — <?= ucfirst($listing['auction_status']) ?>
        </span>
        <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)">
          Highest Bid: <strong style="color:var(--clr-text)">₱<?= number_format((float)$listing['current_highest_bid'],2) ?></strong>
          &bull; Ends: <strong><?= $listing['end_time'] ? date('M d, Y h:i A', strtotime($listing['end_time'])) : '—' ?></strong>
        </span>
      </div>
      <?php if ($hasBids): ?>
      <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:8px">
        <span class="material-symbols-outlined icon-sm" style="color:var(--clr-warn)">info</span>
        This auction has active bids. Title, description, and image can still be edited. Price and type cannot be changed.
      </p>
      <?php endif; ?>
    </div>
    <?php endif; ?>

    <!-- Image preview -->
    <?php if ($listing['image_url']): ?>
    <div class="tb-card" style="overflow:hidden">
      <div class="tb-card-header">Current Image</div>
      <div style="padding:16px 20px;display:flex;align-items:center;gap:16px">
        <div style="width:100px;height:100px;border-radius:var(--radius-sm);overflow:hidden;border:1px solid var(--clr-outline);flex-shrink:0">
          <img src="<?= htmlspecialchars($listing['image_url']) ?>" alt="" style="width:100%;height:100%;object-fit:cover">
        </div>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);word-break:break-all"><?= htmlspecialchars($listing['image_url']) ?></p>
      </div>
    </div>
    <?php endif; ?>

    <!-- Edit form -->
    <div class="tb-card">
      <div class="tb-card-header">
        <span style="font-family:'Hanken Grotesk',sans-serif;font-weight:700">Listing Details</span>
      </div>
      <div style="padding:20px">
        <form method="POST" style="display:flex;flex-direction:column;gap:18px">
          <input type="hidden" name="save" value="1">

          <!-- Title -->
          <div class="tb-form-group">
            <label class="tb-label">Item Title <span class="req">*</span></label>
            <input class="tb-input" name="title" type="text" value="<?= htmlspecialchars($listing['title']) ?>" maxlength="200" required>
          </div>

          <!-- Description -->
          <div class="tb-form-group">
            <label class="tb-label">Description</label>
            <textarea class="tb-textarea" name="description" rows="4" placeholder="Describe the item..."><?= htmlspecialchars($listing['description'] ?? '') ?></textarea>
          </div>

          <!-- Category + Condition row -->
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
            <div class="tb-form-group">
              <label class="tb-label">Category <span class="req">*</span></label>
              <select class="tb-select" name="category_id" required>
                <?php foreach ($categories as $c): ?>
                <option value="<?= $c['category_id'] ?>" <?= $c['category_id']==$listing['category_id']?'selected':'' ?>><?= htmlspecialchars($c['name']) ?></option>
                <?php endforeach; ?>
              </select>
            </div>
            <div class="tb-form-group">
              <label class="tb-label">Item Condition <span class="req">*</span></label>
              <select class="tb-select" name="item_condition">
                <?php foreach (['Like New','Very Good','Good','Fair','For Parts'] as $cond): ?>
                <option value="<?= $cond ?>" <?= $listing['item_condition']===$cond?'selected':'' ?>><?= $cond ?></option>
                <?php endforeach; ?>
              </select>
            </div>
          </div>

          <!-- Price (only editable for fixed-price listings) -->
          <?php if (!$hasAuction): ?>
          <div class="tb-form-group">
            <label class="tb-label">Price (₱) <span class="req">*</span></label>
            <div style="position:relative;max-width:200px">
              <span style="position:absolute;left:12px;top:50%;transform:translateY(-50%);font-weight:700;color:var(--clr-tertiary)">₱</span>
              <input class="tb-input" name="price" type="number" min="1" step="0.01" value="<?= $listing['price'] ?>" style="padding-left:28px" required>
            </div>
          </div>
          <?php else: ?>
          <div class="tb-form-group">
            <label class="tb-label">Starting Bid / Current Price</label>
            <div style="padding:10px 14px;background:var(--clr-surface-low);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);font-weight:700;color:var(--clr-tertiary);max-width:200px">
              ₱<?= number_format((float)$listing['price'],2) ?> <span style="font-weight:400;font-size:var(--fs-label-sm)">(cannot change — auction live)</span>
            </div>
          </div>
          <?php endif; ?>

          <!-- Image URL -->
          <div class="tb-form-group">
            <label class="tb-label">Image URL <span class="opt">(optional)</span></label>
            <input class="tb-input" name="image_url" type="url" placeholder="https://..." value="<?= htmlspecialchars($listing['image_url'] ?? '') ?>">
            <p class="tb-hint">Paste a direct image link or leave blank for placeholder.</p>
          </div>

          <!-- Save buttons -->
          <div style="display:flex;justify-content:space-between;align-items:center;padding-top:8px">
            <a href="active-auctions.php?tab=<?= $hasAuction ? 'active' : 'fixed' ?>" class="btn btn-ghost">Cancel</a>
            <button type="submit" class="btn btn-primary">
              <span class="material-symbols-outlined icon-sm">save</span>Save Changes
            </button>
          </div>

        </form>
      </div>
    </div>

    <!-- Danger zone -->
    <?php if (!$hasBids): ?>
    <div class="tb-card" style="border-color:var(--clr-error-bg)">
      <div class="tb-card-header" style="background:var(--clr-error-bg)">
        <span style="font-weight:700;color:var(--clr-error)">Danger Zone</span>
      </div>
      <div style="padding:16px 20px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px">
        <div>
          <p style="font-weight:600;color:var(--clr-text);font-size:var(--fs-label-md)">Deactivate this listing</p>
          <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:2px">Hidden from buyers. You can reactivate it anytime.</p>
        </div>
        <form method="POST" onsubmit="return confirm('<?= $listing['is_active'] ? 'Deactivate this listing?' : 'Reactivate this listing?' ?>')">
          <input type="hidden" name="toggle_active" value="1">
          <button type="submit" class="btn btn-danger btn-sm">
            <?= $listing['is_active'] ? 'Deactivate Listing' : 'Reactivate Listing' ?>
          </button>
        </form>
      </div>
    </div>
    <?php endif; ?>

  </div><!-- /flex col -->
</div>
</main>
</div>
</body></html>
