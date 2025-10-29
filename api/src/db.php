<?php
function db() {
  static $pdo;
  if ($pdo) return $pdo;

  $host = '127.0.0.1';
  $port = 3306;
  $dbname = 'db_absensi.php'; // <- PENTING! sama persis dengan dump kamu
  $user = 'root';
  $pass = '';                 // sesuaikan

  $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
  $pdo = new PDO($dsn, $user, $pass, [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
  ]);
  return $pdo;
}
