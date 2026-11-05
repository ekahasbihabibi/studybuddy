<?php
declare(strict_types=1);

function dispatch(string $action): never
{
    if ($action === 'health') {
        require_method('GET');
        database()->query('SELECT 1');
        json_response(['success' => true, 'service' => 'StudyBuddy API', 'database' => 'connected']);
    }
    if ($action === 'register') {
        require_method('POST');
        $data = input_data();
        $email = email_field($data);
        $name = text_field($data, 'name', 100);
        $password = password_field($data, true);
        rate_limit('register:' . ($_SERVER['REMOTE_ADDR'] ?? ''), 20, 3600);
        $query = database()->prepare('INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)');
        try {
            $query->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT)]);
        } catch (PDOException $error) {
            if (($error->errorInfo[1] ?? null) === 1062) {
                throw new ApiError(409, 'Email sudah terdaftar. Silakan login.');
            }
            throw $error;
        }
        json_response(['success' => true, 'message' => 'Akun berhasil dibuat. Silakan login.'], 201);
    }
    if ($action === 'login') {
        require_method('POST');
        $data = input_data();
        $email = email_field($data);
        $password = password_field($data);
        $ip = $_SERVER['REMOTE_ADDR'] ?? '';
        rate_limit('login-ip:' . $ip, 120, 900);
        rate_limit('login-account:' . $ip . ':' . $email, 15, 900);
        $query = database()->prepare('SELECT * FROM users WHERE email = ?');
        $query->execute([$email]);
        $user = $query->fetch();
        $dummyHash = app_config()['dummy_hash'] ?? password_hash(bin2hex(random_bytes(24)), PASSWORD_DEFAULT);
        $valid = password_verify($password, $user ? $user['password_hash'] : $dummyHash);
        if (!$user || !$valid) {
            throw new ApiError(401, 'Email atau password tidak sesuai.');
        }
        if (password_needs_rehash($user['password_hash'], PASSWORD_DEFAULT)) {
            database()->prepare('UPDATE users SET password_hash = ? WHERE id = ?')
                ->execute([password_hash($password, PASSWORD_DEFAULT), $user['id']]);
        }
        $token = bin2hex(random_bytes(32));
        $expiry = gmdate('Y-m-d H:i:s', time() + 86400 * (int)(app_config()['session_days'] ?? 30));
        database()->prepare('INSERT INTO sessions (user_id, token_hash, expires_at) VALUES (?, ?, ?)')
            ->execute([$user['id'], hash('sha256', $token), $expiry]);
        json_response(['success' => true, 'access_token' => $token, 'token_type' => 'Bearer',
            'expires_at' => str_replace(' ', 'T', $expiry) . 'Z', 'user' => public_profile($user)]);
    }

    $user = current_user();
    if ($action === 'logout') {
        require_method('POST');
        database()->prepare('DELETE FROM sessions WHERE token_hash = ?')->execute([$user['token_hash']]);
        json_response(['success' => true, 'message' => 'Berhasil logout dari perangkat ini.']);
    }
    if ($action === 'get_profile') {
        require_method('GET');
        json_response(['success' => true] + public_profile($user));
    }
    if ($action === 'update_profile') {
        require_method('POST');
        $name = text_field(input_data(), 'name', 100);
        database()->prepare('UPDATE users SET name = ? WHERE id = ?')->execute([$name, $user['id']]);
        json_response(['success' => true, 'message' => 'Profil berhasil diperbarui.']);
    }
    if ($action === 'upload_profile') {
        require_method('POST');
        upload_avatar($user);
    }
    if ($action === 'delete_profile_picture') {
        require_method('POST');
        remove_avatar(replace_avatar((int)$user['id'], null));
        json_response(['success' => true, 'message' => 'Foto profil berhasil dihapus.']);
    }
    if ($action === 'insert_score') {
        require_method('POST');
        $data = input_data();
        $subject = text_field($data, 'subject', 120);
        $score = filter_var($data['score'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 0, 'max_range' => 100000]]);
        if ($score === false || $score === null) {
            throw new ApiError(422, 'Skor kuis tidak valid.');
        }
        rate_limit('scores:' . $user['id'], 120, 3600);
        database()->prepare('INSERT INTO quiz_scores (user_id, subject, score) VALUES (?, ?, ?)')
            ->execute([$user['id'], $subject, $score]);
        json_response(['success' => true, 'message' => 'Skor berhasil disimpan.'], 201);
    }
    if ($action === 'get_leaderboard_by_subject' || $action === 'get_all_leaderboard') {
        require_method('GET');
        $where = '';
        $params = [];
        if ($action === 'get_leaderboard_by_subject') {
            $where = 'WHERE s.subject = ?';
            $params[] = text_field($_GET, 'subject', 120);
        }
        $query = database()->prepare('SELECT u.name, s.subject, MAX(s.score) AS score, MIN(s.created_at) AS first_score
            FROM quiz_scores s JOIN users u ON u.id = s.user_id ' . $where . '
            GROUP BY u.id, u.name, s.subject ORDER BY s.subject, score DESC, first_score, u.id LIMIT 1000');
        $query->execute($params);
        $entries = array_map(static fn(array $row): array => [
            'name' => $row['name'], 'subject' => $row['subject'], 'score' => (int)$row['score'],
        ], $query->fetchAll());
        if ($action === 'get_leaderboard_by_subject') {
            json_response(['success' => true, 'entries' => $entries]);
        }
        $groups = [];
        foreach ($entries as $entry) {
            $groups[$entry['subject']][] = $entry;
        }
        json_response(['success' => true, 'leaderboards' => (object)$groups]);
    }
    throw new ApiError(404, 'Layanan tidak ditemukan.');
}

