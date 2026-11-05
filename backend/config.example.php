<?php
declare(strict_types=1);

// Copy to config.local.php for a manually configured server. Keep this file
// and config.local.php OUTSIDE the public document root.
return [
    'environment' => 'production',
    'base_url' => 'https://api.example.com',
    'session_days' => 30,
    'db' => [
        'host' => '127.0.0.1',
        'port' => 3306,
        'name' => 'studybuddy_app',
        'user' => 'studybuddy_app',
        'password' => 'CHANGE_ME',
    ],
];
