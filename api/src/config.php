<?php
// Ubah sesuai environment (XAMPP / Laragon / hosting)
return [
'db' => [
'host' => '127.0.0.1',
'user' => 'root',
'pass' => '',
'name' => 'db_absensi.php',
'port' => 3306,
'charset' => 'utf8mb4'
],
'app' => [
'base_url' => 'http://localhost/absensi-api/public',
'upload_dir' => __DIR__ . '/../public/uploads',
'token_lifetime_hours' => 72
],
'cors' => [
'origins' => ['*'],
'methods' => ['GET','POST','PUT','DELETE','OPTIONS'],
'headers' => ['Content-Type','Authorization']
]
];