function remove_avatar(?string $filename): void
{
    if ($filename !== null && preg_match('/^[a-f0-9]{32}\.(jpg|png|webp)$/D', $filename)) {
        $path = dirname(__DIR__) . '/public/uploads/' . $filename;
        if (is_file($path)) {
            unlink($path);
        }
    }
}

function replace_avatar(int $userId, ?string $filename): ?string
{
    $pdo = database();
    $pdo->beginTransaction();
    try {
        $query = $pdo->prepare('SELECT avatar_filename FROM users WHERE id = ? FOR UPDATE');
        $query->execute([$userId]);
        $old = $query->fetchColumn();
        $pdo->prepare('UPDATE users SET avatar_filename = ? WHERE id = ?')->execute([$filename, $userId]);
        $pdo->commit();
        return is_string($old) ? $old : null;
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
}

function upload_avatar(array $user): never
{
    $file = $_FILES['image'] ?? null;
    if (!is_array($file) || ($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK
        || (int)$file['size'] > 2 * 1024 * 1024 || !is_uploaded_file($file['tmp_name'])) {
        throw new ApiError(422, 'Pilih foto JPG, PNG, atau WebP berukuran maksimal 2 MB.');
    }
    $mime = (new finfo(FILEINFO_MIME_TYPE))->file($file['tmp_name']);
    $extensions = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    $size = getimagesize($file['tmp_name']);
    if (!isset($extensions[$mime]) || $size === false || $size[0] > 8192 || $size[1] > 8192) {
        throw new ApiError(422, 'File foto tidak valid. Gunakan JPG, PNG, atau WebP.');
    }
    $directory = dirname(__DIR__) . '/public/uploads';
    if (!is_dir($directory) && !mkdir($directory, 0750, true) && !is_dir($directory)) {
        throw new RuntimeException('Avatar directory is not writable');
    }
    $filename = bin2hex(random_bytes(16)) . '.' . $extensions[$mime];
    $path = $directory . '/' . $filename;
    if (!move_uploaded_file($file['tmp_name'], $path)) {
        throw new RuntimeException('Avatar upload could not be stored');
    }
    try {
        $oldFilename = replace_avatar((int)$user['id'], $filename);
    } catch (Throwable $error) {
        unlink($path);
        throw $error;
    }
    remove_avatar($oldFilename);
    json_response(['success' => true, 'filename' => $filename,
        'profile_picture' => app_config()['base_url'] . '/uploads/' . $filename]);
}
