<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

try {
    if (PHP_VERSION_ID < 80200 || !extension_loaded('pdo_mysql') || !extension_loaded('mbstring') || !extension_loaded('fileinfo')) {
        throw new RuntimeException('Gunakan PHP 8.2+ dengan pdo_mysql, mbstring, dan fileinfo aktif.');
    }
    $configPath = getenv('STUDYBUDDY_CONFIG') ?: dirname(__DIR__) . '/config.local.php';
    $existing = is_file($configPath) ? require $configPath : null;
    $host = getenv('STUDYBUDDY_DB_HOST') ?: ($existing['db']['host'] ?? '127.0.0.1');
    $port = (int)(getenv('STUDYBUDDY_DB_PORT') ?: ($existing['db']['port'] ?? 3306));
    $name = getenv('STUDYBUDDY_DB_NAME') ?: ($existing['db']['name'] ?? 'studybuddy_app');
    if (!in_array($host, ['localhost', '127.0.0.1'], true) || !preg_match('/^[a-zA-Z0-9_]{1,48}$/D', $name) || $port < 1 || $port > 65535) {
        throw new RuntimeException('Installer ditujukan ke MySQL lokal. Periksa host, port, dan nama database.');
    }
    $baseUrl = rtrim(getenv('STUDYBUDDY_BASE_URL') ?: ($existing['base_url'] ?? 'http://127.0.0.1:8080'), '/');
    $parts = parse_url($baseUrl);
    if (!is_array($parts) || !in_array($parts['scheme'] ?? '', ['http', 'https'], true) || empty($parts['host'])
        || isset($parts['user']) || isset($parts['pass']) || isset($parts['query']) || isset($parts['fragment'])) {
        throw new RuntimeException('Alamat server tidak valid.');
    }
    $admin = new PDO(sprintf('mysql:host=%s;port=%d;charset=utf8mb4', $host, $port),
        getenv('STUDYBUDDY_DB_ADMIN_USER') ?: 'root', getenv('STUDYBUDDY_DB_ADMIN_PASSWORD') ?: '',
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false]);
    $admin->exec('CREATE DATABASE IF NOT EXISTS `' . $name . '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
    $admin->exec('USE `' . $name . '`');
    $schema = file_get_contents(dirname(__DIR__) . '/database/schema.sql');
    if ($schema === false) {
        throw new RuntimeException('Berkas schema.sql tidak ditemukan.');
    }
    foreach (explode(';', $schema) as $statement) {
        if (trim($statement) !== '') {
            $admin->exec($statement);
        }
    }
    $appUser = $existing['db']['user'] ?? 'studybuddy_' . bin2hex(random_bytes(6));
    $appPassword = $existing['db']['password'] ?? bin2hex(random_bytes(24));
    if (!preg_match('/^studybuddy_[a-f0-9]{12}$/D', $appUser)) {
        throw new RuntimeException('Konfigurasi memakai akun database manual. Jalankan migrasi melalui administrator database.');
    }
    foreach (['localhost', '127.0.0.1'] as $accountHost) {
        $account = $admin->quote($appUser) . '@' . $admin->quote($accountHost);
        if ($existing === null) {
            $admin->exec('CREATE USER ' . $account . ' IDENTIFIED BY ' . $admin->quote($appPassword));
        }
        $admin->exec('GRANT SELECT, INSERT, UPDATE, DELETE ON `' . $name . '`.* TO ' . $account);
    }
    $config = [
        'environment' => getenv('STUDYBUDDY_ENV') ?: ($existing['environment'] ?? 'development'),
        'base_url' => $baseUrl, 'session_days' => 30,
        'dummy_hash' => $existing['dummy_hash'] ?? password_hash(bin2hex(random_bytes(24)), PASSWORD_DEFAULT),
        'db' => ['host' => $host, 'port' => $port, 'name' => $name, 'user' => $appUser, 'password' => $appPassword],
    ];
    $runtime = new PDO(sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $host, $port, $name), $appUser, $appPassword,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $runtime->query('SELECT 1');
    $text = "<?php\ndeclare(strict_types=1);\nreturn " . var_export($config, true) . ";\n";
    $temporaryPath = $configPath . '.tmp';
    if (file_put_contents($temporaryPath, $text, LOCK_EX) === false) {
        throw new RuntimeException('Tidak bisa menyimpan konfigurasi backend.');
    }
    chmod($temporaryPath, 0600);
    if (!rename($temporaryPath, $configPath)) {
        throw new RuntimeException('Tidak bisa mengganti konfigurasi backend.');
    }
    echo "Database dan tabel siap. Data akun yang sudah ada dipertahankan.\n";
    echo "Konfigurasi backend tersimpan. Akun database aplikasi memiliki akses data saja.\n";
    echo "Alamat API: " . $baseUrl . "\n";
} catch (PDOException $error) {
    fwrite(STDERR, "SQLSTATE: " . $error->getCode() . "; MySQL: " . ($error->errorInfo[1] ?? 'unknown') . PHP_EOL);
    exit(1);
} catch (Throwable $error) {
    fwrite(STDERR, $error->getMessage() . "\n");
    exit(1);
}
