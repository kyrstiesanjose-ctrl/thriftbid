<?php
/* api/logout.php - destroys the session (logoutUser(), includes/auth.php) then bounces back to login */
require_once __DIR__ . '/../includes/auth.php';
logoutUser();


header('Location: ../pages/login.php');
exit;
?>