import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studybuddy/screens/login_screen.dart';
import 'package:studybuddy/screens/register_screen.dart';
import 'package:studybuddy/services/account_api.dart';

void main() {
  testWidgets(
    'login shows progress then a persistent error when the server hangs',
    (tester) async {
      final pending = Completer<http.Response>();
      var requestCount = 0;
      final client = MockClient((_) {
        requestCount++;
        return pending.future;
      });
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(
            accountApi: AccountApi(
              client: client,
              requestTimeout: const Duration(seconds: 1),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'secret123');
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      expect(requestCount, 1);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.textContaining('Waktu tunggu habis'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      client.close();
    },
  );

  testWidgets('registration reports backend failure and allows retry', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var registered = false;
    final client = MockClient((_) => pending.future);
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(
          accountApi: AccountApi(client: client),
          onRegister: (_, __) => registered = true,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), 'Pengguna');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret123');
    final button = find.byWidgetPredicate((widget) => widget is ElevatedButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(find.text('Mendaftar...'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(button).onPressed,
      isNull,
    );
    pending.complete(
      http.Response('{"success":false,"message":"Email sudah terdaftar"}', 200),
    );
    await tester.pumpAndSettle();
    expect(find.text('Email sudah terdaftar'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(button).onPressed,
      isNotNull,
    );
    expect(registered, isFalse);
    client.close();
  });
}
