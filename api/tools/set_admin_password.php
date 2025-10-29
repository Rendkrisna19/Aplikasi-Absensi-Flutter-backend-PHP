<?php
require_once __DIR__.'/../src/db.php';
require_once __DIR__.'/../src/helpers.php';
$pdo = db();
$pdo->prepare('UPDATE admin SET password=? WHERE username=?')
->execute([hash_password('admin123'),'admin']);
echo "OK: password admin di-set ke admin123";