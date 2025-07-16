import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StudyStatsScreen extends StatefulWidget {
  const StudyStatsScreen({super.key});

  @override
  State<StudyStatsScreen> createState() => _StudyStatsScreenState();
}

class _StudyStatsScreenState extends State<StudyStatsScreen> {
  String selectedSubject = 'Matematika';

  final Map<String, List<double>> subjectStudyHours = {
    'Matematika': [1.5, 2.0, 1.8, 2.2, 0.0, 1.0, 1.5],
    'Bahasa Inggris': [1.0, 1.5, 1.0, 1.2, 0.8, 1.3, 1.5],
    'Fisika': [2.0, 2.2, 1.5, 0.0, 2.0, 1.5, 1.8],
  };

  final List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studyHours = subjectStudyHours[selectedSubject]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistik Belajar'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik: $selectedSubject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: subjectStudyHours.keys.map((subject) {
                final isSelected = selectedSubject == subject;
                return ChoiceChip(
                  label: Text(subject),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => selectedSubject = subject);
                  },
                  selectedColor: Colors.indigo,
                  labelStyle: TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  maxY: 3,
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(days[index], style: TextStyle(fontSize: 12)),
                            );
                          }
                          return SizedBox();
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(studyHours.length, (index) {
                    return BarChartGroupData(x: index, barRods: [
                      BarChartRodData(
                        toY: studyHours[index],
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.indigo,
                      ),
                    ]);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total minggu ini: ${studyHours.reduce((a, b) => a + b).toStringAsFixed(1)} jam',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
