import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class StudyAbroadScreen extends StatelessWidget {
  const StudyAbroadScreen({super.key});

  Future<void> _downloadInfo(BuildContext context) async {
    try {
      final byteData = await rootBundle.load('assets/study_abroad_info.pdf');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/study_abroad_info.pdf');
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
        title: const Text("Siap Kuliah di Luar Negeri"),
        backgroundColor: isDark ? Colors.black : Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tambahkan gambar di atas
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/kuliah_luar.png',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "📘 Persiapan Kuliah di Luar Negeri",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Kuliah di luar negeri adalah impian banyak pelajar. Dengan perencanaan yang tepat, kamu bisa membuka jalan menuju pengalaman belajar internasional yang luar biasa.",
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Langkah-Langkah Persiapan"),
            _buildBulletPoints([
              "Menentukan negara, jurusan, dan kampus tujuan.",
              "Memenuhi syarat akademik dan kemampuan bahasa (seperti TOEFL/IELTS).",
              "Mengatur keuangan, termasuk mencari beasiswa.",
              "Mempersiapkan dokumen penting: paspor, transkrip, surat rekomendasi, dsb.",
              "Mengurus visa pelajar dan asuransi kesehatan.",
            ], textColor),
            const SizedBox(height: 20),
            _buildSectionTitle("Keuntungan Kuliah di Luar Negeri"),
            _buildBulletPoints([
              "Pengalaman lintas budaya yang memperluas wawasan.",
              "Kemampuan bahasa asing yang meningkat.",
              "Akses ke fasilitas pendidikan dan riset berkualitas.",
              "Peluang kerja global dan relasi internasional.",
            ], textColor),
            const SizedBox(height: 20),
            _buildSectionTitle("Tantangan yang Perlu Diantisipasi"),
            _buildBulletPoints([
              "Perbedaan budaya dan sistem belajar.",
              "Biaya hidup dan jarak dari keluarga.",
              "Adaptasi terhadap cuaca, makanan, dan lingkungan baru.",
              "Pengelolaan waktu, studi, dan kehidupan sosial.",
            ], textColor),
            const SizedBox(height: 20),
            _buildSectionTitle("Tips Sukses"),
            _buildBulletPoints([
              "Mulai riset dan persiapan minimal 1 tahun sebelumnya.",
              "Ikuti seminar/webinar dari lembaga resmi pendidikan luar negeri.",
              "Bergabung dalam komunitas pelajar Indonesia di negara tujuan.",
              "Bangun kemandirian dan manajemen waktu yang baik.",
            ], textColor),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Unduh Info Lengkap (PDF)"),
                onPressed: () => _downloadInfo(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        color: Colors.indigo,
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
