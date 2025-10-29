<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$pdo = db();
$search = trim($_GET['q'] ?? '');
if ($search!=='') {
  $q = $pdo->prepare('SELECT id_karyawan,nama,jabatan,status_aktif,COALESCE(foto_wajah,"") foto_wajah
                      FROM karyawan WHERE nama LIKE ? OR jabatan LIKE ? ORDER BY id_karyawan DESC LIMIT 200');
  $like = "%$search%";
  $q->execute([$like,$like]);
} else {
  $q = $pdo->query('SELECT id_karyawan,nama,jabatan,status_aktif,COALESCE(foto_wajah,"") foto_wajah
                    FROM karyawan ORDER BY id_karyawan DESC LIMIT 200');
}
json(['data'=>$q->fetchAll()],200);
