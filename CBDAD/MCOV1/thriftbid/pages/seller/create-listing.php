<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin();
requireRole(['seller','admin']);

$user     = currentUser();
$sellerId = $user['seller_id'] ?? $user['id']; // session row IS the seller row now (no USERS lookup needed)

$categories   = DB::fetchAll('SELECT * FROM CATEGORIES ORDER BY name');
$brands       = DB::fetchAll('SELECT * FROM BRANDS ORDER BY brand_name');
$productLines = DB::fetchAll('SELECT * FROM PRODUCT_LINES ORDER BY line_name');
$allSizes     = DB::fetchAll('SELECT * FROM CATEGORY_SIZES ORDER BY size_id');

// Group sizes & product lines client-side 
$sizesByCategory = [];
foreach ($allSizes as $sz) $sizesByCategory[$sz['category_id']][] = $sz;
$linesByBrand = [];
foreach ($productLines as $pl) $linesByBrand[$pl['brand_id']][] = $pl;

const UPLOAD_DIR = __DIR__ . '/../../uploads/listings/';
const UPLOAD_URL_BASE = '/uploads/listings/';

$errors = [];
$vals   = [];

//Find or create a product line to satisfy LISTINGS.product_line_id (NOT NULL).
function resolveProductLineId(int $brandId, int $chosenLineId): int {
    if ($chosenLineId > 0) {
        $line = DB::fetch('SELECT product_line_id FROM PRODUCT_LINES WHERE product_line_id=? AND brand_id=?', [$chosenLineId, $brandId]);
        if ($line) return (int)$line['product_line_id'];
    }
// Match on tier instead of hardcoding a line name, as generic fallbacks vary by brand (e.g., 'Unknown' or 'Generic / No Brand').
    $default = DB::fetch("SELECT product_line_id FROM PRODUCT_LINES WHERE brand_id=? AND tier='Unbranded' ORDER BY product_line_id LIMIT 1", [$brandId]);
    if ($default) return (int)$default['product_line_id'];
    // Still nothing? Any line at all for this brand beats creating a duplicate.
    $any = DB::fetch('SELECT product_line_id FROM PRODUCT_LINES WHERE brand_id=? ORDER BY product_line_id LIMIT 1', [$brandId]);
    if ($any) return (int)$any['product_line_id'];
    return DB::insert("INSERT INTO PRODUCT_LINES (brand_id, line_name, tier) VALUES (?, 'Unknown', 'Unbranded')", [$brandId]);
}

