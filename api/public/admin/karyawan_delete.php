<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$in = body();
$id = (int)($in['id_karyawan'] ?? 0);
if ($id<=0) json(['error'=>'id_karyawan kosong'],422);

$pdo = db();
$pdo->prepare('DELETE FROM karyawan WHERE id_karyawan=?')->execute([$id]); // FK akan cascade
json(['message'=>'Deleted'],200);
