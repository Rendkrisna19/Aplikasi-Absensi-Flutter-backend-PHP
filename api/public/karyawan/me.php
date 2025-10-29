<?php
require_once __DIR__.'/../../src/helpers.php';
require_once __DIR__.'/../../src/db.php';

$auth = auth_required('karyawan'); // -> id_karyawan
$pdo = db();
$stmt = $pdo->prepare('SELECT id_karyawan, nama, jabatan, COALESCE(foto_wajah,"") AS foto_wajah
                       FROM karyawan WHERE id_karyawan=? LIMIT 1');
$stmt->execute([$auth['id_karyawan']]);
$user = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];

json(['data'=>$user], 200);
