import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AllLeaderboardScreen extends StatefulWidget {
  const AllLeaderboardScreen({super.key});

  @override
  State<AllLeaderboardScreen> createState() => _AllLeaderboardScreenState();
}

class _AllLeaderboardScreenState extends State<AllLeaderboardScreen> {
  final String apiUrl = 'http://192.168.100.109/studybuddy/get_all_leaderboard.php';

  Future<Map<String, List<dynamic>>> fetchAllLeaderboards() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, List<dynamic>.from(value)));
    } else {
      throw Exception('Gagal mengambil data leaderboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Leaderboard'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: fetchAllLeaderboards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gagal mengambil data leaderboard'));
          }

          final allData = snapshot.data!;

          if (allData.isEmpty) {
            return const Center(child: Text('Belum ada data leaderboard'));
          }

          return ListView(
            children: allData.entries.map((entry) {
              final subject = entry.key;
              final entries = entry.value;

              return ExpansionTile(
                title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                children: entries.asMap().entries.map((e) {
                  final index = e.key;
                  final data = e.value;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                    ),
                    title: Text(data['name']),
                    trailing: Text('${data['score']} pts'),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
