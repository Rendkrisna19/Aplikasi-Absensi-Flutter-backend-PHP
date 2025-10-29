<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET,POST,OPTIONS,PUT,DELETE');
if ($_SERVER['REQUEST_METHOD']==='OPTIONS') { http_response_code(204); exit; }

set_exception_handler(function($e){
  http_response_code(500);
  echo json_encode(['error'=>'Server error','detail'=>$e->getMessage()]);
  exit;
});
set_error_handler(function($sev,$msg,$file,$line){
  http_response_code(500);
  echo json_encode(['error'=>'PHP error','detail'=>"$msg @ $file:$line"]);
  exit;
});
