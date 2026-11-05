# Backend tests

These tests create synthetic accounts and scores. Use a separate local database
whose name begins with `studybuddy_test_`; never point them at production data.
`integration.py` accepts only localhost/127.0.0.1 URLs. `db_probe.php` accepts only
fixture accounts whose email begins with `sbtest_`.

The Python suite uses only Python's standard library. Start PHP with the included
`router.php` and a dedicated test configuration. Initialize the test schema through
`bin/install.php` with administrator credentials for that test database. The runtime
API then uses the generated restricted database account.

Set these environment variables before running `python backend/tests/integration.py`:

| Variable | Value |
| --- | --- |
| `STUDYBUDDY_TEST_BASE_URL` | e.g. `http://127.0.0.1:18880` |
| `STUDYBUDDY_TEST_CONFIG` | Absolute path to the private test configuration |
| `PHP_BINARY` | PHP CLI executable, e.g. `C:\xampp\php\php.exe` |

The test invoking the installer again needs the test database administrator settings
(`STUDYBUDDY_DB_ADMIN_USER`, `STUDYBUDDY_DB_ADMIN_PASSWORD`, and a non-default
`STUDYBUDDY_DB_PORT` when applicable). Do not commit credential values.
Use `STUDYBUDDY_CONFIG` on the PHP server process to select the same test config.

The Flutter service contract can be run against that local test server:

```sh
flutter test backend/test/flutter_server_contract_test.dart --dart-define=API_BASE_URL=http://127.0.0.1:18880
```

This verifies real HTTP calls from the application's services to PHP/MySQL while
mocking only device storage. The ordinary `flutter test` suite does not need a server.

Verified backend behaviors include account creation, password validation, independent
sessions, cross-device profiles, authorization, avatar upload restrictions, shared
leaderboards, logout isolation, token expiry, setup idempotency, and login rate limits.
