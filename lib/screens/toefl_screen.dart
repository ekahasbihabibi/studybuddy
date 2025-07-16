import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class TOEFLScreen extends StatelessWidget {
  const TOEFLScreen({super.key});

  Future<void> _downloadInfo(BuildContext context) async {
    try {
      final byteData = await rootBundle.load('assets/toefl_info.pdf');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/toefl_info.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuka file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tes TOEFL"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar di atas
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/toefl.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "📘 Persiapan Tes TOEFL",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "TOEFL (Test of English as a Foreign Language) adalah tes Bahasa Inggris internasional yang sering menjadi syarat masuk kuliah di luar negeri atau bekerja di perusahaan global.",
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Jenis-Jenis TOEFL"),
            _buildBulletPoints([
              "TOEFL iBT – berbasis internet, paling umum digunakan.",
              "TOEFL PBT – berbasis kertas, sekarang jarang digunakan.",
              "TOEFL ITP – digunakan untuk keperluan internal institusi pendidikan.",
            ], textColor),
            const SizedBox(height: 20),
            _buildSectionTitle("Struktur Tes TOEFL"),
            _buildBulletPoints([
              "📖 Reading – membaca dan memahami teks akademik.",
              "🎧 Listening – mendengarkan percakapan atau ceramah.",
              "🗣️ Speaking – menjawab pertanyaan secara lisan.",
              "📝 Writing – menulis esai berdasarkan topik atau bacaan.",
            ], textColor),
            const SizedBox(height: 20),
            _buildSectionTitle("Tips Menghadapi TOEFL"),
            _buildBulletPoints([
              "📚 Latihan soal asli TOEFL secara konsisten.",
              "🔤 Perbanyak kosakata dan pemahaman grammar.",
              "📱 Gunakan aplikasi belajar TOEFL atau tonton YouTube edukatif.",
              "⏰ Latih diri dengan simulasi tes berdurasi waktu.",
            ], textColor),
            const SizedBox(height: 20),
            _buildSectionTitle("Skor & Validitas"),
            _buildBulletPoints([
              "🎯 Skor maksimum TOEFL iBT adalah 120.",
              "📅 Skor berlaku selama 2 tahun.",
              "🏫 Tiap universitas atau institusi punya standar skor berbeda.",
            ], textColor),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Unduh Info Lengkap (PDF)"),
                onPressed: () => _downloadInfo(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      "📌 $title",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildBulletPoints(List<String> items, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(item, style: TextStyle(color: textColor)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
