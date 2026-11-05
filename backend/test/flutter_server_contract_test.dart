import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studybuddy/config/api_config.dart';
import 'package:studybuddy/services/account_api.dart';
import 'package:studybuddy/services/auth_service.dart';
import 'package:studybuddy/services/leaderboard_service.dart';
import 'package:studybuddy/services/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Flutter services use real PHP/MySQL sessions across two clients',
    () async {
      expect(
        Uri.parse(ApiConfig.baseUrl).host,
        isIn(['127.0.0.1', 'localhost']),
        reason: 'Run only against an isolated local test backend.',
      );
      HttpOverrides.global =
          null; // Explicit live integration, not a mocked widget test.
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      final email =
          'sbtest_flutter_${DateTime.now().microsecondsSinceEpoch}@example.com';
      const password = 'integration-only-Password-321';
      final api = AccountApi();
      final registration = await api.submit('register.php', {
        'name': 'Flutter User',
        'email': email,
        'password': password,
      });
      expect(registration['success'], isTrue);
      final first = await api.submit('login.php', {
        'email': email,
        'password': password,
      });
      await AuthService.saveSession(email, first);
      expect((await AuthService.getUserProfile(email))['name'], 'Flutter User');
      final firstToken = (await SessionStore.token())!;

      final second = await api.submit('login.php', {
        'email': email,
        'password': password,
      });
      await AuthService.saveSession(email, second);
      final secondToken = (await SessionStore.token())!;
      expect(secondToken, isNot(firstToken));
      expect(
        await AuthService.updateUserName(email, 'Shared Flutter User'),
        isTrue,
      );

      await SessionStore.save(email, firstToken);
      expect(
        (await AuthService.getUserProfile(email))['name'],
        'Shared Flutter User',
      );
      await LeaderboardService.submitScore(
        'Ignored client name',
        8,
        'Flutter contract',
      );
      final entries = await LeaderboardService.fetchLeaderboardBySubject(
        'Flutter contract',
      );
      expect(
        entries.any(
          (entry) => entry.name == 'Shared Flutter User' && entry.score == 8,
        ),
        isTrue,
      );
      expect(
        (await LeaderboardService.fetchAllLeaderboards())['Flutter contract'],
        isNotEmpty,
      );

      await AuthService.logout();
      expect(await AuthService.isLoggedIn(), isFalse);
      await SessionStore.save(email, secondToken);
      expect(
        (await AuthService.getUserProfile(email))['name'],
        'Shared Flutter User',
      );
      await AuthService.logout();
    },
  );
}
