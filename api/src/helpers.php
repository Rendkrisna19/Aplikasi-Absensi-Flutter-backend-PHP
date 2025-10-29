<?php
function json($data, $code = 200)
{
    http_response_code($code);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data);
    exit;
}

function body()
{
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

/** Ambil header Authorization dari berbagai sumber (XAMPP/CGI sering beda) */
function get_auth_header()
{
    if (!empty($_SERVER['HTTP_AUTHORIZATION'])) return $_SERVER['HTTP_AUTHORIZATION'];
    if (!empty($_SERVER['Authorization'])) return $_SERVER['Authorization'];
    if (!empty($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) return $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    if (function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        foreach ($headers as $k => $v) {
            if (strtolower($k) === 'authorization') return $v;
        }
    }
    return null;
}

function bearer_token()
{
    $h = get_auth_header();
    if ($h && stripos($h, 'Bearer ') === 0) return trim(substr($h, 7));
    return null;
}

/** Validasi token & ambil user */
function auth_required($role = 'karyawan')
{
    require_once __DIR__ . '/db.php';
    $pdo = db();
    $token = bearer_token();
    if (!$token) json(['error' => 'Unauthorized (no token)'], 401);

    $stmt = $pdo->prepare('SELECT st.id_karyawan, k.nama, k.jabatan, k.foto_wajah
    FROM session_tokens st
    JOIN karyawan k ON k.id_karyawan = st.id_karyawan
    WHERE st.token=? AND st.expires_at > NOW()
    LIMIT 1');
    $stmt->execute([$token]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) json(['error' => 'Unauthorized (invalid/expired)'], 401);
    return $row; // punya: id_karyawan, nama, jabatan, foto_wajah
}

function hash_password($p)
{
    return password_hash($p, PASSWORD_BCRYPT);
}
function check_password($p, $h)
{
    return password_verify($p, $h);
}
