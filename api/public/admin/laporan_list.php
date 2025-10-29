<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$pdo = db();
$from = $_GET['from'] ?? date('Y-m-01');
$to   = $_GET['to']   ?? date('Y-m-d');
$idK  = (int)($_GET['id_karyawan'] ?? 0);

$sql = 'SELECT a.tanggal, a.jam_masuk, a.jam_pulang, a.status_absen,
               k.id_karyawan, k.nama, k.jabatan, a.foto_masuk, a.foto_pulang
        FROM absensi a JOIN karyawan k USING(id_karyawan)
        WHERE a.tanggal BETWEEN ? AND ?';
$par = [$from,$to];
if ($idK>0) { $sql .= ' AND a.id_karyawan=?'; $par[]=$idK; }
$sql .= ' ORDER BY a.tanggal DESC, a.id_absensi DESC LIMIT 500';

$st = $pdo->prepare($sql); $st->execute($par);
json(['data'=>$st->fetchAll()],200);
