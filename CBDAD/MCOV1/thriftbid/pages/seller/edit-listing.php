<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/currency.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('../../pages/login.php');
requireRole(['seller','admin'], '../../pages/login.php');

$user      = currentUser();
$sellerId  = $user['seller_id'] ?? $user['id']; // session row IS the seller row now
$listingId = (int)($_GET['id'] ?? 0);

if (!$listingId) { header('Location: active-auctions.php?tab=fixed'); exit; }

function loadListing(int $listingId, int $sellerId): array|false {
    return DB::fetch(
        'SELECT l.*, c.name AS cat_name, b.brand_name, pl.brand_id, pl.tier,
                a.auction_id, a.start_bid, a.min_increment, a.end_time, a.current_highest_bid, a.status AS auction_status
         FROM LISTINGS l
         JOIN CATEGORIES c ON l.category_id = c.category_id
         JOIN PRODUCT_LINES pl ON l.product_line_id = pl.product_line_id
         JOIN BRANDS b ON pl.brand_id = b.brand_id
         LEFT JOIN AUCTIONS a ON l.listing_id = a.listing_id AND a.status = \'Active\'
         WHERE l.listing_id = ? AND l.seller_id = ? AND l.deleted_at IS NULL',
        [$listingId, $sellerId]
    );
}

$listing = loadListing($listingId, $sellerId);
if (!$listing) { header('Location: active-auctions.php?tab=fixed'); exit; }

$categories = DB::fetchAll('SELECT * FROM CATEGORIES ORDER BY name');
$sizes      = DB::fetchAll('SELECT * FROM CATEGORY_SIZES WHERE category_id=? ORDER BY size_id', [$listing['category_id']]);
$images     = DB::fetchAll('SELECT * FROM LISTING_IMAGES WHERE listing_id=? ORDER BY is_primary DESC, image_id ASC', [$listingId]);

$hasAuction = !empty($listing['auction_id']);
$hasBids    = $hasAuction && (DB::fetch('SELECT COUNT(*) c FROM BIDDINGS WHERE auction_id=? AND is_deleted=0', [$listing['auction_id']])['c'] ?? 0) > 0;
$hasSold    = (bool) DB::fetch('SELECT order_id FROM ORDERS WHERE listing_id=? LIMIT 1', [$listingId]);

const UPLOAD_DIR_EDIT = __DIR__ . '/../../uploads/listings/';
const UPLOAD_URL_EDIT = '/uploads/listings/';

function saveEditPhoto(array $file): ?string {
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) return null;
    if ($file['error'] !== UPLOAD_ERR_OK) return null;
    $allowed = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    $mime = mime_content_type($file['tmp_name']);
    if (!isset($allowed[$mime]) || $file['size'] > 6 * 1024 * 1024) return null;
    if (!is_dir(UPLOAD_DIR_EDIT)) mkdir(UPLOAD_DIR_EDIT, 0775, true);
    $name = bin2hex(random_bytes(12)) . '.' . $allowed[$mime];
    return move_uploaded_file($file['tmp_name'], UPLOAD_DIR_EDIT . $name) ? UPLOAD_URL_EDIT . $name : null;
}

$successMsg = '';
$errors     = [];

