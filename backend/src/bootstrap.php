<?php
declare(strict_types=1);

date_default_timezone_set('UTC');
ini_set('display_errors', '0');

final class ApiError extends RuntimeException
{
    public function __construct(public readonly int $status, string $message)
    {
        parent::__construct($message);
    }
}

function app_config(): array
{
    static $config;
    if ($config === null) {
        $path = getenv('STUDYBUDDY_CONFIG') ?: dirname(__DIR__) . '/config.local.php';
        if (!is_file($path)) {
            throw new ApiError(503, 'Server belum dikonfigurasi. Hubungi pengelola aplikasi.');
        }
        $config = require $path;
        if (!is_array($config) || empty($config['db']) || empty($config['base_url'])) {
            throw new ApiError(503, 'Konfigurasi server belum lengkap.');
        }
        $config['base_url'] = rtrim($config['base_url'], '/');
    }
    return $config;
}

function database(): PDO
{
    static $pdo;
    if ($pdo === null) {
        $db = app_config()['db'];
        $pdo = new PDO(
            sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $db['host'], $db['port'], $db['name']),
            $db['user'], $db['password'],
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
             PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
             PDO::ATTR_EMULATE_PREPARES => false]
        );
        $pdo->exec("SET time_zone = '+00:00'");
    }
    return $pdo;
}

function json_response(array $data, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    header('X-Content-Type-Options: nosniff');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    exit;
}

function require_method(string $method): void
{
    if (($_SERVER['REQUEST_METHOD'] ?? '') !== $method) {
        header('Allow: ' . $method);
        throw new ApiError(405, 'Metode permintaan tidak didukung.');
    }
}

function input_data(): array
{
    if ((int)($_SERVER['CONTENT_LENGTH'] ?? 0) > 16384) {
        throw new ApiError(413, 'Data permintaan terlalu besar.');
    }
    $raw = file_get_contents('php://input', false, null, 0, 16385);
    if ($raw === false || strlen($raw) > 16384) {
        throw new ApiError(413, 'Data permintaan terlalu besar.');
    }
    try {
        $data = json_decode($raw, true, 32, JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        throw new ApiError(400, 'Format permintaan harus berupa JSON.');
    }
    if (!is_array($data) || array_is_list($data)) {
        throw new ApiError(400, 'Data permintaan tidak valid.');
    }
    return $data;
}

function text_field(array $data, string $key, int $max): string
{
    $value = $data[$key] ?? null;
    if (!is_string($value)) {
        throw new ApiError(422, 'Data ' . $key . ' wajib diisi.');
    }
    $value = trim($value);
    if ($value === '' || !mb_check_encoding($value, 'UTF-8') || mb_strlen($value, 'UTF-8') > $max || str_contains($value, "\0")) {
        throw new ApiError(422, 'Data ' . $key . ' tidak valid.');
    }
    return $value;
}

function email_field(array $data): string
{
    $email = strtolower(text_field($data, 'email', 254));
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new ApiError(422, 'Alamat email tidak valid.');
    }
    return $email;
}

function password_field(array $data, bool $registration = false): string
{
    $value = $data['password'] ?? null;
    if (!is_string($value) || strlen($value) > 72 || str_contains($value, "\0") || strlen($value) < ($registration ? 8 : 1)) {
        throw new ApiError(422, $registration ? 'Password harus 8 sampai 72 karakter/byte.' : 'Password tidak valid.');
    }
    return $value;
}

function rate_limit(string $key, int $limit, int $seconds): void
{
    $pdo = database();
    $cutoff = gmdate('Y-m-d H:i:s', time() - $seconds);
    $hash = hash('sha256', $key);
    $query = $pdo->prepare('INSERT INTO rate_limits (key_hash, window_started, attempts)
        VALUES (:key_hash, UTC_TIMESTAMP(), 1)
        ON DUPLICATE KEY UPDATE
        attempts = IF(window_started < :cutoff_a, 1, attempts + 1),
        window_started = IF(window_started < :cutoff_b, UTC_TIMESTAMP(), window_started)');
    $query->execute(['key_hash' => $hash, 'cutoff_a' => $cutoff, 'cutoff_b' => $cutoff]);
    $query = $pdo->prepare('SELECT attempts FROM rate_limits WHERE key_hash = ?');
    $query->execute([$hash]);
    if ((int)$query->fetchColumn() > $limit) {
        header('Retry-After: ' . $seconds);
        throw new ApiError(429, 'Terlalu banyak percobaan. Coba lagi beberapa saat nanti.');
    }
}

function current_user(): array
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (!preg_match('/^Bearer ([a-f0-9]{64})$/D', $header, $matches)) {
        throw new ApiError(401, 'Sesi login tidak tersedia. Silakan login kembali.');
    }
    $hash = hash('sha256', $matches[1]);
    $query = database()->prepare('SELECT u.*, s.token_hash FROM users u JOIN sessions s ON s.user_id = u.id
        WHERE s.token_hash = ? AND s.expires_at > UTC_TIMESTAMP()');
    $query->execute([$hash]);
    $user = $query->fetch();
    if (!$user) {
        throw new ApiError(401, 'Sesi login sudah berakhir. Silakan login kembali.');
    }
    return $user;
}

function public_profile(array $user): array
{
    return [
        'id' => (int)$user['id'], 'name' => $user['name'], 'email' => $user['email'],
        'profile_picture' => $user['avatar_filename'] === null ? null
            : app_config()['base_url'] . '/uploads/' . rawurlencode($user['avatar_filename']),
    ];
}

function run_endpoint(string $action): never
{
    try {
        $config = app_config();
        if (($config['environment'] ?? 'production') === 'production' && !in_array(strtolower((string)($_SERVER['HTTPS'] ?? '')), ['on', '1'], true)) {
            throw new ApiError(400, 'Server akun harus diakses melalui HTTPS.');
        }
        require __DIR__ . '/actions.php';
        dispatch($action);
    } catch (ApiError $error) {
        json_response(['success' => false, 'message' => $error->getMessage()], $error->status);
    } catch (Throwable $error) {
        error_log('StudyBuddy API: ' . get_class($error) . ': ' . $error->getMessage());
        json_response(['success' => false, 'message' => 'Layanan akun sedang bermasalah. Coba lagi nanti.'], 503);
    }
}
