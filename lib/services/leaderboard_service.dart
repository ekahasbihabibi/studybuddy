import '../models/leaderboard_entry.dart';
import 'account_api.dart';

class LeaderboardService {
  static Future<void> submitScore(
    String name,
    int score,
    String subject,
  ) async {
    // User identity and display name come from the authenticated account.
    await AccountApi().submit('insert_score.php', {
      'score': score.toString(),
      'subject': subject,
    }, authenticated: true);
  }

  static Future<List<LeaderboardEntry>> fetchLeaderboardBySubject(
    String subject,
  ) async {
    final data = await AccountApi().request(
      'get_leaderboard_by_subject.php',
      query: {'subject': subject},
    );
    return (data['entries'] as List<dynamic>)
        .map(
          (entry) => LeaderboardEntry.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }

  static Future<Map<String, List<dynamic>>> fetchAllLeaderboards() async {
    final data = await AccountApi().request('get_all_leaderboard.php');
    return Map<String, dynamic>.from(
      data['leaderboards'] as Map,
    ).map((key, value) => MapEntry(key, List<dynamic>.from(value as List)));
  }
}
