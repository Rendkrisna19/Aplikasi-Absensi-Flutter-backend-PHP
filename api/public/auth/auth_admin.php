<?php
// api/src/auth_admin.php
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/helpers.php';

function auth_admin() {
  $headers = getallheaders();
  $auth = $headers['Authorization'] ?? $headers['authorization'] ?? '';
  if (!preg_match('/Bearer\s+([A-Za-z0-9]+)$/', $auth, $m)) {
    json(['error' => 'Unauthorized'], 401);
  }
  $token = $m[1];

  $pdo = db();
  $stmt = $pdo->prepare("SELECT user_id, expired_at FROM tokens WHERE user_type='admin' AND token=? LIMIT 1");
  $stmt->execute([$token]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);
  if (!$row) json(['error' => 'Invalid token'], 401);
  if (strtotime($row['expired_at']) < time()) json(['error'=>'Token expired'], 401);

  // ambil data admin
  $stmt = $pdo->prepare("SELECT id_admin, nama_admin, username, email FROM admin WHERE id_admin=? LIMIT 1");
  $stmt->execute([(int)$row['user_id']]);
  $admin = $stmt->fetch(PDO::FETCH_ASSOC);
  if (!$admin) json(['error' => 'Admin not found'], 401);

  return $admin;
}