function saveUploadedPhoto(array $file): ?string {
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) return null;
    if ($file['error'] !== UPLOAD_ERR_OK) return null;

    $allowed = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    $mime = mime_content_type($file['tmp_name']);
    if (!isset($allowed[$mime])) return null;
    if ($file['size'] > 6 * 1024 * 1024) return null; // 6MB cap

    if (!is_dir(UPLOAD_DIR)) mkdir(UPLOAD_DIR, 0775, true);
    $name = bin2hex(random_bytes(12)) . '.' . $allowed[$mime];
    if (!move_uploaded_file($file['tmp_name'], UPLOAD_DIR . $name)) return null;

    return UPLOAD_URL_BASE . $name;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $vals = [
        'title'         => trim($_POST['title'] ?? ''),
        'description'   => trim($_POST['description'] ?? ''),
        'category_id'   => (int)($_POST['category_id'] ?? 0),
        'brand_id'      => (int)($_POST['brand_id'] ?? 0),
        'product_line_id'=> (int)($_POST['product_line_id'] ?? 0),
        'size_id'       => (int)($_POST['size_id'] ?? 0),
        'condition_grade'=> $_POST['condition_grade'] ?? '',
        'color'         => trim($_POST['color'] ?? ''),
        'material'      => trim($_POST['material'] ?? ''),
        'target_gender' => $_POST['target_gender'] ?? '',
        'made_in'       => trim($_POST['made_in'] ?? ''),
        'listing_type'  => $_POST['listing_type'] ?? 'fixed',
        'price'         => (float)($_POST['price'] ?? 0),
        'original_price'=> (float)($_POST['original_price'] ?? 0),
        'start_bid'     => (float)($_POST['start_bid'] ?? 0),
        'min_increment' => (float)($_POST['min_increment'] ?? 10),
        'end_hours'     => (int)($_POST['end_hours'] ?? 48),
        'is_luxury'     => isset($_POST['is_luxury']),
        'has_certificate'=> $_POST['has_certificate'] ?? 'no',
    ];

    $conditions = ['Brand New','Like New','Lightly Used','Well Used','Heavily Used'];

    if (!$vals['title'])                                    $errors[] = 'Item title is required.';
    if (!$vals['category_id'])                               $errors[] = 'Please select a category.';
    if (!$vals['brand_id'])                                  $errors[] = 'Please select a brand (choose "Unbranded" if none).';
    if (!$vals['size_id'])                                   $errors[] = 'Please select a size.';
    if (!in_array($vals['condition_grade'], $conditions, true)) $errors[] = 'Please select a valid item condition.';
    if ($vals['listing_type'] === 'fixed' && $vals['price'] <= 0)     $errors[] = 'Enter a valid fixed price.';
    if ($vals['listing_type'] === 'auction' && $vals['start_bid'] <= 0) $errors[] = 'Enter a valid starting bid.';
    if ($vals['listing_type'] === 'auction' && $vals['min_increment'] <= 0) $errors[] = 'Minimum increment must be greater than 0.';

    $photoFiles = array_filter($_FILES['photos']['tmp_name'] ?? [], fn($t) => $t !== '');
    if (empty($photoFiles)) $errors[] = 'At least one photo is required.';

    if ($vals['is_luxury'] && $vals['has_certificate'] === 'yes' && ($_FILES['certificate']['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
        $errors[] = 'Please upload a photo of the certificate of authenticity.';
    }
    if ($vals['is_luxury'] && $vals['has_certificate'] === 'no' && ($_FILES['box_match_photo']['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
        $errors[] = 'Without a certificate, please upload a photo showing the item together with its box/serial number so admin can verify they match.';
    }

    if (empty($errors)) {
        $productLineId = resolveProductLineId($vals['brand_id'], $vals['product_line_id']);
        $price = $vals['listing_type'] === 'fixed' ? $vals['price'] : $vals['start_bid'];

        // Luxury items stay OFF (pending admin authentication) until approved.
        // Everything else auto-publishes immediately.
        $isActive = $vals['is_luxury'] ? 0 : 1;

        $listingId = DB::insert(
            'INSERT INTO LISTINGS (title, description, price, original_price, condition_grade, color, material, target_gender, made_in, is_active, category_id, seller_id, product_line_id, size_id)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
            [$vals['title'], $vals['description'] ?: null, $price, $vals['original_price'] > 0 ? $vals['original_price'] : null,
             $vals['condition_grade'], $vals['color'] ?: null, $vals['material'] ?: null, $vals['target_gender'] ?: null, $vals['made_in'] ?: null,
             $isActive, $vals['category_id'], $sellerId, $productLineId, $vals['size_id']]
        );

        // Photos via device upload
        $isPrimary = 1;
        foreach ($_FILES['photos']['tmp_name'] as $i => $tmp) {
            if ($tmp === '') continue;
            $file = [
                'tmp_name' => $tmp,
                'error'    => $_FILES['photos']['error'][$i],
                'size'     => $_FILES['photos']['size'][$i],
            ];
            $url = saveUploadedPhoto($file);
            if ($url) {
                DB::query('INSERT INTO LISTING_IMAGES (listing_id, image_url, is_primary) VALUES (?,?,?)', [$listingId, $url, $isPrimary]);
                $isPrimary = 0;
            }
        }

        // Auction record
        if ($vals['listing_type'] === 'auction') {
            $endTime = date('Y-m-d H:i:s', time() + ($vals['end_hours'] * 3600));
            DB::query(
                'INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id)
                 VALUES (?,?,?,NOW(),?,"Active",?)',
                [$vals['start_bid'], $vals['min_increment'], $vals['start_bid'], $endTime, $listingId]
            );
        }

        // Luxury authentication workflow
        if ($vals['is_luxury']) {
            $certUrl = null;
            if ($vals['has_certificate'] === 'yes') {
                $certUrl = saveUploadedPhoto($_FILES['certificate']);
                if ($certUrl) DB::query('INSERT INTO LISTING_IMAGES (listing_id, image_url, is_primary) VALUES (?,?,0)', [$listingId, $certUrl]);
                $remarks = 'Certificate of authenticity submitted by seller.';
            } else {
                $boxUrl = saveUploadedPhoto($_FILES['box_match_photo']);
                if ($boxUrl) DB::query('INSERT INTO LISTING_IMAGES (listing_id, image_url, is_primary) VALUES (?,?,0)', [$listingId, $boxUrl]);
                $remarks = 'No certificate provided, seller submitted a box/item match photo for verification.';
            }

            DB::query(
                'INSERT INTO AUTHENTICATION (listing_id, authentication_status, remarks, manufacture_year) VALUES (?,"Pending",?,?)',
                [$listingId, $remarks, (int)($_POST['manufacture_year'] ?? 0) ?: null]
            );

            DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
                [$sellerId, 'Listing Submitted for Authentication',
                 'Your luxury item "' . $vals['title'] . '" is pending admin authentication before it goes live.', 'SYSTEM']);
        } else {
            DB::query('INSERT INTO NOTIFICATIONS (seller_id, title, message, notification_type) VALUES (?,?,?,?)',
                [$sellerId, 'Listing Created!', 'Your item "' . $vals['title'] . '" is now live on ThriftBid.', 'SYSTEM']);
        }

        header('Location: ' . BASE_URL . '/pages/seller/active-auctions.php?created=1');
        exit;
    }
}

renderHead('Create Listing');
?>
<body class="flex flex-col h-screen overflow-hidden">
<?php renderNavbar('home', true); ?>

<div class="flex flex-1 w-full overflow-hidden">
<?php renderSellerSidebar('create'); ?>

<main class="flex-1 overflow-auto bg-background">
  <div class="max-w-[1400px] mx-auto px-6 py-8">

    <header class="mb-6">
      <h1 class="text-3xl font-bold text-on-surface" style="font-family:'Hanken Grotesk',sans-serif">Create New Listing</h1>
      <p class="text-tertiary mt-1">Fill in the details below to publish your thrifted item.</p>
    </header>

    <?php if ($errors): ?>
    <div class="p-4 bg-error-container rounded-xl mb-6">
      <ul class="text-sm text-error space-y-1">
        <?php foreach ($errors as $e): ?><li class="flex items-center gap-2"><span class="material-symbols-outlined text-sm">error</span><?= htmlspecialchars($e) ?></li><?php endforeach; ?>
      </ul>
    </div>
    <?php endif; ?>

    <form method="POST" enctype="multipart/form-data" id="createForm">
      <!-- Listing-view style layout: photo panel on the left (sticky), details on the right -->
      <div class="grid grid-cols-1 lg:grid-cols-[420px_1fr] gap-12">

        <!-- LEFT: Photos, listing page's image panel -->
        <div class="lg:sticky lg:top-6 self-start space-y-3">
          <label id="dropZone" for="photosInput" class="block cursor-pointer bg-surface-container border border-outline-variant rounded-xl overflow-hidden" style="aspect-ratio:4/5;display:flex;align-items:center;justify-content:center;position:relative">
            <div id="dropZoneEmpty" class="text-center text-tertiary px-6">
              <span class="material-symbols-outlined" style="font-size:56px;color:var(--clr-outline-variant, #c9c9c9)">add_photo_alternate</span>
              <p class="font-bold mt-2 text-on-surface">Add Photos</p>
              <p class="text-xs mt-1">Click to upload from your device &bull; up to 6 photos &bull; first photo becomes the cover</p>
            </div>
            <img id="mainPreview" class="hidden w-full h-full object-cover" alt="Cover preview">
            <?php if ($errors && !empty($vals['is_luxury'])): ?><span class="absolute top-3 right-3 text-xs font-bold px-2 py-1 rounded bg-black text-white">Luxury</span><?php endif; ?>
          </label>
          <input type="file" name="photos[]" id="photosInput" accept="image/png,image/jpeg,image/webp" multiple class="hidden">
          <div id="thumbRow" class="flex gap-2 flex-wrap"></div>
          <p class="text-xs text-tertiary">3+ clear photos improve your listing's completeness score in Analytics.</p>
        </div>

        <!-- RIGHT: listing page's info panel -->
        <div class="space-y-6">

          <!-- Listing type -->
          <section class="bg-white border border-outline-variant rounded-xl p-6">
            <h2 class="font-bold text-sm mb-3 text-tertiary uppercase tracking-wide">Listing Type</h2>
            <div class="grid grid-cols-2 gap-3" id="typeCards">
              <label class="cursor-pointer listing-type-card" data-type="fixed">
                <input type="radio" name="listing_type" value="fixed" class="hidden" <?= ($vals['listing_type'] ?? 'fixed')==='fixed'?'checked':'' ?>>
                <div class="p-4 border-2 rounded-xl flex items-center gap-3 card-inner <?= ($vals['listing_type'] ?? 'fixed')==='fixed'?'border-thrift-coral bg-red-50':'border-outline-variant' ?>">
                  <span class="material-symbols-outlined text-xl text-tertiary">sell</span>
                  <div>
                    <p class="font-bold text-sm text-on-surface">Fixed Price</p>
                    <p class="text-xs text-tertiary">Buy-now, no bidding</p>
                  </div>
                </div>
              </label>
              <label class="cursor-pointer listing-type-card" data-type="auction">
                <input type="radio" name="listing_type" value="auction" class="hidden" <?= ($vals['listing_type'] ?? '')==='auction'?'checked':'' ?>>
                <div class="p-4 border-2 rounded-xl flex items-center gap-3 card-inner <?= ($vals['listing_type'] ?? '')==='auction'?'border-thrift-coral bg-red-50':'border-outline-variant' ?>">
                  <span class="material-symbols-outlined text-xl text-tertiary">gavel</span>
                  <div>
                    <p class="font-bold text-sm text-on-surface">Auction</p>
                    <p class="text-xs text-tertiary">Anti-snipe protected</p>
                  </div>
                </div>
              </label>
            </div>
          </section>

          <!-- Title + description -->
          <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-4">
            <div class="space-y-1">
              <label class="block text-sm font-medium text-on-surface" style="display:block">Item Title <span class="text-thrift-coral">*</span></label>
              <input class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="title" type="text" placeholder="e.g. Vintage Levi's 501 Jeans" maxlength="200" value="<?= htmlspecialchars($vals['title'] ?? '') ?>" required>
            </div>
            <div class="space-y-1">
              <label class="block text-sm font-medium text-on-surface" style="display:block">Description <span class="text-tertiary font-normal">(optional)</span></label>
              <textarea class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="description" rows="6" placeholder="Style, fit, fabric, any flaws..."><?= htmlspecialchars($vals['description'] ?? '') ?></textarea>
            </div>
          </section>

          <!-- Category / Brand / Size / Product line -->
          <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-4">
            <h2 class="font-bold text-sm mb-1 text-tertiary uppercase tracking-wide">Category &amp; Brand</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-5">

              <?php
              
              function tb_dropdown(string $name, string $id, string $placeholder, array $options, $selected, bool $required = false): void {
                  $selectedLabel = $placeholder;
                  foreach ($options as $opt) { if ((string)$opt['value'] === (string)$selected) { $selectedLabel = $opt['label']; break; } }
                  ?>
                  <div class="tb-dd" data-name="<?= $name ?>" <?= $required ? 'data-required="1"' : '' ?>>
                    <button type="button" class="tb-dd-btn">
                      <span class="tb-dd-btn-label"><?= htmlspecialchars($selectedLabel) ?></span>
                      <span class="material-symbols-outlined icon-sm">expand_more</span>
                    </button>
                    <div class="tb-dd-menu">
                      <div class="tb-dd-option" data-value="">-- <?= htmlspecialchars($placeholder) ?> --</div>
                      <?php foreach ($options as $opt): ?>
                      <div class="tb-dd-option" data-value="<?= htmlspecialchars($opt['value']) ?>"><?= htmlspecialchars($opt['label']) ?></div>
                      <?php endforeach; ?>
                    </div>
                    
                    <input type="hidden" name="<?= $name ?>" id="<?= $id ?>" value="<?= htmlspecialchars($selected ?? '') ?>">
                  </div>
                  <?php
              }
              ?>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Category <span class="text-thrift-coral">*</span></label>
                <?php tb_dropdown('category_id', 'categorySelect', 'Select a category',
                  array_map(fn($c)=>['value'=>$c['category_id'],'label'=>$c['name']], $categories),
                  $vals['category_id'] ?? '', true); ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Size <span class="text-thrift-coral">*</span></label>
                <?php tb_dropdown('size_id', 'sizeSelect', 'Select category first', [], $vals['size_id'] ?? '', true); ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Brand <span class="text-thrift-coral">*</span></label>
                <?php tb_dropdown('brand_id', 'brandSelect', 'Select brand (or Unbranded)',
                  array_map(fn($b)=>['value'=>$b['brand_id'],'label'=>$b['brand_name']], $brands),
                  $vals['brand_id'] ?? '', true); ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Product Line <span class="text-tertiary font-normal">(optional)</span></label>
                <?php tb_dropdown('product_line_id', 'lineSelect', 'Unknown / Default', [], $vals['product_line_id'] ?? '0'); ?>
              </div>

              <div class="space-y-1 md:col-span-2">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Condition <span class="text-thrift-coral">*</span></label>
                <?php tb_dropdown('condition_grade', 'conditionSelect', 'Select condition',
                  array_map(fn($c)=>['value'=>$c,'label'=>$c], ['Brand New','Like New','Lightly Used','Well Used','Heavily Used']),
                  $vals['condition_grade'] ?? '', true); ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Color <span class="text-tertiary font-normal">(optional)</span></label>
                <input type="text" name="color" value="<?= htmlspecialchars($vals['color'] ?? '') ?>" placeholder="e.g. Black, Multicolor" class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm">
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Material <span class="text-tertiary font-normal">(optional)</span></label>
                <input type="text" name="material" value="<?= htmlspecialchars($vals['material'] ?? '') ?>" placeholder="e.g. Cotton, Leather" class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm">
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Target Gender <span class="text-tertiary font-normal">(optional)</span></label>
                <?php tb_dropdown('target_gender', 'genderSelect', 'Not specified',
                  array_map(fn($g)=>['value'=>$g,'label'=>$g], ['Women','Men','Unisex','Kids']),
                  $vals['target_gender'] ?? ''); ?>
              </div>

              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Made In <span class="text-tertiary font-normal">(optional)</span></label>
                <input type="text" name="made_in" value="<?= htmlspecialchars($vals['made_in'] ?? '') ?>" placeholder="e.g. Philippines, Italy" class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm">
              </div>
            </div>
          </section>

          <!-- Pricing -->
          <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-4" id="pricingSection">
            <h2 class="font-bold text-sm mb-1 text-tertiary uppercase tracking-wide">Pricing</h2>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div id="fixedPriceField">
                <label class="text-sm font-medium text-on-surface block mb-1">Selling Price (₱) <span class="text-thrift-coral">*</span></label>
                <div class="relative">
                  <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-tertiary">₱</span>
                  <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="price" type="number" min="1" step="0.01" placeholder="0.00" value="<?= $vals['price'] ?? '' ?>">
                </div>
              </div>

              <div>
                <label class="text-sm font-medium text-on-surface block mb-1">Original Retail Price (₱) <span class="text-tertiary font-normal">(optional)</span></label>
                <div class="relative">
                  <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-tertiary">₱</span>
                  <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="original_price" type="number" min="0" step="0.01" placeholder="0.00" value="<?= $vals['original_price'] ?? '' ?>">
                </div>
              </div>
            </div>

            <div id="auctionFields" class="hidden space-y-4">
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="space-y-1">
                  <label class="block text-sm font-medium text-on-surface" style="display:block">Starting Bid (₱) <span class="text-thrift-coral">*</span></label>
                  <div class="relative">
                    <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-tertiary">₱</span>
                    <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="start_bid" type="number" min="1" step="0.01" placeholder="0.00" value="<?= $vals['start_bid'] ?? '' ?>">
                  </div>
                </div>
                <div class="space-y-1">
                  <label class="block text-sm font-medium text-on-surface" style="display:block">Min. Increment (₱)</label>
                  <div class="relative">
                    <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-tertiary">₱</span>
                    <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="min_increment" type="number" min="1" step="0.01" value="<?= $vals['min_increment'] ?? '10' ?>">
                  </div>
                </div>
                <div class="space-y-1">
                  <label class="block text-sm font-medium text-on-surface" style="display:block">Duration</label>
                  <?php
                  $durations = [6=>'6 hours',12=>'12 hours',24=>'1 day',48=>'2 days',72=>'3 days',168=>'7 days'];
                  $durationOpts = [];
                  foreach ($durations as $h => $l) $durationOpts[] = ['value'=>$h,'label'=>$l];
                  tb_dropdown('end_hours', 'endHoursSelect', 'Select duration', $durationOpts, $vals['end_hours'] ?? 48);
                  ?>
                </div>
              </div>
              <div class="p-3 bg-yellow-50 border border-yellow-200 rounded-lg text-xs text-yellow-700">
                <strong>Anti-Snipe Rule:</strong> a bid in the last 2 minutes extends the auction by 2 minutes (max 10x).
              </div>
            </div>
          </section>

          <!-- Luxury -->
          <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-4">
            <label class="flex items-center gap-2 text-sm font-medium text-on-surface">
              <input type="checkbox" name="is_luxury" id="luxuryToggle" value="1" <?= !empty($vals['is_luxury'])?'checked':'' ?>>
              Tag as Luxury <span class="text-tertiary font-normal">(requires admin authentication before it goes live)</span>
            </label>

            <div id="luxurySection" class="hidden space-y-3 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p class="block text-sm font-medium text-on-surface" style="display:block">Does the brand provide an official certificate of authenticity?</p>
              <div class="flex gap-6">
                <label class="flex items-center gap-2 text-sm"><input type="radio" name="has_certificate" value="yes" <?= ($vals['has_certificate']??'')==='yes'?'checked':'' ?>> Yes, I have one</label>
                <label class="flex items-center gap-2 text-sm"><input type="radio" name="has_certificate" value="no" <?= ($vals['has_certificate']??'no')==='no'?'checked':'' ?>> No certificate</label>
              </div>
              <div id="certUploadField" class="hidden space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Photo of Certificate <span class="text-thrift-coral">*</span></label>
                <input type="file" name="certificate" accept="image/png,image/jpeg,image/webp" class="w-full text-sm">
              </div>
              <div class="space-y-1">
                <label class="block text-sm font-medium text-on-surface" style="display:block">Year Manufactured <span class="text-tertiary font-normal">(optional, if known)</span></label>
                <input type="number" name="manufacture_year" min="1950" max="<?= date('Y') ?>" placeholder="e.g. 2022" class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm max-w-[160px]">
              </div>
              <div id="noCertSection" class="hidden space-y-2">
                <p class="text-xs text-tertiary">
                  Since there's no certificate, upload a clear photo showing the <strong>item together with its original box</strong>, make sure any serial number/code on the box is visible and matches the item. A missing box or a mismatch will be rejected by our admin team.
                </p>
                <label class="block text-sm font-medium text-on-surface" style="display:block">Photo of Item + Box (showing matching code/serial) <span class="text-thrift-coral">*</span></label>
                <input type="file" name="box_match_photo" accept="image/png,image/jpeg,image/webp" class="w-full text-sm">
              </div>
            </div>
          </section>

          <div class="flex justify-end items-center gap-4 pb-8">
            <a href="<?= BASE_URL ?>/pages/seller/dashboard.php" class="btn btn-ghost px-6 py-3 rounded-xl text-sm font-medium">Cancel</a>
            <button type="submit" class="btn btn-primary px-10 py-3 rounded-xl font-bold">Publish Listing</button>
          </div>

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
// Server-provided lookup data
const SIZES_BY_CATEGORY = <?= json_encode($sizesByCategory) ?>;
const LINES_BY_BRAND     = <?= json_encode($linesByBrand) ?>;

// --- custom dropdown  ---
function buildDropdownOptions(dd, options, placeholder, keepValue) {
  const menu = dd.querySelector('.tb-dd-menu');
  const hidden = dd.querySelector('input[type=hidden]');
  const currentVal = keepValue ? hidden.value : '';
  menu.innerHTML = '<div class="tb-dd-option" data-value="">-- ' + placeholder + ' --</div>' +
    options.map(o => `<div class="tb-dd-option" data-value="${o.value}">${o.label}</div>`).join('');
  wireOptions(dd);
  const match = options.find(o => String(o.value) === String(currentVal));
  hidden.value = match ? currentVal : '';
  dd.querySelector('.tb-dd-btn-label').textContent = match ? match.label : placeholder;
}
function wireOptions(dd) {
  const menu = dd.querySelector('.tb-dd-menu');
  const label = dd.querySelector('.tb-dd-btn-label');
  const hidden = dd.querySelector('input[type=hidden]');
  menu.querySelectorAll('.tb-dd-option').forEach(opt => {
    opt.onclick = () => {
      hidden.value = opt.dataset.value;
      label.textContent = opt.textContent;
      menu.classList.remove('open');
      hidden.dispatchEvent(new Event('change'));
    };
  });
}
document.querySelectorAll('.tb-dd').forEach(dd => {
  const btn = dd.querySelector('.tb-dd-btn');
  const menu = dd.querySelector('.tb-dd-menu');
  btn.addEventListener('click', e => {
    e.stopPropagation();
    document.querySelectorAll('.tb-dd-menu.open').forEach(m => { if (m !== menu) m.classList.remove('open'); });
    menu.classList.toggle('open');
  });
  wireOptions(dd);
});
document.addEventListener('click', () => document.querySelectorAll('.tb-dd-menu.open').forEach(m => m.classList.remove('open')));

const categoryHidden = document.getElementById('categorySelect');
const sizeDd     = document.getElementById('sizeSelect').closest('.tb-dd');
const brandHidden = document.getElementById('brandSelect');
const lineDd     = document.getElementById('lineSelect').closest('.tb-dd');

function refreshSizes(keep) {
  const sizes = SIZES_BY_CATEGORY[categoryHidden.value] || [];
  buildDropdownOptions(sizeDd, sizes.map(s => ({value: s.size_id, label: s.size_value})),
    sizes.length ? 'Select size' : 'No sizes configured', !!keep);
}
function refreshLines(keep) {
  const lines = LINES_BY_BRAND[brandHidden.value] || [];
  buildDropdownOptions(lineDd, lines.map(l => ({value: l.product_line_id, label: `${l.line_name} (${l.tier})`})), 'Unknown / Default', !!keep);
}
categoryHidden.addEventListener('change', () => refreshSizes(false));
brandHidden.addEventListener('change', () => refreshLines(false));
if (categoryHidden.value) refreshSizes(true);
if (brandHidden.value) refreshLines(true);

// Listing type toggle
const typeCards = document.querySelectorAll('.listing-type-card');
const fixedField    = document.getElementById('fixedPriceField');
const auctionFields = document.getElementById('auctionFields');
function applyType(type) {
  fixedField.classList.toggle('hidden',    type !== 'fixed');
  auctionFields.classList.toggle('hidden', type === 'fixed');
  typeCards.forEach(c => {
    const inner = c.querySelector('.card-inner');
    const match = c.dataset.type === type;
    inner.classList.toggle('border-thrift-coral', match);
    inner.classList.toggle('bg-red-50', match);
    inner.classList.toggle('border-outline-variant', !match);
  });
}
typeCards.forEach(card => {
  card.addEventListener('click', () => {
    card.querySelector('input[type=radio]').checked = true;
    applyType(card.dataset.type);
  });
});
const checkedType = document.querySelector('input[name=listing_type]:checked');
if (checkedType) applyType(checkedType.value);

// Luxury / certificate toggles
const luxuryToggle  = document.getElementById('luxuryToggle');
const luxurySection = document.getElementById('luxurySection');
const certField     = document.getElementById('certUploadField');
const noCertSection = document.getElementById('noCertSection');

function applyCertChoice() {
  const yes = document.querySelector('input[name=has_certificate][value=yes]')?.checked;
  certField.classList.toggle('hidden', !yes);
  noCertSection.classList.toggle('hidden', !!yes);
}
function applyLuxury() { luxurySection.classList.toggle('hidden', !luxuryToggle.checked); }
luxuryToggle.addEventListener('change', applyLuxury);
document.querySelectorAll('input[name=has_certificate]').forEach(r => r.addEventListener('change', applyCertChoice));


applyLuxury();
applyCertChoice();
applyLuxury(); applyCertChoice();

// Photo preview, cover image shown large (listing-view style), rest as thumbnails. 
const photosInput = document.getElementById('photosInput');
let selectedFiles = [];

function renderPhotoPreview() {
  const mainPreview = document.getElementById('mainPreview');
  const empty = document.getElementById('dropZoneEmpty');
  const thumbRow = document.getElementById('thumbRow');
  thumbRow.innerHTML = '';

  if (selectedFiles.length) {
    mainPreview.src = URL.createObjectURL(selectedFiles[0]);
    mainPreview.classList.remove('hidden');
    empty.classList.add('hidden');
  } else {
    mainPreview.classList.add('hidden');
    empty.classList.remove('hidden');
  }

  selectedFiles.forEach((file, i) => {
    const wrap = document.createElement('div');
    wrap.style.cssText = 'position:relative;width:64px;height:64px';
    const img = document.createElement('img');
    img.src = URL.createObjectURL(file);
    img.style.cssText = `width:64px;height:64px;object-fit:cover;border-radius:8px;border:2px solid ${i===0 ? '#ff6b6b' : '#ddd'}`;
    wrap.appendChild(img);
    if (i === 0) {
      const tag = document.createElement('span');
      tag.textContent = 'Cover';
      tag.style.cssText = 'position:absolute;bottom:1px;left:1px;font-size:9px;font-weight:700;background:#ff6b6b;color:#fff;padding:0 4px;border-radius:4px';
      wrap.appendChild(tag);
    }
    const removeBtn = document.createElement('button');
    removeBtn.type = 'button';
    removeBtn.textContent = '×';
    removeBtn.title = 'Remove photo';
    removeBtn.style.cssText = 'position:absolute;top:-6px;right:-6px;width:20px;height:20px;border-radius:50%;background:#fff;border:1px solid #ddd;font-size:12px;line-height:1;cursor:pointer';
    removeBtn.onclick = () => {
      selectedFiles.splice(i, 1);
      syncFileInput();
      renderPhotoPreview();
    };
    wrap.appendChild(removeBtn);
    thumbRow.appendChild(wrap);
  });
}

function syncFileInput() {
  const dt = new DataTransfer();
  selectedFiles.forEach(f => dt.items.add(f));
  photosInput.files = dt.files;
}

photosInput.addEventListener('change', function () {
  // Newly picked files are appended to whatever's already selected, up to 6 total
  const incoming = [...this.files];
  selectedFiles = [...selectedFiles, ...incoming].slice(0, 6);
  syncFileInput();
  renderPhotoPreview();
});

// Hidden inputs behind custom dropdowns broke native browser validation, silently blocking submits. 
// validate required dropdowns manually here to give clear, visible feedback.
document.getElementById('createForm').addEventListener('submit', function (e) {
  const missing = [];
  document.querySelectorAll('.tb-dd[data-required="1"]').forEach(dd => {
    const input = dd.querySelector('input[type="hidden"]');
    if (!input.value) {
      missing.push(dd);
      dd.querySelector('.tb-dd-btn').style.borderColor = 'var(--clr-error)';
    }
  });

  // Luxury certificate/box-match photo
  if (luxuryToggle.checked) {
    const visibleSection = certField.classList.contains('hidden') ? noCertSection : certField;
    const fileInput = visibleSection.querySelector('input[type="file"]');
    if (fileInput && fileInput.files.length === 0) missing.push(visibleSection);
  }

  if (missing.length) {
    e.preventDefault();
    missing[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
    alert('Please fill out all required fields (marked with *) before publishing.');
  }
});
</script>
</body></html>