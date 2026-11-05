import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studybuddy/main.dart';

void main() {
  testWidgets('StudyBuddy opens the mobile login screen', (tester) async {
    await tester.pumpWidget(MyApp());
    // Let the existing delayed form animation complete.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to StudyBuddy'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('Empty login validates without calling the backend', (
    tester,
  ) async {
    await tester.pumpWidget(MyApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Email dan password wajib diisi'), findsOneWidget);
  });
}
