<?php
// api/public/auth/login.php
require_once __DIR__ . '/../../src/db.php';
require_once __DIR__ . '/../../src/helpers.php';

$input    = body();
$username = trim($input['username'] ?? '');
$password = trim($input['password'] ?? '');
$role     = strtolower(trim($input['role'] ?? 'karyawan')); // 'karyawan' | 'admin'

if ($username === '' || $password === '') {
  json(['error' => 'Data kurang'], 422);
}

$pdo = db();

if ($role === 'admin') {
  // ===== ADMIN LOGIN =====

  // 1) BOOTSTRAP admin pertama bila tabel admin kosong:
  $count = (int)$pdo->query("SELECT COUNT(*) FROM admin")->fetchColumn();
  if ($count === 0) {
    // Auto-create first admin dari kredensial yang diketik user pada form login
    $stmt = $pdo->prepare("INSERT INTO admin(nama_admin, username, password, email) VALUES(?,?,?,?)");
    $ok = $stmt->execute([
      // Nama default = username, email default = username@example.com (bisa diedit nanti dari UI admin)
      $username,
      $username,
      password_hash($password, PASSWORD_BCRYPT),
      filter_var($username, FILTER_VALIDATE_EMAIL) ? $username : ($username . '@example.com'),
    ]);
    if (!$ok) {
      json(['error' => 'Gagal membuat admin pertama'], 500);
    }
  }

  // 2) Verifikasi kredensial admin
  $stmt = $pdo->prepare("SELECT id_admin, password FROM admin WHERE username = ? LIMIT 1");
  $stmt->execute([$username]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);

  if (!$row || !password_verify($password, $row['password'])) {
    json(['error' => 'Username/Password salah'], 401);
  }

  // 3) Buat token untuk admin → simpan di tabel tokens
  $token   = bin2hex(random_bytes(32));
  $expired = date('Y-m-d H:i:s', time() + 86400 * 3); // 3 hari

  $ins = $pdo->prepare("INSERT INTO tokens(user_type, user_id, token, expired_at) VALUES('admin', ?, ?, ?)");
  $ins->execute([(int)$row['id_admin'], $token, $expired]);

  json(['message' => 'OK', 'token' => $token, 'expires' => $expired, 'status' => 200], 200);

} else {
  // ===== KARYAWAN LOGIN =====
  $stmt = $pdo->prepare(
    'SELECT k.id_karyawan, c.password 
     FROM karyawan k
     JOIN karyawan_cred c ON c.id_karyawan = k.id_karyawan
     WHERE c.username = ? LIMIT 1'
  );
  $stmt->execute([$username]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);
  if (!$row || !password_verify($password, $row['password'])) {
    json(['error' => 'Username/Password salah'], 401);
  }

  $idK    = (int)$row['id_karyawan'];
  $token  = bin2hex(random_bytes(32));
  $expire = date('Y-m-d H:i:s', time() + 86400 * 3); // 3 hari

  // pakai tabel session_tokens (sesuai skema awal kamu)
  $pdo->prepare('INSERT INTO session_tokens(id_karyawan, token, expires_at) VALUES (?,?,?)')
      ->execute([$idK, $token, $expire]);

  json(['message' => 'OK', 'token' => $token, 'expires' => $expire, 'status' => 200], 200);
}
