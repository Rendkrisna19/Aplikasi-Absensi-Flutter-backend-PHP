<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$id = (int)($_GET['id_karyawan'] ?? 0);
if ($id<=0) json(['error'=>'id_karyawan?'],422);

$pdo = db();
$q = $pdo->prepare('SELECT id_jadwal,id_karyawan,jam_masuk,jam_pulang,toleransi_menit
                    FROM jadwal_karyawan WHERE id_karyawan=? LIMIT 1');
$q->execute([$id]);
$r = $q->fetch(PDO::FETCH_ASSOC);
json(['data'=>$r],200);
