<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require dirname(__DIR__) . '/src/bootstrap.php';
try {
    $sessions = database()->exec('DELETE FROM sessions WHERE expires_at <= UTC_TIMESTAMP()');
    $limits = database()->exec('DELETE FROM rate_limits WHERE window_started < DATE_SUB(UTC_TIMESTAMP(), INTERVAL 1 DAY)');
    echo "Expired sessions removed: $sessions; old rate-limit records removed: $limits\n";
} catch (Throwable) {
    fwrite(STDERR, "Pembersihan gagal. Periksa koneksi database dan konfigurasi backend.\n");
    exit(1);
}
