<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$pdo = db();
$q = $pdo->query('SELECT id_admin,nama_admin,username,email,created_at FROM admin ORDER BY id_admin DESC LIMIT 200');
json(['data'=>$q->fetchAll()],200);
