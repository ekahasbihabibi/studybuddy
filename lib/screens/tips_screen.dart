import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips Belajar'),
        backgroundColor: isDark ? Colors.black : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            context,
            "1. Buat Jadwal Belajar",
            "Atur waktu belajar secara konsisten setiap hari agar terbentuk kebiasaan yang baik.",
          ),
          _buildTipCard(
            context,
            "2. Gunakan Teknik Pomodoro",
            "Belajar selama 25 menit lalu istirahat 5 menit agar tetap fokus dan tidak mudah lelah.",
          ),
          _buildTipCard(
            context,
            "3. Pelajari Materi dengan Aktif",
            "Buat catatan sendiri, ajarkan kembali ke orang lain, atau gunakan metode tanya-jawab.",
          ),
          _buildTipCard(
            context,
            "4. Gunakan Flashcard",
            "Ulangi dan uji pemahamanmu menggunakan kartu untuk meningkatkan daya ingat.",
          ),
          _buildTipCard(
            context,
            "5. Istirahat Cukup",
            "Pastikan tidur cukup agar otak mampu menyerap informasi secara optimal.",
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? Colors.blueGrey[800] : Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }
}
