<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
$path = $argv[1] ?? dirname(__DIR__) . '/config.local.php';
if (!is_file($path)) { fwrite(STDERR, "Konfigurasi backend belum tersedia.\n"); exit(1); }
$config = require $path;
echo json_encode(['base_url' => $config['base_url'], 'environment' => $config['environment']], JSON_THROW_ON_ERROR);
