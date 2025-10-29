<?php
// api/public/_bootstrap_json.php
declare(strict_types=1);

/* ===== JSON-only hardening ===== */
header('Content-Type: application/json; charset=utf-8');

// Matikan tampilan error ke output, tapi tetap log ke error_log
ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

// Buang SEMUA output buffer yang mungkin aktif sebelum ini
while (ob_get_level() > 0) { ob_end_clean(); }

// Start output buffer yang MENOLAK semua output non-JSON
ob_start(function ($buffer) {
  // Jangan kirim apa pun selain apa yang kita echo di json()
  // Tapi log supaya bisa didiagnosa.
  $trim = trim($buffer);
  if ($trim !== '') {
    error_log("[JSON-FW] Stray output blocked: " . substr($trim, 0, 200));
  }
  return ''; // telan semua output
});

// Convert warning/notice ke Exception → nanti kita tangani sebagai JSON 500
set_error_handler(function ($sev, $msg, $file, $line) {
  if (!(error_reporting() & $sev)) return;
  throw new ErrorException($msg, 0, $sev, $file, $line);
});

// CORS (opsional, aktifkan kalau FE beda domain)
if (!headers_sent()) {
  header('Access-Control-Allow-Origin: *');
  header('Access-Control-Allow-Headers: Authorization, Content-Type');
  header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
}
if (strtoupper($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
  http_response_code(204);
  // Tutup buffer & keluar tanpa output text
  while (ob_get_level() > 0) { ob_end_clean(); }
  exit;
}

/* ===== Helper json() yang bersih & pasti exit ===== */
if (!function_exists('json')) {
  function json(array $payload, int $code = 200): void {
    if (!headers_sent()) {
      header('Content-Type: application/json; charset=utf-8', true, $code);
    }
    // Pastikan tidak ada output lain
    while (ob_get_level() > 0) { ob_end_clean(); }
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
  }
}
