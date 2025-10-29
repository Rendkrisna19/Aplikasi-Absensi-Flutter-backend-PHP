<?php
require_once __DIR__ . '/../src/bootstrap.php';
// export: boleh tanpa auth_admin() jika publik, tapi idealnya tetap butuh admin:
auth_admin();

$from = trim((string)($_GET['from'] ?? ''));
$to   = trim((string)($_GET['to'] ?? ''));
$idk  = trim((string)($_GET['id_karyawan'] ?? ''));

if ($from === '' || $to === '') {
  http_response_code(422);
  header('Content-Type: application/json; charset=utf-8');
  echo json_encode(['error'=>'Parameter from/to wajib']);
  exit;
}

$pdo = db();
$sql = "SELECT 
    a.id_absen,
    a.id_karyawan,
    k.nama,
    k.jabatan,
    a.tanggal,
    a.jam_masuk,
    a.jam_pulang,
    a.status_absen,
    a.catatan
  FROM absensi a
  JOIN karyawan k ON k.id_karyawan = a.id_karyawan
  WHERE a.tanggal BETWEEN :from AND :to";
$params = [':from' => $from, ':to' => $to];

if ($idk !== '') {
  $sql .= " AND a.id_karyawan = :idk";
  $params[':idk'] = (int)$idk;
}
$sql .= " ORDER BY a.tanggal DESC, a.id_absen DESC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);

// Set headers CSV
$fname = 'laporan_absensi_' . date('Ymd_His') . '.csv';
header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="'.$fname.'"');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

$out = fopen('php://output', 'w');
// Header CSV
fputcsv($out, [
  'id_absen','id_karyawan','nama','jabatan','tanggal','jam_masuk','jam_pulang','status_absen','catatan'
]);

while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
  fputcsv($out, [
    $row['id_absen'],
    $row['id_karyawan'],
    $row['nama'],
    $row['jabatan'],
    $row['tanggal'],
    $row['jam_masuk'],
    $row['jam_pulang'],
    $row['status_absen'],
    $row['catatan'],
  ]);
}
fclose($out);
exit;
