<?php
require_once __DIR__.'/db.php';
require_once __DIR__.'/helpers.php';
$config = require __DIR__.'/config.php';


function issue_token(string $userType,int $userId){
global $config; $pdo = db();
$token = make_token();
$exp = (new DateTime('+'.(int)$config['app']['token_lifetime_hours'].' hours'))
->format('Y-m-d H:i:s');
$stmt = $pdo->prepare('INSERT INTO tokens(user_type,user_id,token,expired_at) VALUES (?,?,?,?)');
$stmt->execute([$userType,$userId,$token,$exp]);
return $token;
}


function auth_required($role=null){
$hdr = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
if (!preg_match('/Bearer\s+(\w{64})/',$hdr,$m)) json(['error'=>'Unauthorized'],401);
$token = $m[1]; $pdo = db();
$q = $pdo->prepare('SELECT * FROM tokens WHERE token=? AND expired_at>NOW()');
$q->execute([$token]);
$row = $q->fetch();
if(!$row) json(['error'=>'Invalid token'],401);
if($role && $row['user_type']!==$role) json(['error'=>'Forbidden'],403);
return $row; // ['user_type','user_id',...]
}