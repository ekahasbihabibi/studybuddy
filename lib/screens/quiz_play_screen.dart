import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/leaderboard_service.dart';
import '../services/auth_service.dart'; // untuk ambil nama user dari login

class QuizPlayScreen extends StatefulWidget {
  final String quizTitle;

  QuizPlayScreen({required this.quizTitle});

  @override
  _QuizPlayScreenState createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  late List<QuizQuestion> questions;

  int currentQuestionIndex = 0;
  int selectedOptionIndex = -1;
  int score = 0;
  bool showResult = false;

  @override
  void initState() {
    super.initState();
    questions = _getQuestions(widget.quizTitle);
  }

  List<QuizQuestion> _getQuestions(String title) {
    switch (title) {
      case 'Kuis Matematika':
        return [
          QuizQuestion(question: 'Berapakah 5 + 3?', options: ['6', '7', '8', '9'], correctAnswerIndex: 2),
          QuizQuestion(question: 'Hasil dari 9 x 2?', options: ['16', '18', '20', '12'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Berapakah hasil dari 15 - 6?', options: ['9', '10', '8', '11'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Berapakah 12 ÷ 4?', options: ['2', '3', '4', '6'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Berapakah 7 x 5?', options: ['30', '35', '40', '25'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Bilangan ganjil dari daftar ini adalah?', options: ['4', '6', '8', '9'], correctAnswerIndex: 3),
          QuizQuestion(question: 'Hasil dari 100 - 55 adalah?', options: ['45', '40', '50', '55'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Berapakah 11 x 11?', options: ['121', '111', '101', '131'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Berapakah akar dari 81?', options: ['7', '8', '9', '10'], correctAnswerIndex: 2),
          QuizQuestion(question: 'Berapakah 2 pangkat 5?', options: ['16', '32', '64', '128'], correctAnswerIndex: 1),
        ];
      case 'Kuis Bahasa Inggris':
        return [
          QuizQuestion(question: 'Bahasa Inggris dari "Pintu"?', options: ['Window', 'Chair', 'Door', 'Wall'], correctAnswerIndex: 2),
          QuizQuestion(question: 'Arti "Apple" adalah?', options: ['Apel', 'Pisang', 'Mangga', 'Nanas'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Bahasa Inggris dari "Meja" adalah?', options: ['Chair', 'Table', 'Book', 'Pen'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Sinonim dari "Happy" adalah?', options: ['Sad', 'Angry', 'Glad', 'Tired'], correctAnswerIndex: 2),
          QuizQuestion(question: 'Arti kata "Library" dalam bahasa Indonesia?', options: ['Perpustakaan', 'Laboratorium', 'Kelas', 'Kantin'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Bahasa Inggris dari "Kucing" adalah?', options: ['Cat', 'Dog', 'Rabbit', 'Mouse'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Bahasa Inggris dari "Buku" adalah?', options: ['Book', 'Box', 'Board', 'Bottle'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Arti kata "Teacher" dalam bahasa Indonesia?', options: ['Dokter', 'Guru', 'Murid', 'Polisi'], correctAnswerIndex: 1),
        ];
      case 'Kuis Fisika':
        return [
          QuizQuestion(question: 'Apa satuan gaya dalam Fisika?', options: ['Watt', 'Newton', 'Ohm', 'Joule'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Rumus kecepatan adalah?', options: ['jarak × waktu', 'massa / gaya', 'jarak / waktu', 'waktu / jarak'], correctAnswerIndex: 2),
          QuizQuestion(question: 'Satuan SI untuk massa adalah?', options: ['Kilogram', 'Meter', 'Newton', 'Joule'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Alat untuk mengukur arus listrik adalah?', options: ['Voltmeter', 'Ammeter', 'Thermometer', 'Barometer'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Berapakah percepatan gravitasi di bumi?', options: ['8.9 m/s²', '9.8 m/s²', '10 m/s²', '9.0 m/s²'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Bunyi merambat paling cepat melalui?', options: ['Udara', 'Air', 'Besi', 'Hampa udara'], correctAnswerIndex: 2),
          QuizQuestion(question: 'Energi yang dimiliki benda karena geraknya disebut?', options: ['Energi potensial', 'Energi kinetik', 'Energi panas', 'Energi kimia'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Satuan daya listrik adalah?', options: ['Watt', 'Volt', 'Ampere', 'Ohm'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Alat optik yang digunakan pada mata adalah?', options: ['Lensa', 'Cermin', 'Kaca pembesar', 'Prisma'], correctAnswerIndex: 0),
          QuizQuestion(question: 'Apa yang menyebabkan pelangi terbentuk?', options: ['Pantulan', 'Bias dan Dispersi', 'Resonansi', 'Interferensi'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Apa hukum Newton ke-1 disebut juga?', options: ['Hukum Keseimbangan', 'Hukum Inersia', 'Hukum Aksi-Reaksi', 'Hukum Massa'], correctAnswerIndex: 1),
          QuizQuestion(question: 'Gelombang cahaya termasuk gelombang?', options: ['Longitudinal', 'Mekanik', 'Transversal', 'Permukaan'], correctAnswerIndex: 2),
        ];
      default:
        return [];
    }
  }

  void nextQuestion() {
    if (selectedOptionIndex == questions[currentQuestionIndex].correctAnswerIndex) {
      score++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionIndex = -1;
      });
    } else {
      setState(() {
        showResult = true;
      });

      // Kirim skor ke leaderboard setelah selesai kuis
      AuthService.getCurrentUserEmail().then((email) {
        final name = (email ?? 'Guest').split('@')[0];
        LeaderboardService.submitScore(name, score, widget.quizTitle);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return FutureBuilder<String?>(
        future: AuthService.getCurrentUserEmail(),
        builder: (context, snapshot) {
          final email = snapshot.data ?? 'Guest';
          final name = email.split('@')[0];

          return Scaffold(
            appBar: AppBar(title: Text('Hasil Kuis')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nama: $name', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Skor Anda:', style: TextStyle(fontSize: 22)),
                  SizedBox(height: 8),
                  Text('$score / ${questions.length}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Kembali ke Home'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/leaderboard',
                        arguments: widget.quizTitle, // Kirim nama kuis (subject)
                      );
                    },
                    child: Text('Lihat Leaderboard'),
                  ),

                ],
              ),
            ),
          );
        },
      );
    }


    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Soal ${currentQuestionIndex + 1}/${questions.length}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(question.question, style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            ...List.generate(question.options.length, (index) {
              return RadioListTile<int>(
                title: Text(question.options[index]),
                value: index,
                groupValue: selectedOptionIndex,
                onChanged: (value) {
                  setState(() {
                    selectedOptionIndex = value!;
                  });
                },
              );
            }),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: selectedOptionIndex == -1 ? null : nextQuestion,
                child: Text(currentQuestionIndex < questions.length - 1 ? 'Selanjutnya' : 'Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
