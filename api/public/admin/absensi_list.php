<?php
require_once __DIR__.'/../../src/auth.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';


$who = auth_required('admin');
$pdo = db();
$month = $_GET['month'] ?? date('Y-m');
$start = $month.'-01';
$end = date('Y-m-t', strtotime($start));
$q = $pdo->prepare('SELECT a.*, k.nama, k.jabatan FROM absensi a JOIN karyawan k ON k.id_karyawan=a.id_karyawan WHERE a.tanggal BETWEEN ? AND ? ORDER BY a.tanggal DESC');
$q->execute([$start,$end]);
json(['data'=>$q->fetchAll()]);