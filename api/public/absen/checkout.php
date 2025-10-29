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
  $tgl = $now->format('Y-m-d');
  $jam = $now->format('H:i:s');

  $fname = 'checkout_'.$id.'_'.$now->getTimestamp().'.jpg';
  $disk  = $dir.'/'.$fname;
  if (file_put_contents($disk,$bin)===false) json(['error'=>'Gagal simpan file'],500);
  $rel   = 'uploads/snaps/'.$fname;

  // pastikan sudah punya record hari ini (minimal jam_masuk dulu)
  $s=$pdo->prepare('SELECT id_absensi,jam_masuk,jam_pulang FROM absensi WHERE id_karyawan=? AND tanggal=? LIMIT 1');
  $s->execute([$id,$tgl]);
  $row=$s->fetch();
  if(!$row) json(['error'=>'Belum absen masuk hari ini'],409);
  if(!empty($row['jam_pulang'])) json(['error'=>'Sudah absen pulang'],409);

  $sql = 'UPDATE absensi SET jam_pulang=?, foto_pulang=? WHERE id_absensi=?';
  $st  = $pdo->prepare($sql);
  $ok  = $st->execute([$jam,$rel,(int)$row['id_absensi']]);

  if (!$ok) {
    $ei = $st->errorInfo();
    json(['error'=>'DB gagal simpan check-out','detail'=>$ei],500);
  }

  json(['message'=>'Check-out berhasil','jam_pulang'=>$jam,'foto'=>$rel],200);

} catch (Throwable $e) {
  json(['error'=>'Server error','detail'=>$e->getMessage()],500);
}
