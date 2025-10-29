<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$in  = body();
$id  = (int)($in['id_karyawan'] ?? 0);
$nama= trim($in['nama'] ?? '');
$jab = trim($in['jabatan'] ?? '');
$stat= trim($in['status_aktif'] ?? 'aktif');
if ($id<=0 || $nama==='' || $jab==='') json(['error'=>'Data kurang'],422);

$pdo = db();
$pdo->prepare('UPDATE karyawan SET nama=?, jabatan=?, status_aktif=? WHERE id_karyawan=?')
    ->execute([$nama,$jab,$stat,$id]);

// opsional ganti cred
if (!empty($in['username']) || !empty($in['password'])) {
  $row = $pdo->prepare('SELECT 1 FROM karyawan_cred WHERE id_karyawan=?'); $row->execute([$id]);
  $exists = $row->fetchColumn() ? true : false;

  if (!empty($in['username']) && !empty($in['password'])) {
    $hash = password_hash($in['password'], PASSWORD_BCRYPT);
    if ($exists)
      $pdo->prepare('UPDATE karyawan_cred SET username=?, password=? WHERE id_karyawan=?')
          ->execute([$in['username'],$hash,$id]);
    else
      $pdo->prepare('INSERT INTO karyawan_cred(id_karyawan,username,password) VALUES (?,?,?)')
          ->execute([$id,$in['username'],$hash]);
  }
}

json(['message'=>'Updated'],200);
