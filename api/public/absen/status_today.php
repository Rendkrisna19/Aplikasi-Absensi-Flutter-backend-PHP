<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';

$auth=auth_required('karyawan');
$id=(int)$auth['id_karyawan'];
$tgl=date('Y-m-d');

$pdo=db();
$q=$pdo->prepare('SELECT jam_masuk,jam_pulang FROM absensi WHERE id_karyawan=? AND tanggal=? LIMIT 1');
$q->execute([$id,$tgl]);
$r=$q->fetch();

json(['data'=>[
  'checked_in'  => !empty($r['jam_masuk']),
  'checked_out' => !empty($r['jam_pulang']),
  'jam_masuk'   => $r['jam_masuk'] ?? null,
  'jam_pulang'  => $r['jam_pulang'] ?? null,
]],200);
