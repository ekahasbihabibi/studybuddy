<?php
declare(strict_types=1);

// Explicit routes keep PHP 8.2+ development-server behavior consistent, including
// a real 404 for deleted avatars and unknown paths.
$path = rawurldecode(parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/');
if (preg_match('#^/uploads/[a-f0-9]{32}\.(jpg|png|webp)$#D', $path)
    && is_file(__DIR__ . '/public' . $path)) {
    header('X-Content-Type-Options: nosniff');
    return false;
}
require __DIR__ . '/src/bootstrap.php';
if ($path === '/') run_endpoint('health');
if (preg_match('#^/(health|register|login|logout|get_profile|update_profile|upload_profile|delete_profile_picture|insert_score|get_leaderboard_by_subject|get_all_leaderboard)\.php$#D', $path, $matches)) {
    run_endpoint($matches[1]);
}
json_response(['success' => false, 'message' => 'Layanan tidak ditemukan.'], 404);