// ------------------------------------------------------------
// Save details
// ------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save'])) {
    $title       = trim($_POST['title'] ?? '');
    $description = trim($_POST['description'] ?? '');
    $catId       = $hasBids ? $listing['category_id'] : (int)($_POST['category_id'] ?? 0);
    $sizeId      = $hasBids ? $listing['size_id']     : (int)($_POST['size_id'] ?? 0);
    $condition   = $_POST['condition_grade'] ?? '';
    $color       = trim($_POST['color'] ?? '');
    $material    = trim($_POST['material'] ?? '');
    $targetGender= $_POST['target_gender'] ?? '';
    $madeIn      = trim($_POST['made_in'] ?? '');
    $price       = (float)($_POST['price'] ?? 0);
    $originalPrice = (float)($_POST['original_price'] ?? 0);
    $isActive    = isset($_POST['is_active']) ? 1 : 0;
    $conditions  = ['Brand New','Like New','Lightly Used','Well Used','Heavily Used'];

    if (!$title) $errors[] = 'Item title is required.';
    if (!$catId) $errors[] = 'Please select a category.';
    if (!$sizeId) $errors[] = 'Please select a size.';
    if (!in_array($condition, $conditions, true)) $errors[] = 'Please select a valid condition.';
    if (!$hasAuction && $price <= 0) $errors[] = 'Enter a valid price.';

    if (empty($errors)) {
        DB::query(
            'UPDATE LISTINGS SET title=?, description=?, category_id=?, size_id=?, condition_grade=?, color=?, material=?, target_gender=?, made_in=?, price=?, original_price=?, is_active=? WHERE listing_id=? AND seller_id=?',
            [$title, $description ?: null, $catId, $sizeId, $condition, $color ?: null, $material ?: null, $targetGender ?: null, $madeIn ?: null,
             $hasAuction ? $listing['price'] : $price, $originalPrice > 0 ? $originalPrice : null, $isActive, $listingId, $sellerId]
        );

        // New photos (appended, not replacing existing ones)
        if (!empty($_FILES['new_photos']['tmp_name'][0] ?? '')) {
            foreach ($_FILES['new_photos']['tmp_name'] as $i => $tmp) {
                if ($tmp === '') continue;
                $url = saveEditPhoto(['tmp_name'=>$tmp,'error'=>$_FILES['new_photos']['error'][$i],'size'=>$_FILES['new_photos']['size'][$i]]);
                if ($url) DB::query('INSERT INTO LISTING_IMAGES (listing_id, image_url, is_primary) VALUES (?,?,0)', [$listingId, $url]);
            }
        }

        $listing = loadListing($listingId, $sellerId);
        $images  = DB::fetchAll('SELECT * FROM LISTING_IMAGES WHERE listing_id=? ORDER BY is_primary DESC, image_id ASC', [$listingId]);
        $successMsg = 'Listing updated successfully.';
    }
}

// Delete a single photo (must always keep at least 1)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_photo'])) {
    $imgId = (int)$_POST['image_id'];
    if (count($images) > 1) {
        DB::query('DELETE FROM LISTING_IMAGES WHERE image_id=? AND listing_id=?', [$imgId, $listingId]);
        $images = DB::fetchAll('SELECT * FROM LISTING_IMAGES WHERE listing_id=? ORDER BY is_primary DESC, image_id ASC', [$listingId]);
        if (!empty($images) && !$images[0]['is_primary']) {
            DB::query('UPDATE LISTING_IMAGES SET is_primary=1 WHERE image_id=?', [$images[0]['image_id']]);
        }
    } else {
        $errors[] = 'A listing must have at least one photo.';
    }
}

// Make a photo the primary/cover photo
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['make_primary'])) {
    $imgId = (int)$_POST['image_id'];
    DB::query('UPDATE LISTING_IMAGES SET is_primary=0 WHERE listing_id=?', [$listingId]);
    DB::query('UPDATE LISTING_IMAGES SET is_primary=1 WHERE image_id=? AND listing_id=?', [$imgId, $listingId]);
    $images = DB::fetchAll('SELECT * FROM LISTING_IMAGES WHERE listing_id=? ORDER BY is_primary DESC, image_id ASC', [$listingId]);
}

// Deactivate / reactivate
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['toggle_active'])) {
    $newActive = $listing['is_active'] ? 0 : 1;
    DB::query('UPDATE LISTINGS SET is_active=? WHERE listing_id=? AND seller_id=?', [$newActive, $listingId, $sellerId]);
    header('Location: edit-listing.php?id='.$listingId.'&updated=1'); exit;
}

// Soft-delete (archiving rule: never hard-delete a listing that might be
// referenced by past ORDERS, set deleted_at instead)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_listing'])) {
    if ($hasBids) {
        $errors[] = 'Cannot delete a listing with active bids.';
    } else {
        DB::callProc('sp_soft_delete_listing', [$listingId, $sellerId]);
        header('Location: active-auctions.php?tab=fixed&deleted=1'); exit;
    }
}

if (isset($_GET['updated'])) $successMsg = 'Listing updated.';

renderHead('Edit Listing - ' . htmlspecialchars($listing['title']));
?>
<body class="flex flex-col h-screen overflow-hidden">
<?php renderNavbar('auctions', true); ?>

