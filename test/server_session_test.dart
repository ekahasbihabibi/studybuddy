import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/services/account_api.dart';
import 'package:studybuddy/services/auth_service.dart';
import 'package:studybuddy/services/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final token = List.filled(64, 'a').join();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  test('email-only success cannot create a login session', () async {
    await expectLater(
      AuthService.saveSession('test@example.com', {'success': true}),
      throwsA(isA<AccountApiException>()),
    );
    expect(await AuthService.isLoggedIn(), isFalse);
  });

  test('valid server session is kept in secure storage', () async {
    await AuthService.saveSession('TEST@example.com', {
      'success': true,
      'access_token': token,
      'user': {'email': 'test@example.com'},
    });
    expect(await AuthService.isLoggedIn(), isTrue);
    expect(await AuthService.getCurrentUserEmail(), 'test@example.com');
    expect(await SessionStore.token(), token);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  });

  test(
    'protected profile request sends a bearer token without trusting an email field',
    () async {
      await SessionStore.save('test@example.com', token);
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer $token');
        expect(request.body, isEmpty);
        return http.Response(
          jsonEncode({
            'success': true,
            'email': 'test@example.com',
            'name': 'Pengguna',
          }),
          200,
        );
      });
      final data = await AccountApi(client: client).request('get_profile.php');
      expect(data['email'], 'test@example.com');
      client.close();
    },
  );

  test('protected requests without a session never reach the server', () async {
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('{}', 200);
    });
    await expectLater(
      AccountApi(client: client).request('get_profile.php'),
      throwsA(isA<AccountApiException>()),
    );
    expect(called, isFalse);
    client.close();
  });

  test('expired server session clears local credentials', () async {
    await SessionStore.save('test@example.com', token);
    final client = MockClient(
      (_) async => http.Response(
        '{"success":false,"message":"Sesi sudah berakhir"}',
        401,
      ),
    );
    await expectLater(
      AccountApi(client: client).request('get_profile.php'),
      throwsA(isA<AccountApiException>()),
    );
    expect(await SessionStore.token(), isNull);
    expect(await AuthService.isLoggedIn(), isFalse);
    client.close();
  });

  test(
    'switching accounts does not expose local preferences from the previous user',
    () async {
      await SessionStore.save('previous@example.com', token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('favorite_module_ids', '["private-user-favorite"]');
      await AuthService.saveSession('next@example.com', {
        'success': true,
        'access_token': token,
        'user': {'email': 'next@example.com'},
      });
      expect(prefs.getString('favorite_module_ids'), isNull);
      expect(await SessionStore.email(), 'next@example.com');
    },
  );
}
