<?php
require_once __DIR__.'/db.php';
require_once __DIR__.'/helpers.php';

function admin_auth_required(){
  $pdo = db();
  $t = bearer_token();
  if (!$t) json(['error'=>'Unauthorized (no token)'],401);

  $q = $pdo->prepare('SELECT user_id FROM tokens WHERE user_type="admin" AND token=? AND expired_at>NOW() LIMIT 1');
  $q->execute([$t]);
  $r = $q->fetch(PDO::FETCH_ASSOC);
  if (!$r) json(['error'=>'Unauthorized (invalid/expired)'],401);

  return ['id_admin'=>(int)$r['user_id']];
}
