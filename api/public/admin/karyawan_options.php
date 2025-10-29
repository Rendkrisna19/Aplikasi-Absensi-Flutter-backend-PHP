<?php
require_once __DIR__ . '/../../src/db.php';
require_once __DIR__ . '/../../src/helpers.php';

auth_admin(); // pastikan admin

$pdo = db();
$stmt = $pdo->query("SELECT id_karyawan, nama FROM karyawan WHERE status_aktif='aktif' ORDER BY nama ASC");
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

json(['data' => $rows, 'status' => 200], 200);