<div class="flex flex-1 w-full overflow-hidden">
<?php renderSellerSidebar('auctions'); ?>

<main class="flex-1 overflow-auto bg-background">
  <div class="max-w-[1400px] mx-auto px-6 py-8">

    <a href="active-auctions.php?tab=<?= $hasAuction ? 'active' : 'fixed' ?>" class="inline-flex items-center gap-1 text-sm text-tertiary mb-5">
      <span class="material-symbols-outlined text-sm">arrow_back</span>Back to My Listings
    </a>

    <header class="flex items-start justify-between gap-4 flex-wrap mb-6">
      <div>
        <h1 class="text-3xl font-bold text-on-surface" style="font-family:'Hanken Grotesk',sans-serif">Edit Listing</h1>
        <p class="text-tertiary mt-1">Update your listing details below.</p>
      </div>
      <div class="flex items-center gap-2">
        <span class="px-3 py-1 rounded-full text-xs font-bold <?= $listing['is_active'] ? 'bg-green-600 text-white' : 'bg-surface-container text-tertiary' ?>">
          <?= $listing['is_active'] ? 'ACTIVE' : 'INACTIVE' ?>
        </span>
        <form method="POST">
          <input type="hidden" name="toggle_active" value="1">
          <button type="submit" class="btn btn-ghost btn-sm"><?= $listing['is_active'] ? 'Deactivate' : 'Reactivate' ?></button>
        </form>
      </div>
    </header>

    <?php if ($successMsg): ?>
    <div class="p-4 bg-green-50 border border-green-200 text-green-700 rounded-xl mb-6 flex items-center gap-2 text-sm">
      <span class="material-symbols-outlined text-sm">check_circle</span><?= htmlspecialchars($successMsg) ?>
    </div>
    <?php endif; ?>
    <?php if ($errors): ?>
    <div class="p-4 bg-error-container rounded-xl mb-6">
      <ul class="text-sm text-error space-y-1">
        <?php foreach ($errors as $e): ?><li class="flex items-center gap-2"><span class="material-symbols-outlined text-sm">error</span><?= htmlspecialchars($e) ?></li><?php endforeach; ?>
      </ul>
    </div>
    <?php endif; ?>

    <?php if ($hasAuction): ?>
    <div class="p-4 rounded-xl mb-6 <?= $listing['auction_status']==='Active' ? 'bg-red-50' : 'bg-surface-container' ?>">
      <div class="flex items-center gap-2 flex-wrap">
        <span class="px-3 py-1 rounded-full text-xs font-bold <?= $listing['auction_status']==='Active' ? 'bg-yellow-400 text-black' : 'bg-surface-container text-tertiary' ?>">AUCTION - <?= strtoupper($listing['auction_status']) ?></span>
        <span class="text-sm text-tertiary">
          Highest Bid: <strong class="text-on-surface"><?= convertCurrency((float)$listing['current_highest_bid']) ?></strong>
          &bull; Ends: <strong><?= $listing['end_time'] ? date('M d, Y h:i A', strtotime($listing['end_time'])) : 'N/A' ?></strong>
        </span>
      </div>
      <?php if ($hasBids): ?>
      <p class="text-xs text-tertiary mt-2 flex items-center gap-1">
        <span class="material-symbols-outlined text-sm">info</span>
        This auction has active bids. Title, description, and photos can still be edited. Category, size, and price cannot be changed.
      </p>
      <?php endif; ?>
    </div>
    <?php endif; ?>

    <form method="POST" enctype="multipart/form-data">
      <input type="hidden" name="save" value="1">
      <div class="grid grid-cols-1 lg:grid-cols-[420px_1fr] gap-12">

        <!-- LEFT: Photos -->
        <div class="lg:sticky lg:top-6 self-start space-y-3">
          <div class="bg-white border border-outline-variant rounded-xl overflow-hidden" style="aspect-ratio:4/5">
            <?php if (!empty($images)): ?>
            <img src="<?= htmlspecialchars($images[0]['image_url']) ?>" class="w-full h-full object-cover" alt="Cover">
            <?php else: ?>
            <div class="w-full h-full flex items-center justify-center text-tertiary">
              <span class="material-symbols-outlined" style="font-size:56px">checkroom</span>
            </div>
            <?php endif; ?>
          </div>

          <div class="flex gap-2 flex-wrap">
            <?php foreach ($images as $img): ?>
            <div class="relative" style="width:76px;height:76px">
              <img src="<?= htmlspecialchars($img['image_url']) ?>" class="w-full h-full object-cover rounded-lg border-2" style="border-color:<?= $img['is_primary'] ? 'var(--clr-coral, #ff6b6b)' : '#e5e5e5' ?>">
              <?php if ($img['is_primary']): ?><span class="absolute bottom-0 left-0 text-[9px] font-bold px-1 rounded bg-thrift-coral text-white">COVER</span><?php endif; ?>
              <div class="absolute top-0.5 right-0.5 flex gap-0.5">
                <?php if (!$img['is_primary']): ?>
                <form method="POST"><input type="hidden" name="image_id" value="<?= $img['image_id'] ?>">
                  <button type="submit" name="make_primary" value="1" title="Make cover photo" class="w-5 h-5 rounded-full bg-white border text-[10px]">★</button>
                </form>
                <?php endif; ?>
                <form method="POST" onsubmit="return confirm('Remove this photo?')"><input type="hidden" name="image_id" value="<?= $img['image_id'] ?>">
                  <button type="submit" name="delete_photo" value="1" title="Remove" class="w-5 h-5 rounded-full bg-white border text-[10px] text-error">&times;</button>
                </form>
              </div>
            </div>
            <?php endforeach; ?>
          </div>

          <label class="block cursor-pointer border-2 border-dashed border-outline-variant rounded-xl p-4 text-center text-tertiary text-sm">
            <span class="material-symbols-outlined align-middle text-tertiary mr-1">add_photo_alternate</span>Add more photos
            <input type="file" name="new_photos[]" accept="image/png,image/jpeg,image/webp" multiple class="hidden" onchange="document.getElementById('newPhotoCount').textContent=this.files.length+' new photo(s) selected'">
          </label>
          <p id="newPhotoCount" class="text-xs text-tertiary"></p>
        </div>

        <!-- RIGHT: Details -->
        <div class="space-y-6">

          <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-4">
            <div class="space-y-1">
              <label class="block text-sm font-medium text-on-surface">Item Title <span class="text-thrift-coral">*</span></label>
              <input class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="title" type="text" value="<?= htmlspecialchars($listing['title']) ?>" maxlength="200" required>
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-medium text-on-surface">Description <span class="text-tertiary font-normal">(optional)</span></label>
              <textarea class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="description" rows="6"><?= htmlspecialchars($listing['description'] ?? '') ?></textarea>
            </div>
          </section>

          <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-4">
            <h2 class="font-bold text-sm mb-1 text-tertiary uppercase tracking-wide">Category &amp; Condition</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-5">

              <?php
              function tb_dropdown_edit(string $name, string $id, string $placeholder, array $options, $selected, bool $required = false, bool $disabled = false): void {
                  $selectedLabel = $placeholder;
                  foreach ($options as $opt) { if ((string)$opt['value'] === (string)$selected) { $selectedLabel = $opt['label']; break; } }
                  ?>
                  <div class="tb-dd <?= $disabled ? 'opacity-50 pointer-events-none' : '' ?>" data-name="<?= $name ?>">
                    <button type="button" class="tb-dd-btn">
                      <span class="tb-dd-btn-label"><?= htmlspecialchars($selectedLabel) ?></span>
                      <span class="material-symbols-outlined icon-sm">expand_more</span>
                    </button>
                    <div class="tb-dd-menu">
                      <?php foreach ($options as $opt): ?>
                      <div class="tb-dd-option" data-value="<?= htmlspecialchars($opt['value']) ?>"><?= htmlspecialchars($opt['label']) ?></div>
                      <?php endforeach; ?>
                    </div>
                    <input type="hidden" name="<?= $name ?>" id="<?= $id ?>" value="<?= htmlspecialchars($selected ?? '') ?>" <?= $required ? 'required' : '' ?>>
                  </div>
                  <?php
              }
              ?>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface">Category <span class="text-thrift-coral">*</span></label>
                <?php tb_dropdown_edit('category_id', 'categorySelect', 'Select a category',
                  array_map(fn($c)=>['value'=>$c['category_id'],'label'=>$c['name']], $categories),
                  $listing['category_id'], true, $hasBids); ?>
                <?php if ($hasBids): ?><p class="text-xs text-tertiary">Locked, auction has active bids.</p><?php endif; ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface">Size <span class="text-thrift-coral">*</span></label>
                <?php tb_dropdown_edit('size_id', 'sizeSelect', 'Select size',
                  array_map(fn($s)=>['value'=>$s['size_id'],'label'=>$s['size_value']], $sizes),
                  $listing['size_id'], true, $hasBids); ?>
                <?php if ($hasBids): ?><p class="text-xs text-tertiary">Locked, auction has active bids.</p><?php endif; ?>
              </div>

              <div class="space-y-1 md:col-span-2">
                <label class="block text-sm font-medium text-on-surface">Condition <span class="text-thrift-coral">*</span></label>
                <?php tb_dropdown_edit('condition_grade', 'conditionSelect', 'Select condition',
                  array_map(fn($c)=>['value'=>$c,'label'=>$c], ['Brand New','Like New','Lightly Used','Well Used','Heavily Used']),
                  $listing['condition_grade'], true); ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface">Color <span class="text-tertiary font-normal">(optional)</span></label>
                <input type="text" name="color" value="<?= htmlspecialchars($listing['color'] ?? '') ?>" placeholder="e.g. Black, Multicolor" class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm">
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface">Material <span class="text-tertiary font-normal">(optional)</span></label>
                <input type="text" name="material" value="<?= htmlspecialchars($listing['material'] ?? '') ?>" placeholder="e.g. Cotton, Leather" class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm">
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface">Target Gender <span class="text-tertiary font-normal">(optional)</span></label>
                <?php tb_dropdown_edit('target_gender', 'genderSelect', 'Not specified',
                  array_map(fn($g)=>['value'=>$g,'label'=>$g], ['Women','Men','Unisex','Kids']),
                  $listing['target_gender'] ?? ''); ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface">Made In <span class="text-tertiary font-normal">(optional)</span></label>
                <input type="text" name="made_in" value="<?= htmlspecialchars($listing['made_in'] ?? '') ?>" placeholder="e.g. Philippines, Italy" class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm">
              </div>
            </div>
          </section>

          <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-4">
            <h2 class="font-bold text-sm mb-1 text-tertiary uppercase tracking-wide">Pricing</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <?php if (!$hasAuction): ?>
            <div class="space-y-1">
              <label class="block text-sm font-medium text-on-surface">Selling Price (₱) <span class="text-thrift-coral">*</span></label>
              <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-tertiary">₱</span>
                <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="price" type="number" min="1" step="0.01" value="<?= $listing['price'] ?>" required>
              </div>
            </div>
            <?php else: ?>
            <div class="max-w-xs px-4 py-3 bg-surface-container border border-outline-variant rounded-lg text-sm font-bold text-tertiary">
              <?= convertCurrency((float)$listing['price']) ?> <span class="font-normal text-xs">(auction, can't edit)</span>
            </div>
            <?php endif; ?>

            <div class="space-y-1">
              <label class="block text-sm font-medium text-on-surface">Original Retail Price (₱) <span class="text-tertiary font-normal">(optional)</span></label>
              <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-tertiary">₱</span>
                <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="original_price" type="number" min="0" step="0.01" value="<?= $listing['original_price'] ?? '' ?>">
              </div>
            </div>
            </div>
          </section>

          <div class="flex justify-end items-center gap-4">
            <a href="active-auctions.php?tab=<?= $hasAuction ? 'active' : 'fixed' ?>" class="btn btn-ghost px-6 py-3 rounded-xl text-sm font-medium">Cancel</a>
            <button type="submit" class="btn btn-primary px-10 py-3 rounded-xl font-bold"><span class="material-symbols-outlined icon-sm">save</span>Save Changes</button>
          </div>

          <?php if (!$hasBids): ?>
          <section class="bg-white border rounded-xl overflow-hidden" style="border-color:var(--clr-error-bg,#f5e0de)">
            <div class="px-6 py-3" style="background:var(--clr-error-bg,#f5e0de)"><span class="font-bold text-error text-sm">Danger Zone</span></div>
            <div class="p-6 flex items-center justify-between flex-wrap gap-3">
              <div>
                <p class="font-semibold text-sm text-on-surface">Delete this listing</p>
                <p class="text-xs text-tertiary mt-0.5">
                  <?= $hasSold ? "This item has order history, so it's archived (hidden) rather than fully removed." : "Permanently hides this listing from buyers." ?>
                </p>
              </div>
              <form method="POST" onsubmit="return confirm('Delete this listing? This cannot be undone from the UI.')">
                <button type="submit" name="delete_listing" value="1" class="btn btn-danger btn-sm">Delete Listing</button>
              </form>
            </div>
          </section>
          <?php endif; ?>

        </div>
      </div>
    </form>
  </div>
</main>
</div>

<style>
.tb-dd { position: relative; }
.tb-dd-btn {
  width: 100%; display: flex; align-items: center; justify-content: space-between;
  padding: 12px 14px; border: 1px solid var(--clr-outline-variant, #d8d8d8); border-radius: 8px;
  background: #fff; font-size: 14px; cursor: pointer; text-align: left; color: var(--clr-text, #1a1a1a);
}
.tb-dd-btn:hover { border-color: var(--clr-coral, #ff6b6b); }
.tb-dd-menu {
  display: none; position: absolute; top: calc(100% + 4px); left: 0; right: 0;
  background: #fff; border: 1px solid var(--clr-outline-variant, #d8d8d8); border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.10); max-height: 240px; overflow-y: auto; z-index: 60;
}
.tb-dd-menu.open { display: block; }
.tb-dd-option { padding: 10px 14px; font-size: 14px; cursor: pointer; }
.tb-dd-option:hover { background: var(--clr-surface-low, #f7f7f7); }
</style>

<script>
document.querySelectorAll('.tb-dd').forEach(dd => {
  const btn = dd.querySelector('.tb-dd-btn');
  const label = dd.querySelector('.tb-dd-btn-label');
  const menu = dd.querySelector('.tb-dd-menu');
  const hidden = dd.querySelector('input[type=hidden]');
  btn.addEventListener('click', e => {
    e.stopPropagation();
    document.querySelectorAll('.tb-dd-menu.open').forEach(m => { if (m !== menu) m.classList.remove('open'); });
    menu.classList.toggle('open');
  });
  menu.querySelectorAll('.tb-dd-option').forEach(opt => {
    opt.addEventListener('click', () => {
      hidden.value = opt.dataset.value;
      label.textContent = opt.textContent;
      menu.classList.remove('open');
    });
  });
});
document.addEventListener('click', () => document.querySelectorAll('.tb-dd-menu.open').forEach(m => m.classList.remove('open')));

<?php if (!$hasBids): ?>
// Category -> Size dependency (only relevant when editing is still allowed)
const SIZES_BY_CATEGORY = <?= json_encode((function() {
    $all = DB::fetchAll('SELECT * FROM CATEGORY_SIZES ORDER BY size_id');
    $out = [];
    foreach ($all as $s) $out[$s['category_id']][] = $s;
    return $out;
})()) ?>;
const categoryDd = document.querySelector('.tb-dd[data-name="category_id"]');
const sizeDd     = document.querySelector('.tb-dd[data-name="size_id"]');
categoryDd.querySelector('input[type=hidden]').addEventListener('change', function () {
  const sizes = SIZES_BY_CATEGORY[this.value] || [];
  const menu = sizeDd.querySelector('.tb-dd-menu');
  const hidden = sizeDd.querySelector('input[type=hidden]');
  menu.innerHTML = sizes.map(s => `<div class="tb-dd-option" data-value="${s.size_id}">${s.size_value}</div>`).join('');
  menu.querySelectorAll('.tb-dd-option').forEach(opt => {
    opt.addEventListener('click', () => {
      hidden.value = opt.dataset.value;
      sizeDd.querySelector('.tb-dd-btn-label').textContent = opt.textContent;
      menu.classList.remove('open');
    });
  });
  hidden.value = '';
  sizeDd.querySelector('.tb-dd-btn-label').textContent = sizes.length ? 'Select size' : 'No sizes configured';
});
<?php endif; ?>
</script>
</body></html>