import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class WorkAbroadScreen extends StatelessWidget {
  const WorkAbroadScreen({super.key});

  Future<void> _downloadAndOpenPDF(BuildContext context) async {
    try {
      final bytes = await rootBundle.load('assets/work_abroad_info.pdf');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/work_abroad_info.pdf');
      await file.writeAsBytes(bytes.buffer.asUint8List());

      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka file PDF.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Siap Kerja di Luar Negeri"),
        backgroundColor: isDark ? Colors.black : Colors.indigo,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset("assets/kerja_luar.png", height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              "Persiapkan Diri untuk Karir Internasional",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Bekerja di luar negeri menjadi impian banyak orang karena peluang karir yang lebih luas, pengalaman budaya baru, dan penghasilan yang kompetitif. Modul ini akan membantumu memahami langkah-langkah penting untuk mempersiapkan diri sebelum bekerja di luar negeri.",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "📌 Yang akan kamu pelajari:\n\n"
                  "• Informasi dasar tentang dokumen penting seperti visa kerja, surat lamaran internasional, dan CV berstandar global.\n"
                  "• Tips menghadapi wawancara kerja internasional dan adaptasi budaya kerja.\n"
                  "• Persiapan bahasa, keuangan, dan legalitas.\n",
              style: TextStyle(fontSize: 15, height: 1.5, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _downloadAndOpenPDF(context),
                icon: const Icon(Icons.download),
                label: const Text(
                  "Unduh Info Lengkap (PDF)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
