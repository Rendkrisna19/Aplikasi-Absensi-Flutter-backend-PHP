<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';

$auth=auth_required('karyawan');
$id=(int)$auth['id_karyawan'];

$in=body();
$img=$in['image_base64'] ?? '';
if(!$img || strpos($img,'base64,')===false) json(['error'=>'Gambar kosong'],400);

$bin=base64_decode(explode('base64,',$img,2)[1]);
if($bin===false) json(['error'=>'Decode gagal'],400);

$dir=__DIR__.'/../uploads/faces';
if(!is_dir($dir)) mkdir($dir,0777,true);

$fname='face_'.$id.'_'.time().'.jpg';
$disk=$dir.'/'.$fname;
if(file_put_contents($disk,$bin)===false) json(['error'=>'Gagal simpan file'],500);

$rel='uploads/faces/'.$fname;
$pdo=db();
$pdo->prepare('UPDATE karyawan SET foto_wajah=? WHERE id_karyawan=?')->execute([$rel,$id]);

json(['message'=>'Wajah tersimpan','path'=>$rel],200);
