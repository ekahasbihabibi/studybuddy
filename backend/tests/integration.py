"""Run against a LOCAL server with a separate studybuddy_test_* database only.

Requires STUDYBUDDY_TEST_BASE_URL, STUDYBUDDY_TEST_CONFIG, and PHP_BINARY.
No production account or default demonstration password is created.
"""
import base64
import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import urllib.error
import urllib.parse
import urllib.request

BASE = os.environ['STUDYBUDDY_TEST_BASE_URL'].rstrip('/')
if urllib.parse.urlsplit(BASE).hostname not in ('127.0.0.1', 'localhost'):
    raise RuntimeError('Integration tests must use a local test server')
PHP = os.environ.get('PHP_BINARY', 'php')
ROOT = Path(__file__).resolve().parents[1]
CHECKS = 0


def check(label, condition):
    global CHECKS
    assert condition, label
    CHECKS += 1
    print('PASS:', label, flush=True)


def call(endpoint, payload=None, token=None, method=None, raw=None, content_type=None):
    headers = {}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    data = raw
    if payload is not None:
        data = json.dumps(payload).encode()
        headers['Content-Type'] = 'application/json'
    if content_type:
        headers['Content-Type'] = content_type
    request = urllib.request.Request(BASE + '/' + endpoint, data=data, headers=headers,
                                     method=method or ('POST' if data is not None else 'GET'))
    try:
        response = urllib.request.urlopen(request, timeout=15)
    except urllib.error.HTTPError as error:
        response = error
    with response:
        body = response.read()
        try:
            body = json.loads(body)
        except (ValueError, UnicodeDecodeError):
            pass
        return response.status, body


def probe(data):
    result = subprocess.run([PHP, str(ROOT / 'tests/db_probe.php')], input=json.dumps(data),
                            text=True, capture_output=True, check=True)
    return json.loads(result.stdout)


def upload(data, filename, token):
    boundary = 'StudyBuddy' + secrets.token_hex(10)
    body = (f'--{boundary}\r\nContent-Disposition: form-data; name="image"; filename="{filename}"\r\n'
            'Content-Type: application/octet-stream\r\n\r\n').encode() + data + f'\r\n--{boundary}--\r\n'.encode()
    return call('upload_profile.php', token=token, raw=body,
                content_type='multipart/form-data; boundary=' + boundary)


suffix = secrets.token_hex(5)
alice = f'sbtest_alice_{suffix}@example.com'
bob = f'sbtest_bob_{suffix}@example.com'
math_subject = f'Math {suffix}'
password = secrets.token_hex(12)
status, body = call('health.php')
check('health checks the MySQL database', status == 200 and body['database'] == 'connected')
status, _ = call('login.php')
check('login only accepts POST', status == 405)
status, _ = call('register.php', raw=b'not json', content_type='application/json')
check('invalid JSON is rejected', status == 400)
status, _ = call('register.php', {'name': 'Test', 'email': alice, 'password': 'short'})
check('short passwords are rejected', status == 422)
status, _ = call('register.php', {'name': 'Alice', 'email': alice.upper(), 'password': password})
check('registration stores a new account', status == 201)
status, _ = call('register.php', {'name': 'Other', 'email': alice, 'password': password})
check('email uniqueness is case insensitive', status == 409)
status, _ = call('register.php', {'name': 'Bob', 'email': bob, 'password': password})
check('a second independent account is available', status == 201)
status, _ = call('login.php', {'email': alice, 'password': 'incorrect-password'})
check('wrong passwords are rejected', status == 401)
status, a1 = call('login.php', {'email': alice, 'password': password})
check('first device logs in', status == 200 and re.fullmatch('[a-f0-9]{64}', a1['access_token']) is not None)
status, a2 = call('login.php', {'email': alice, 'password': password})
check('second device gets its own session', status == 200 and a2['access_token'] != a1['access_token'])
status, b1 = call('login.php', {'email': bob, 'password': password})
check('another user has a separate session', status == 200)
A, A2, B = a1['access_token'], a2['access_token'], b1['access_token']
stored = probe({'email': alice, 'token': A, 'password': password})
check('passwords are stored as verifiable hashes', stored['password_hashed'])
check('session tokens are stored as hashes', stored['session_hashed'])
status, _ = call('get_profile.php')
check('profile access requires authentication', status == 401)
status, _ = call('get_profile.php', token='0' * 64)
check('a forged bearer token is rejected', status == 401)
status, profile = call('get_profile.php?email=' + urllib.parse.quote(bob), token=A)
check('a supplied email cannot read another user profile', status == 200 and profile['email'] == alice)
status, _ = call('update_profile.php', {'name': 'Alice Updated', 'email': bob}, token=A)
check('profile updates are accepted for the authenticated user', status == 200)
_, profile = call('get_profile.php', token=A2)
check('the other device sees the updated profile', profile['name'] == 'Alice Updated')
_, profile = call('get_profile.php', token=B)
check('another user profile is unchanged', profile['name'] == 'Bob')
status, _ = call('insert_score.php', {'subject': math_subject, 'score': '-1'}, token=A)
check('negative scores are rejected', status == 422)
status, _ = call('insert_score.php', {'subject': math_subject, 'score': '7', 'email': bob, 'name': 'Forged'}, token=A)
check('a score is stored using the authenticated identity', status == 201)
call('insert_score.php', {'subject': math_subject, 'score': '3'}, token=A)
call('insert_score.php', {'subject': math_subject, 'score': '5'}, token=B)
status, scores = call('get_leaderboard_by_subject.php?subject=' + urllib.parse.quote(math_subject), token=A2)
check('leaderboard keeps each user best score and uses server profile names',
      status == 200 and [(x['name'], x['score']) for x in scores['entries']] == [('Alice Updated', 7), ('Bob', 5)])
