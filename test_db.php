<?php
// Load configuration to get credentials
require_once __DIR__ . '/includes/config.php';

// Connect without selecting a specific database
$conn = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, '', DB_PORT);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Query to show all databases the user has permission to see
$res = $conn->query("SHOW DATABASES");
echo "<h2>You have access to these databases:</h2>";
echo "<pre>";
while ($row = $res->fetch_array()) {
    echo $row[0] . "\n";
}
echo "</pre>";
$conn->close();
?>