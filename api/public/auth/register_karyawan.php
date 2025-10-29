<?php
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
// (opsional) require_once __DIR__.'/../_bootstrap.php';

$input   = body();
$nama    = trim($input['nama'] ?? '');
$jabatan = trim($input['jabatan'] ?? '');
$username= trim($input['username'] ?? '');
$password= trim($input['password'] ?? '');

if ($nama==='' || $jabatan==='' || $username==='' || $password==='') {
  json(['error'=>'Data kurang'],422);
}

$pdo = db();

/* PASTIKAN TABEL SUDAH ADA (DDL DI LUAR TRANSAKSI) */
$pdo->exec("CREATE TABLE IF NOT EXISTS karyawan_cred (
  id_karyawan INT PRIMARY KEY,
  username VARCHAR(60) UNIQUE,
  password VARCHAR(255) NOT NULL,
  FOREIGN KEY (id_karyawan) REFERENCES karyawan(id_karyawan) ON DELETE CASCADE
) ENGINE=InnoDB");

try {
  $pdo->beginTransaction();

  // karyawan
  $pdo->prepare('INSERT INTO karyawan(nama,jabatan) VALUES (?,?)')
      ->execute([$nama,$jabatan]);
  $idK = (int)$pdo->lastInsertId();

  // cred
  $stmt = $pdo->prepare('INSERT INTO karyawan_cred(id_karyawan,username,password) VALUES (?,?,?)');
  $stmt->execute([$idK,$username,hash_password($password)]);

  $pdo->commit();
  json(['message'=>'Registrasi karyawan berhasil','id_karyawan'=>$idK],201);

} catch (PDOException $e) {
  if ($pdo->inTransaction()) { $pdo->rollBack(); }

  // duplikat username
  if (isset($e->errorInfo[1]) && (int)$e->errorInfo[1] === 1062) {
    json(['error'=>'Username sudah dipakai'],409);
  }
  json(['error'=>'Server error','detail'=>$e->getMessage()],500);
} catch (Throwable $e) {
  if ($pdo->inTransaction()) { $pdo->rollBack(); }
  json(['error'=>'Server error','detail'=>$e->getMessage()],500);
}
