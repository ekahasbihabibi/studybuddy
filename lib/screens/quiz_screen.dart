import 'package:flutter/material.dart';
import 'quiz_play_screen.dart';
import '../services/leaderboard_service.dart';
import '../services/auth_service.dart';

class QuizScreen extends StatelessWidget {
  final List<Map<String, dynamic>> quizzes = [
    {'title': 'Kuis Matematika', 'questions': 10},
    {'title': 'Kuis Bahasa Inggris', 'questions': 8},
    {'title': 'Kuis Fisika', 'questions': 12},
  ];

  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kuis')),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                quiz['title'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${quiz['questions']} soal'),
              trailing: Icon(Icons.play_arrow),
              onTap: () async {
                final score = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPlayScreen(quizTitle: quiz['title']),
                  ),
                );

                if (score != null) {
                  final subject = quiz['title'];
                  final email = await AuthService.getCurrentUserEmail();
                  final name = (email ?? 'Guest').split('@')[0];

                  await LeaderboardService.submitScore(name, score, subject);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Skor berhasil dikirim ke leaderboard'),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
