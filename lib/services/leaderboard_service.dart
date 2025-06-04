
import 'package:test123/models/leaderboard_model.dart';
class LeaderboardService {
  Future<List<LeaderboardEntry>> getLeaderboardData() async {
    // Simulasi pengambilan data dari backend dengan delay
    await Future.delayed(const Duration(seconds: 2));

    // Data dummy untuk contoh
    final List<Map<String, dynamic>> dummyData = [
      {
        'studentName': 'Budi Santoso',
        'quizScore': 95,
        'materialProgress': 1.0, // 100%
        'quizzesCompleted': 10,
      },
      {
        'studentName': 'Ani Setiawati',
        'quizScore': 88,
        'materialProgress': 0.9, // 90%
        'quizzesCompleted': 9,
      },
      {
        'studentName': 'Joko Susanto',
        'quizScore': 82,
        'materialProgress': 0.75, // 75%
        'quizzesCompleted': 8,
      },
      {
        'studentName': 'Siti Rahayu',
        'quizScore': 78,
        'materialProgress': 0.85, // 85%
        'quizzesCompleted': 9,
      },
      {
        'studentName': 'Agus Salim',
        'quizScore': 70,
        'materialProgress': 0.60, // 60%
        'quizzesCompleted': 7,
      },
    ];

    // Mengkonversi data dummy menjadi list LeaderboardEntry
    List<LeaderboardEntry> leaderboard = dummyData.map((data) {
      return LeaderboardEntry.fromJson(data);
    }).toList();

    // Mengurutkan data berdasarkan skor kuis (dari tertinggi ke terendah)
    leaderboard.sort((a, b) => b.quizScore.compareTo(a.quizScore));

    return leaderboard;
  }
}