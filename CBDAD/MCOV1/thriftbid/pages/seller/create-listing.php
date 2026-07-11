<?php
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/db.php';
require_once __DIR__ . '/../../includes/layout.php';

requireLogin('/pages/login.php');
requireRole(['seller','admin'], '/pages/login.php');

$user     = currentUser();
$seller   = DB::fetch('SELECT seller_id FROM SELLER WHERE user_id = ?', [$user['user_id']]);
$sellerId = $seller['seller_id'] ?? 0;
$categories = DB::fetchAll('SELECT * FROM CATEGORIES ORDER BY category_id');

$errors = [];
$vals   = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $vals = [
        'title'          => trim($_POST['title'] ?? ''),
        'description'    => trim($_POST['description'] ?? ''),
        'category_id'    => (int)($_POST['category_id'] ?? 0),
        'item_condition' => $_POST['item_condition'] ?? 'Good',
        'listing_type'   => $_POST['listing_type'] ?? 'fixed',
        'price'          => (float)($_POST['price'] ?? 0),
        'start_bid'      => (float)($_POST['start_bid'] ?? 0),
        'min_increment'  => (float)($_POST['min_increment'] ?? 10),
        'end_hours'      => (int)($_POST['end_hours'] ?? 48),
        'image_url'      => trim($_POST['image_url'] ?? ''),
    ];

    if (!$vals['title'])        $errors[] = 'Item title is required.';
    if (!$vals['category_id'])  $errors[] = 'Please select a category.';
    if ($vals['listing_type'] === 'fixed' && $vals['price'] <= 0)     $errors[] = 'Enter a valid fixed price.';
    if (in_array($vals['listing_type'], ['auction','live']) && $vals['start_bid'] <= 0) $errors[] = 'Enter a valid starting bid.';
    if (in_array($vals['listing_type'], ['auction','live']) && $vals['min_increment'] <= 0) $errors[] = 'Minimum increment must be greater than 0.';

    if (empty($errors)) {
        $price = $vals['listing_type'] === 'fixed' ? $vals['price'] : $vals['start_bid'];

        $listingId = DB::insert(
            'INSERT INTO LISTINGS (title, description, price, item_condition, image_url, is_active, category_id, seller_id) VALUES (?,?,?,?,?,1,?,?)',
            [$vals['title'], $vals['description'] ?: null, $price, $vals['item_condition'], $vals['image_url'] ?: null, $vals['category_id'], $sellerId]
        );

        // If auction or live bidding, create auction record
        if (in_array($vals['listing_type'], ['auction','live'])) {
            $endTime = date('Y-m-d H:i:s', time() + ($vals['end_hours'] * 3600));
            DB::query(
                'INSERT INTO AUCTIONS (start_bid, min_increment, current_highest_bid, start_time, end_time, status, listing_id) VALUES (?,?,?,NOW(),?,"Active",?)',
                [$vals['start_bid'], $vals['min_increment'], $vals['start_bid'], $endTime, $listingId]
            );
        }

        // Notify the seller
        DB::query('INSERT INTO NOTIFICATIONS (user_id, title, message, notification_type) VALUES (?,?,?,?)',
            [$user['user_id'], 'Listing Created!', 'Your item "' . $vals['title'] . '" is now live on ThriftBid.', 'SYSTEM']);

        header('Location: /pages/seller/active-auctions.php?created=1');
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
  <div class="max-w-[860px] mx-auto px-6 py-10 space-y-8">

    <header>
      <h1 class="text-3xl font-bold text-on-surface" style="font-family:'Hanken Grotesk',sans-serif">Create New Listing</h1>
      <p class="text-on-surface-variant mt-1">Fill in the details below to publish your thrifted item.</p>
    </header>

    <?php if ($errors): ?>
    <div class="p-4 bg-error-container rounded-xl">
      <ul class="text-sm text-error space-y-1">
        <?php foreach ($errors as $e): ?><li class="flex items-center gap-2"><span class="material-symbols-outlined text-sm">error</span><?= htmlspecialchars($e) ?></li><?php endforeach; ?>
      </ul>
    </div>
    <?php endif; ?>

    <form method="POST" class="space-y-8" id="createForm">

      <!-- LISTING TYPE (3 types) -->
      <section class="bg-white border border-outline-variant rounded-xl p-6">
        <h2 class="font-bold text-base mb-4 text-on-surface">Listing Type</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4" id="typeCards">

          <label class="cursor-pointer listing-type-card" data-type="fixed">
            <input type="radio" name="listing_type" value="fixed" class="hidden" <?= ($vals['listing_type'] ?? 'fixed')==='fixed'?'checked':'' ?>>
            <div class="p-5 border-2 rounded-xl transition-all flex flex-col gap-3 h-full card-inner <?= ($vals['listing_type'] ?? 'fixed')==='fixed'?'border-thrift-coral bg-red-50':'border-outline-variant' ?>">
              <span class="material-symbols-outlined text-2xl text-on-surface-variant">sell</span>
              <div>
                <p class="font-bold text-on-surface">Fixed Price</p>
                <p class="text-xs text-on-surface-variant mt-1">Set a direct buy-now price. Buyers can purchase instantly without bidding.</p>
              </div>
            </div>
          </label>

          <label class="cursor-pointer listing-type-card" data-type="auction">
            <input type="radio" name="listing_type" value="auction" class="hidden" <?= ($vals['listing_type'] ?? '')==='auction'?'checked':'' ?>>
            <div class="p-5 border-2 rounded-xl transition-all flex flex-col gap-3 h-full card-inner <?= ($vals['listing_type'] ?? '')==='auction'?'border-thrift-coral bg-red-50':'border-outline-variant' ?>">
              <span class="material-symbols-outlined text-2xl text-on-surface-variant">gavel</span>
              <div>
                <p class="font-bold text-on-surface">Non-Live Auction</p>
                <p class="text-xs text-on-surface-variant mt-1">Buyers bid asynchronously. Highest bid wins when time expires.</p>
              </div>
            </div>
          </label>

          <label class="cursor-pointer listing-type-card" data-type="live">
            <input type="radio" name="listing_type" value="live" class="hidden" <?= ($vals['listing_type'] ?? '')==='live'?'checked':'' ?>>
            <div class="p-5 border-2 rounded-xl transition-all flex flex-col gap-3 h-full card-inner <?= ($vals['listing_type'] ?? '')==='live'?'border-thrift-coral bg-red-50':'border-outline-variant' ?>">
              <span class="material-symbols-outlined text-2xl text-on-surface-variant">live_tv</span>
              <div>
                <p class="font-bold text-on-surface">Live Auction</p>
                <p class="text-xs text-on-surface-variant mt-1">Real-time bidding session. Anti-snipe rules apply. Ends on schedule.</p>
              </div>
            </div>
          </label>
        </div>
      </section>

      <!-- ITEM DETAILS -->
      <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-5">
        <h2 class="font-bold text-base text-on-surface">Item Details</h2>

        <div class="space-y-1">
          <label class="text-sm font-medium text-on-surface">Item Title <span class="text-thrift-coral">*</span></label>
          <input class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="title" type="text" placeholder="e.g. Vintage Levi's 501 Jeans (Size 30)" maxlength="200" value="<?= htmlspecialchars($vals['title'] ?? '') ?>" required>
        </div>

        <div class="space-y-1">
          <label class="text-sm font-medium text-on-surface">Description</label>
          <textarea class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm resize-none" name="description" rows="4" placeholder="Describe the item's style, fit, fabric, any flaws..."><?= htmlspecialchars($vals['description'] ?? '') ?></textarea>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div class="space-y-1">
            <label class="text-sm font-medium text-on-surface">Category <span class="text-thrift-coral">*</span></label>
            <select class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="category_id" required>
              <option value="">Select a category</option>
              <?php foreach ($categories as $c): ?>
              <option value="<?= $c['category_id'] ?>" <?= ($vals['category_id'] ?? 0)==$c['category_id']?'selected':'' ?>><?= htmlspecialchars($c['name']) ?></option>
              <?php endforeach; ?>
            </select>
          </div>
          <div class="space-y-1">
            <label class="text-sm font-medium text-on-surface">Item Condition <span class="text-thrift-coral">*</span></label>
            <select class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="item_condition">
              <?php foreach (['Like New','Very Good','Good','Fair','For Parts'] as $cond): ?>
              <option value="<?= $cond ?>" <?= ($vals['item_condition'] ?? 'Good')===$cond?'selected':'' ?>><?= $cond ?></option>
              <?php endforeach; ?>
            </select>
          </div>
        </div>

        <div class="space-y-1">
          <label class="text-sm font-medium text-on-surface">Image URL <span class="text-on-surface-variant font-normal">(optional)</span></label>
          <input class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="image_url" type="url" placeholder="https://..." value="<?= htmlspecialchars($vals['image_url'] ?? '') ?>">
          <p class="text-xs text-on-surface-variant">Paste a direct image link. Leave blank for a placeholder image.</p>
        </div>
      </section>

      <!-- PRICING (conditional) -->
      <section class="bg-white border border-outline-variant rounded-xl p-6 space-y-5" id="pricingSection">
        <h2 class="font-bold text-base text-on-surface">Pricing &amp; Auction Settings</h2>

        <!-- Fixed price -->
        <div id="fixedPriceField">
          <label class="text-sm font-medium text-on-surface block mb-1">Fixed Price (₱) <span class="text-thrift-coral">*</span></label>
          <div class="relative max-w-xs">
            <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-on-surface-variant">₱</span>
            <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="price" type="number" min="1" step="0.01" placeholder="0.00" value="<?= $vals['price'] ?? '' ?>">
          </div>
        </div>

        <!-- Auction fields -->
        <div id="auctionFields" class="hidden space-y-5">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
            <div class="space-y-1">
              <label class="text-sm font-medium text-on-surface">Starting Bid (₱) <span class="text-thrift-coral">*</span></label>
              <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-on-surface-variant">₱</span>
                <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="start_bid" type="number" min="1" step="0.01" placeholder="0.00" value="<?= $vals['start_bid'] ?? '' ?>">
              </div>
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium text-on-surface">Min. Increment (₱)</label>
              <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 font-bold text-on-surface-variant">₱</span>
                <input class="w-full pl-8 pr-4 py-3 border border-outline-variant rounded-lg text-sm" name="min_increment" type="number" min="1" step="0.01" value="<?= $vals['min_increment'] ?? '10' ?>">
              </div>
            </div>
            <div class="space-y-1">
              <label class="text-sm font-medium text-on-surface">Auction Duration</label>
              <select class="w-full border border-outline-variant rounded-lg px-4 py-3 text-sm" name="end_hours">
                <?php foreach ([6=>'6 hours',12=>'12 hours',24=>'1 day',48=>'2 days',72=>'3 days',168=>'7 days'] as $h=>$l): ?>
                <option value="<?= $h ?>" <?= ($vals['end_hours'] ?? 48)==$h?'selected':'' ?>><?= $l ?></option>
                <?php endforeach; ?>
              </select>
            </div>
          </div>
          <div class="p-4 bg-yellow-50 border border-yellow-200 rounded-lg text-xs text-yellow-700">
            <strong>Anti-Snipe Rule:</strong> If a bid is placed within the last 2 minutes, the auction extends by 2 minutes (max 10 extensions / +20 min total).
          </div>
        </div>

        <!-- Live fields note -->
        <div id="liveFields" class="hidden">
          <div class="p-4 bg-red-50 border border-thrift-coral/30 rounded-lg text-sm text-on-surface-variant">
            <strong class="text-thrift-coral">Live Auction:</strong> Same as non-live auction but the listing will be prominently featured on the Live Bids page with a countdown. Anti-snipe rules also apply.
          </div>
        </div>
      </section>

      <!-- Submit -->
      <div class="flex justify-end gap-4">
        <a href="/pages/seller/dashboard.php" class="px-6 py-3 border border-outline-variant text-on-surface-variant rounded-xl text-sm font-medium hover:bg-surface-container transition-colors">Cancel</a>
        <button type="submit" class="btn btn-primary px-10 py-3 rounded-xl font-bold">Publish Listing</button>
      </div>

    </form>
  </div>
</main>
</div>

<script>
const typeCards = document.querySelectorAll('.listing-type-card');
const fixedField    = document.getElementById('fixedPriceField');
const auctionFields = document.getElementById('auctionFields');
const liveFields    = document.getElementById('liveFields');

function applyType(type) {
  fixedField.classList.toggle('hidden',    type !== 'fixed');
  auctionFields.classList.toggle('hidden', type === 'fixed');
  liveFields.classList.toggle('hidden',    type !== 'live');
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

// Init from server state
const checked = document.querySelector('input[name=listing_type]:checked');
if (checked) applyType(checked.value);
</script>
</body></html>
