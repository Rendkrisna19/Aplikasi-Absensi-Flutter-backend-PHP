<?php
// Boleh dibiarkan kosong jika akses file langsung. Ini hanya contoh.
if($_SERVER['REQUEST_METHOD']==='OPTIONS'){
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS');
exit;
}
http_response_code(404);
header('Content-Type: application/json');
echo json_encode(['error'=>'Not found','hint'=>'akses file endpoint langsung, mis: /auth/login.php']);