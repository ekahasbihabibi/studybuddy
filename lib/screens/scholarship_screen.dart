import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'scholarship_form_screen.dart';

class ScholarshipScreen extends StatelessWidget {
  const ScholarshipScreen({super.key});

  Future<void> _downloadAndOpenPDF(BuildContext context) async {
    try {
      final byteData = await rootBundle.load('assets/info_beasiswa.pdf');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/info_beasiswa.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalender Beasiswa"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/beasiswa.png', height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              "Program Beasiswa Digital untuk Pelajar dan Mahasiswa",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Dapatkan kesempatan emas untuk melanjutkan studi secara gratis dengan program beasiswa unggulan. Program ini ditujukan bagi pelajar dan mahasiswa berprestasi yang memiliki semangat belajar tinggi dan kontribusi positif di lingkungan sekitarnya. Pendaftaran terbuka untuk seluruh jurusan dan latar belakang pendidikan.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.calendar_today, "Pendaftaran: 1 - 31 Agustus 2025"),
                  _infoRow(Icons.check_circle, "Seleksi Administrasi & Tes Online"),
                  _infoRow(Icons.school, "Tunjangan biaya pendidikan & sertifikat"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text("Download Info"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _downloadAndOpenPDF(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit_note),
                  label: const Text("Ajukan Sekarang"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ScholarshipFormScreen()),
                    );
                  },

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