status, all_scores = call('get_all_leaderboard.php', token=B)
check('leaderboard is shared across users and devices', status == 200 and len(all_scores['leaderboards'][math_subject]) == 2)
subject = "Math'; DROP TABLE users; -- " + suffix
status, _ = call('insert_score.php', {'subject': subject, 'score': '0'}, token=A)
status2, payload = call('get_leaderboard_by_subject.php?subject=' + urllib.parse.quote(subject), token=A2)
check('SQL-looking text is stored as data and zero scores work', status == 201 and status2 == 200 and payload['entries'][0]['score'] == 0)
png = base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jrR8AAAAASUVORK5CYII=')
status, image = upload(png, '../../unsafe.php', A)
check('photo uploads generate a safe filename from verified image data', status == 200 and re.fullmatch('[a-f0-9]{32}\\.png', image['filename']) is not None)
photo_url = image['profile_picture']
_, profile = call('get_profile.php', token=A2)
check('the other device receives the shared profile photo URL', profile['profile_picture'] == photo_url)
with urllib.request.urlopen(photo_url, timeout=10) as response:
    check('the stored image can be displayed by the mobile app', response.status == 200 and response.read() == png)
status, _ = upload(b'<?php echo "unsafe"; ?>', 'image.png', A)
check('an executable disguised as a photo is rejected', status == 422)
status, _ = upload(png + b'X' * (2 * 1024 * 1024), 'large.png', A)
check('photos larger than 2 MB are rejected', status == 422)
call('delete_profile_picture.php', {'email': alice}, token=B)
_, profile = call('get_profile.php', token=A2)
check('another user cannot delete the profile photo by supplying an email', profile['profile_picture'] == photo_url)
call('delete_profile_picture.php', {}, token=A)
_, profile = call('get_profile.php', token=A2)
check('deleting a profile photo is visible on the other device', profile['profile_picture'] is None)
try:
    urllib.request.urlopen(photo_url, timeout=10)
    removed = False
except urllib.error.HTTPError as error:
    removed = error.code == 404
check('a deleted avatar file is removed from storage', removed)
call('logout.php', {}, token=A)
status, _ = call('get_profile.php', token=A)
check('logout revokes the current device session', status == 401)
status, _ = call('get_profile.php', token=A2)
check('logout does not revoke the other device session', status == 200)
probe({'mode': 'expire', 'email': alice, 'token': A2})
status, _ = call('get_profile.php', token=A2)
check('expired sessions are rejected', status == 401)
status, _ = call('login.php', {'email': alice, 'password': password})
check('the account can log in again after expiration', status == 200)
install_env = os.environ.copy()
install_env['STUDYBUDDY_CONFIG'] = os.environ['STUDYBUDDY_TEST_CONFIG']
result = subprocess.run([PHP, str(ROOT / 'bin/install.php')], env=install_env, capture_output=True, text=True)
check('re-running the database installer preserves existing data', result.returncode == 0)
status, _ = call('login.php', {'email': alice, 'password': password})
check('existing accounts still log in after re-running setup', status == 200)
unknown = f'sbtest_unknown_{suffix}@example.com'
for _ in range(16):
    status, _ = call('login.php', {'email': unknown, 'password': password})
check('repeated login attempts are rate limited', status == 429)
print(f'All {CHECKS} backend integration checks passed.', flush=True)
