<?php
require_once __DIR__.'/../_bootstrap.php';
require_once __DIR__.'/../../src/db.php';
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/admin_guard.php';
admin_auth_required();

$in=body();
$nama=trim($in['nama_admin']??'');
$user=trim($in['username']??'');
$pass=trim($in['password']??'');
$email=trim($in['email']??'');
if($nama===''||$user===''||$pass===''||$email==='') json(['error'=>'Data kurang'],422);

$pdo=db();
$hash=password_hash($pass,PASSWORD_BCRYPT);
$pdo->prepare('INSERT INTO admin(nama_admin,username,password,email) VALUES (?,?,?,?)')
    ->execute([$nama,$user,$hash,$email]);
json(['message'=>'Admin dibuat'],200);
