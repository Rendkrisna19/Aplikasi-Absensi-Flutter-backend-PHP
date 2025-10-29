<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$in=body();
$id=(int)($in['id_admin']??0);
$nama=trim($in['nama_admin']??'');
$user=trim($in['username']??'');
$email=trim($in['email']??'');
$pass=trim($in['password']??''); // opsional
if($id<=0||$nama===''||$user===''||$email==='') json(['error'=>'Data kurang'],422);

$pdo=db();
if($pass!==''){
  $hash=password_hash($pass,PASSWORD_BCRYPT);
  $pdo->prepare('UPDATE admin SET nama_admin=?, username=?, email=?, password=? WHERE id_admin=?')
      ->execute([$nama,$user,$email,$hash,$id]);
}else{
  $pdo->prepare('UPDATE admin SET nama_admin=?, username=?, email=? WHERE id_admin=?')
      ->execute([$nama,$user,$email,$id]);
}
json(['message'=>'Updated'],200);
