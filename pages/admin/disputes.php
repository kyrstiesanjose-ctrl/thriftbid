<?php
// pages/admin/disputes.php
// Order disputes now live inside Moderation (pages/admin/moderation.php?view=disputes).
// This file is kept only so old bookmarks/links don't 404 — it no longer
// contains any of its own logic, so there's nothing here to drift out of
// sync with moderation.php.
require_once __DIR__ . '/../../includes/auth.php';

$qs = $_GET;
unset($qs['view']);
$qs['view'] = 'disputes';

header('Location: ' . BASE_URL . '/pages/admin/moderation.php?' . http_build_query($qs));
exit;