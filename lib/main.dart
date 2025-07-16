import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/leaderboard_screen.dart'; // ← tambahkan ini
import 'screens/home_screen.dart'; // opsional, jika ada halaman home setelah login
import 'screens/all_leaderboard_screen.dart';
import 'screens/best_choice_screen.dart';
import 'package:studybuddy/screens/target_screen.dart';
import 'screens/add_flashcard_screen.dart';




void main() {
  runApp(MyApp());
}

// Notifier untuk mengelola mode tema
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// Inisialisasi global notifier
final themeNotifier = ThemeNotifier();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'StudyBuddy',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: LoginScreen(), // Halaman awal login
          routes: {
            '/leaderboard': (context) => LeaderboardScreen(),
            '/leaderboard-all': (context) => const AllLeaderboardScreen(),
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/target': (context) => TargetScreen(),
            '/add-flashcard': (context) => AddFlashcardScreen(),// opsional
            // tambahkan route lain jika ada
          },
        );
      },
    );
  }
}
