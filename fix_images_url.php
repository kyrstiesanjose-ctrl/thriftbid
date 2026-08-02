<?php
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/db.php';

echo "Detected BASE_URL: " . BASE_URL . "<br><br>";

$rows = DB::fetchAll("SELECT image_id, image_url FROM LISTING_IMAGES WHERE image_url LIKE '/uploads/listings/%'");

echo "Found " . count($rows) . " image(s) to fix.<br><br>";

foreach ($rows as $row) {
    $newUrl = BASE_URL . $row['image_url'];
    DB::query('UPDATE LISTING_IMAGES SET image_url = ? WHERE image_id = ?', [$newUrl, $row['image_id']]);
    echo "Fixed image_id {$row['image_id']}: {$row['image_url']} → {$newUrl}<br>";
}

echo "<br>Done.";   