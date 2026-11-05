<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$path = getenv('STUDYBUDDY_TEST_CONFIG');
if (!$path || !is_file($path)) { fwrite(STDERR, "Test config required.\n"); exit(1); }
$config = require $path;
if (!str_starts_with($config['db']['name'] ?? '', 'studybuddy_test_')) { fwrite(STDERR, "Use a separate studybuddy_test_ database.\n"); exit(1); }
putenv('STUDYBUDDY_CONFIG=' . $path);
require dirname(__DIR__) . '/src/bootstrap.php';
$input = json_decode(stream_get_contents(STDIN), true, 32, JSON_THROW_ON_ERROR);
$email = $input['email'] ?? '';
if (!str_starts_with($email, 'sbtest_')) { fwrite(STDERR, "Only test fixtures are allowed.\n"); exit(1); }
if (($input['mode'] ?? '') === 'expire') {
    database()->prepare('UPDATE sessions s JOIN users u ON u.id = s.user_id SET s.expires_at = DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 SECOND) WHERE u.email = ? AND s.token_hash = ?')
        ->execute([$email, hash('sha256', $input['token'])]);
    echo '{"expired":true}';
} else {
    $query = database()->prepare('SELECT password_hash FROM users WHERE email = ?');
    $query->execute([$email]);
    $hash = $query->fetchColumn();
    $query = database()->prepare('SELECT COUNT(*) FROM sessions s JOIN users u ON u.id = s.user_id WHERE u.email = ? AND s.token_hash = ?');
    $query->execute([$email, hash('sha256', $input['token'])]);
    echo json_encode(['password_hashed' => $hash !== $input['password'] && password_verify($input['password'], $hash),
        'session_hashed' => (int)$query->fetchColumn() === 1], JSON_THROW_ON_ERROR);
}
