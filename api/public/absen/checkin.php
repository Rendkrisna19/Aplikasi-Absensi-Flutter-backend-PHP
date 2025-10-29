<?php
require_once __DIR__ . '/../_bootstrap.php';
require_once __DIR__ . '/../../src/db.php';
require_once __DIR__ . '/../../src/helpers.php';

try {
  $auth = auth_required('karyawan');
  $id   = (int)$auth['id_karyawan'];

  $pdo = db();
  $in  = body();
  $img = $in['image_base64'] ?? '';
  if (!$img || strpos($img,'base64,')===false) json(['error'=>'Gambar kosong'],400);

  $bin = base64_decode(explode('base64,',$img,2)[1]);
  if ($bin===false) json(['error'=>'Decode gagal'],400);

  $dir = __DIR__.'/../uploads/snaps';
  if (!is_dir($dir)) mkdir($dir,0777,true);

  $now = new DateTime('now');
  $tgl = $now->format('Y-m-d');  // DATE kolommu
  $jam = $now->format('H:i:s');  // TIME kolommu

  $fname = 'checkin_'.$id.'_'.$now->getTimestamp().'.jpg';
  $disk  = $dir.'/'.$fname;
  if (file_put_contents($disk,$bin)===false) json(['error'=>'Gagal simpan file'],500);
  $rel   = 'uploads/snaps/'.$fname;

  // hitung status hadir/terlambat dari jadwal_karyawan
  $s = $pdo->prepare('SELECT jam_masuk, toleransi_menit FROM jadwal_karyawan WHERE id_karyawan=? LIMIT 1');
  $s->execute([$id]);
  $jdw = $s->fetch();
  if (!$jdw) json(['error'=>'Jadwal belum di-set'],422);

  $deadline = DateTime::createFromFormat('H:i:s',$jdw['jam_masuk']);
  $deadline->modify('+'.(int)$jdw['toleransi_menit'].' minutes');
  $status   = (DateTime::createFromFormat('H:i:s',$jam) <= $deadline) ? 'hadir' : 'terlambat';

  // UPSERT: kalau sudah ada baris (unik id_karyawan+tanggal), lakukan UPDATE
  $sql = 'INSERT INTO absensi (id_karyawan,tanggal,jam_masuk,status_absen,foto_masuk)
          VALUES (?,?,?,?,?)
          ON DUPLICATE KEY UPDATE
            jam_masuk=IF(jam_masuk IS NULL, VALUES(jam_masuk), jam_masuk),
            status_absen=IF(jam_masuk IS NULL, VALUES(status_absen), status_absen),
            foto_masuk=IF(jam_masuk IS NULL, VALUES(foto_masuk), foto_masuk)';
  $stmt = $pdo->prepare($sql);
  $ok = $stmt->execute([$id,$tgl,$jam,$status,$rel]);

  if (!$ok) {
    $ei = $stmt->errorInfo();
    json(['error'=>'DB gagal simpan check-in','detail'=>$ei],500);
  }

  json(['message'=>"Check-in $status",'status_absen'=>$status,'jam_masuk'=>$jam,'foto'=>$rel],200);

} catch (Throwable $e) {
  json(['error'=>'Server error','detail'=>$e->getMessage()],500);
}
