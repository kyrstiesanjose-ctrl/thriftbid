<?php
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/../includes/layout.php';
requireLogin('./login.php');

$user = currentUser();
// Mark all read
DB::query('UPDATE NOTIFICATIONS SET is_read=1 WHERE user_id=?', [$user['user_id']]);

$notifs = DB::fetchAll(
    'SELECT * FROM NOTIFICATIONS WHERE user_id=? ORDER BY created_at DESC LIMIT 60',
    [$user['user_id']]
);

$iconMap = ['BID'=>'gavel','ORDER'=>'package_2','AUCTION'=>'timer','SYSTEM'=>'notifications','PAYMENT'=>'payments','ALERT'=>'warning'];

renderHeadRoot('Notifications');
?>
<body class="flex flex-col min-h-screen" style="background:var(--clr-bg)">
<?php renderNavbar(''); ?>

<main style="flex:1;max-width:760px;margin:0 auto;padding:32px var(--sp-margin-desktop) 80px;width:100%">
  <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:24px">
    <h1 class="tb-page-title">Notifications</h1>
    <span style="font-size:var(--fs-label-sm);color:var(--clr-tertiary)"><?= count($notifs) ?> total</span>
  </div>

  <?php if (empty($notifs)): ?>
  <div style="text-align:center;padding:64px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);color:var(--clr-tertiary)">
    <span class="material-symbols-outlined icon-xl" style="color:var(--clr-outline);display:block;margin-bottom:12px">notifications_off</span>
    <p style="font-weight:700;font-size:var(--fs-headline-sm)">No notifications yet</p>
    <p style="margin-top:6px">Activity updates will appear here.</p>
  </div>
  <?php else: ?>
  <div style="display:flex;flex-direction:column;gap:2px">
    <?php
    $today = date('Y-m-d'); $yesterday = date('Y-m-d', strtotime('-1 day'));
    $currentDate = null;
    foreach ($notifs as $n):
      $nd = date('Y-m-d', strtotime($n['created_at']));
      if ($nd !== $currentDate) {
        $currentDate = $nd;
        $label = $nd === $today ? 'Today' : ($nd === $yesterday ? 'Yesterday' : date('M d, Y', strtotime($n['created_at'])));
        echo "<p style='font-size:var(--fs-label-sm);font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:var(--clr-tertiary);padding:16px 0 6px'>" . htmlspecialchars($label) . "</p>";
      }
      $icon = $iconMap[$n['notification_type']] ?? 'notifications';
    ?>
    <div style="display:flex;align-items:flex-start;gap:12px;padding:14px 16px;background:var(--clr-white);border:1px solid var(--clr-outline);border-radius:var(--radius-sm);<?= $n['is_read']==0?'border-left:3px solid var(--clr-coral)':'' ?>">
      <div style="width:36px;height:36px;border-radius:var(--radius-sm);background:<?= $n['is_read']==0?'rgba(255,107,107,0.1)':'var(--clr-surface-mid)' ?>;display:flex;align-items:center;justify-content:center;flex-shrink:0;color:var(--clr-coral)">
        <span class="material-symbols-outlined icon-sm"><?= $icon ?></span>
      </div>
      <div style="flex:1;min-width:0">
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:10px">
          <p style="font-weight:700;font-size:var(--fs-label-md);color:var(--clr-text)"><?= htmlspecialchars($n['title']) ?></p>
          <span style="font-size:11px;color:var(--clr-tertiary);white-space:nowrap"><?= date('h:i A', strtotime($n['created_at'])) ?></span>
        </div>
        <?php if ($n['message']): ?>
        <p style="font-size:var(--fs-label-sm);color:var(--clr-tertiary);margin-top:3px"><?= htmlspecialchars($n['message']) ?></p>
        <?php endif; ?>
      </div>
    </div>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>
</main>
<?php renderFooter(); ?>
</body></html>
