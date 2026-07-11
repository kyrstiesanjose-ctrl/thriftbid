<?php
// api/logout.php
require_once __DIR__ . '/../includes/auth.php';
logoutUser();


header('Location: ../pages/login.php');
exit;
?>