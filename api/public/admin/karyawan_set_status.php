<?php
require_once __DIR__.'/../../src/auth.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';


$who = auth_required('admin');
$input = body();
$id = (int)($input['id_karyawan'] ?? 0);
$status = $input['status_aktif'] ?? 'aktif';
if(!in_array($status,['aktif','non-aktif'],true)) json(['error'=>'status tidak valid'],422);
$pdo = db();
$st = $pdo->prepare('UPDATE karyawan SET status_aktif=? WHERE id_karyawan=?');
$st->execute([$status,$id]);
json(['message'=>'OK']);