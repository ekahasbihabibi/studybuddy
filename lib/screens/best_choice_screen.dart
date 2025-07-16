import 'package:flutter/material.dart';
import 'scholarship_screen.dart';
import 'study_abroad_screen.dart';
import 'work_abroad_screen.dart';
import 'toefl_screen.dart';

class BestChoiceScreen extends StatelessWidget {
  const BestChoiceScreen({super.key});

  final List<_BestChoiceItem> items = const [
    _BestChoiceItem(
      title: 'Kalender Beasiswa',
      imagePath: 'assets/beasiswa.png',
      screen: ScholarshipScreen(),
    ),
    _BestChoiceItem(
      title: 'Siap Kuliah di Luar Negeri',
      imagePath: 'assets/kuliah_luar.png',
      screen: StudyAbroadScreen(),
    ),
    _BestChoiceItem(
      title: 'Siap Kerja di Luar Negeri',
      imagePath: 'assets/kerja_luar.png',
      screen: WorkAbroadScreen(),
    ),
    _BestChoiceItem(
      title: 'Tes TOEFL',
      imagePath: 'assets/toefl.png',
      screen: TOEFLScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilihan Belajar Terbaik"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    item.imagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => item.screen),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: const Text(
                        'Lihat Detail',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BestChoiceItem {
  final String title;
  final String imagePath;
  final Widget screen;

  const _BestChoiceItem({
    required this.title,
    required this.imagePath,
    required this.screen,
  });
}
