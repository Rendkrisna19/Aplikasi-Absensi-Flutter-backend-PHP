<?php
// api/public/admin/jadwal_set.php
require_once __DIR__ . '/../../src/db.php';
require_once __DIR__ . '/../../src/helpers.php';
require_once __DIR__ . '/../../src/auth_admin.php';

$admin = auth_admin(); // validasi token admin

$in = body();
$idK   = (int)($in['id_karyawan'] ?? 0);
$jm    = trim($in['jam_masuk'] ?? '');
$jp    = trim($in['jam_pulang'] ?? '');
$tol   = (int)($in['toleransi_menit'] ?? 15);

if ($idK <= 0 || $jm === '' || $jp === '') {
  json(['error' => 'id_karyawan, jam_masuk, jam_pulang wajib diisi'], 422);
}

// validasi format HH:mm:ss sederhana
$re = '/^\d{2}:\d{2}:\d{2}$/';
if (!preg_match($re, $jm) || !preg_match($re, $jp)) {
  json(['error' => 'Format jam harus HH:mm:ss'], 422);
}

$pdo = db();

// pastikan karyawan ada
$cek = $pdo->prepare("SELECT id_karyawan FROM karyawan WHERE id_karyawan=? LIMIT 1");
$cek->execute([$idK]);
if (!$cek->fetch()) json(['error' => 'Karyawan tidak ditemukan'], 404);

// cek sudah ada jadwal?
$s = $pdo->prepare("SELECT id_jadwal FROM jadwal_karyawan WHERE id_karyawan=? LIMIT 1");
$s->execute([$idK]);
$exist = $s->fetch(PDO::FETCH_ASSOC);

if ($exist) {
  $u = $pdo->prepare("UPDATE jadwal_karyawan
                      SET jam_masuk=?, jam_pulang=?, toleransi_menit=?
                      WHERE id_karyawan=?");
  $u->execute([$jm, $jp, $tol, $idK]);
  json(['message' => 'Jadwal diperbarui', 'status' => 200], 200);
} else {
  $i = $pdo->prepare("INSERT INTO jadwal_karyawan(id_karyawan, jam_masuk, jam_pulang, toleransi_menit)
                      VALUES(?,?,?,?)");
  $i->execute([$idK, $jm, $jp, $tol]);
  json(['message' => 'Jadwal ditambahkan', 'status' => 200], 200);
}
