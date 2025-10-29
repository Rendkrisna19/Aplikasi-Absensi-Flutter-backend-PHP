<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';

$auth=auth_required('karyawan');
$id=(int)$auth['id_karyawan'];

$pdo=db();
$q=$pdo->prepare('SELECT tanggal, jam_masuk, jam_pulang, status_absen, foto_masuk, foto_pulang
                  FROM absensi WHERE id_karyawan=? ORDER BY tanggal DESC, id_absensi DESC LIMIT 100');
$q->execute([$id]);
json(['data'=>$q->fetchAll()],200);
