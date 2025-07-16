import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/leaderboard_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardService {
  static const String baseUrl = 'http://192.168.100.109/studybuddy'; // sesuaikan IP

  static Future<void> submitScore(String name, int score, String subject) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/insert_score.php'),
      body: {
        'name': name,
        'score': score.toString(),
        'email': email,
        'subject': subject,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal kirim skor');
    }
  }

  static Future<List<LeaderboardEntry>> fetchLeaderboardBySubject(String subject) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_leaderboard_by_subject.php?subject=${Uri.encodeComponent(subject)}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => LeaderboardEntry.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil leaderboard');
    }
  }

  static Future<Map<String, List<dynamic>>> fetchAllLeaderboards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_all_leaderboard.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, List<dynamic>.from(value)));
    } else {
      throw Exception('Gagal mengambil semua leaderboard');
    }
  }
}
