<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$in = body();
$id = (int)($in['id_karyawan'] ?? 0);
$jm = trim($in['jam_masuk'] ?? '08:00:00');
$jp = trim($in['jam_pulang'] ?? '17:00:00');
$tol= (int)($in['toleransi_menit'] ?? 15);
if ($id<=0) json(['error'=>'id_karyawan kosong'],422);

$pdo = db();
$ok = $pdo->prepare('INSERT INTO jadwal_karyawan(id_karyawan,jam_masuk,jam_pulang,toleransi_menit)
                     VALUES (?,?,?,?)
                     ON DUPLICATE KEY UPDATE
                       jam_masuk=VALUES(jam_masuk),
                       jam_pulang=VALUES(jam_pulang),
                       toleransi_menit=VALUES(toleransi_menit)')
          ->execute([$id,$jm,$jp,$tol]);

json(['message'=>'Jadwal disimpan'],200);
