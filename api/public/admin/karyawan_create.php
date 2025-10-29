<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$in = body();
$nama = trim($in['nama'] ?? '');
$jab  = trim($in['jabatan'] ?? '');
$user = trim($in['username'] ?? '');
$pass = trim($in['password'] ?? '');
if ($nama===''||$jab===''||$user===''||$pass==='') json(['error'=>'Data kurang'],422);

$pdo = db();
$pdo->beginTransaction();
try{
  $pdo->prepare('INSERT INTO karyawan(nama,jabatan,status_aktif) VALUES (?,?, "aktif")')
      ->execute([$nama,$jab]);
  $id = (int)$pdo->lastInsertId();

  $hash = password_hash($pass, PASSWORD_BCRYPT);
  $pdo->prepare('INSERT INTO karyawan_cred(id_karyawan,username,password) VALUES (?,?,?)')
      ->execute([$id,$user,$hash]);

  // default jadwal
  $pdo->prepare('INSERT INTO jadwal_karyawan(id_karyawan,jam_masuk,jam_pulang,toleransi_menit)
                 VALUES (?,?,?,?)')->execute([$id,'08:00:00','17:00:00',15]);

  $pdo->commit();
  json(['message'=>'Karyawan dibuat','id_karyawan'=>$id],200);
}catch(Throwable $e){
  $pdo->rollBack();
  json(['error'=>'Gagal simpan','detail'=>$e->getMessage()],500);
}
