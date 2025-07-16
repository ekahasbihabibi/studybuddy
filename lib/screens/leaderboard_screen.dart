import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});


  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Future<List<LeaderboardEntry>>? _leaderboardFuture;
  String subject = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) {
      subject = arg;
      _leaderboardFuture = LeaderboardService.fetchLeaderboardBySubject(subject);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;




    return Scaffold(
      appBar: AppBar(
        title: Text('Peringkat - $subject'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
        actions: [ // <- ini harus di dalam AppBar
          IconButton(
            icon: Icon(Icons.list_alt),
            tooltip: 'Lihat Semua Leaderboard',
            onPressed: () {
              Navigator.pushNamed(context, '/leaderboard-all');
            },
          ),
        ],
      ),

      body: _leaderboardFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<LeaderboardEntry>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gagal mengambil data leaderboard'));
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(child: Text('Belum ada data peringkat'));
          }

          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => Divider(
              color: isDarkMode ? Colors.white12 : Colors.grey[300],
              thickness: 1,
              height: 0,
            ),
            itemBuilder: (context, index) {
              final entry = data[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                title: Text(
                  entry.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Text(
                  '${entry.score} pts',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
