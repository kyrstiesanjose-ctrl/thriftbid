<?php
// pages/admin/reported-listings.php
// Listing reports now live inside Moderation (pages/admin/moderation.php?view=reports).
// Kept only so old bookmarks/links don't 404 — no logic lives here anymore,
// so there's nothing left that can drift out of sync with moderation.php.
require_once __DIR__ . '/../../includes/auth.php';

$qs = $_GET;
unset($qs['view']);
$qs['view'] = 'reports';

header('Location: ' . BASE_URL . '/pages/admin/moderation.php?' . http_build_query($qs));
exit;