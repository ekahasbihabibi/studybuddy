class LeaderboardEntry {
  final String name;
  final int score;
  final String subject; // ✅ tambahkan ini

  LeaderboardEntry({
    required this.name,
    required this.score,
    required this.subject, // ✅ pastikan ikut disini juga
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'],
      score: int.tryParse(json['score'].toString()) ?? 0,
      subject: json['subject'] ?? '', // ✅ parsing dari JSON
    );
  }
}
