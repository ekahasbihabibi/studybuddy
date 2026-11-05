import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studybuddy/services/account_api.dart';

void main() {
  test(
    'sends the login payload and accepts a valid account response',
    () async {
      final client = MockClient((request) async {
        expect(request.url.path.endsWith('/login.php'), isTrue);
        expect(jsonDecode(request.body), {
          'email': 'test@example.com',
          'password': 'secret123',
        });
        return http.Response('{"success":true}', 200);
      });
      final data = await AccountApi(client: client).submit('login.php', {
        'email': 'test@example.com',
        'password': 'secret123',
      });
      expect(data['success'], isTrue);
      client.close();
    },
  );

  test('preserves a registration rejection from the backend', () async {
    final client = MockClient(
      (_) async => http.Response(
        '{"success":false,"message":"Email sudah terdaftar"}',
        409,
      ),
    );
    await expectLater(
      AccountApi(client: client).submit('register.php', {}),
      throwsA(
        isA<AccountApiException>().having(
          (e) => e.message,
          'message',
          'Email sudah terdaftar',
        ),
      ),
    );
    client.close();
  });

  test('HTML instead of JSON produces a clear account-service error', () async {
    final client = MockClient(
      (_) async => http.Response('<html>Not an API</html>', 200),
    );
    await expectLater(
      AccountApi(client: client).submit('login.php', {}),
      throwsA(
        isA<AccountApiException>().having(
          (e) => e.message,
          'message',
          contains('belum dapat digunakan'),
        ),
      ),
    );
    client.close();
  });

  test('server errors do not get treated as successful logins', () async {
    final client = MockClient((_) async => http.Response('Server error', 500));
    await expectLater(
      AccountApi(client: client).submit('login.php', {}),
      throwsA(
        isA<AccountApiException>().having(
          (e) => e.message,
          'message',
          contains('bermasalah'),
        ),
      ),
    );
    client.close();
  });

  test('connection failure reports an understandable message', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('Unreachable'),
    );
    await expectLater(
      AccountApi(client: client).submit('login.php', {}),
      throwsA(
        isA<AccountApiException>().having(
          (e) => e.message,
          'message',
          contains('Tidak dapat terhubung'),
        ),
      ),
    );
    client.close();
  });

  test(
    'a server that never responds stops at the configured deadline',
    () async {
      final pending = Completer<http.Response>();
      final client = MockClient((_) => pending.future);
      await expectLater(
        AccountApi(
          client: client,
          requestTimeout: const Duration(milliseconds: 1),
        ).submit('login.php', {}),
        throwsA(
          isA<AccountApiException>().having(
            (e) => e.message,
            'message',
            contains('Waktu tunggu habis'),
          ),
        ),
      );
      client.close();
    },
  );
}
