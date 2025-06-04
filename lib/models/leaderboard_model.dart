// Tidak ada perubahan di sini
class LeaderboardEntry {
  final String studentName;
  final int quizScore; // Skor kuis
  final double materialProgress; // Progress materi dalam persentase (0.0 - 1.0)
  final int quizzesCompleted; // Jumlah kuis yang diselesaikan

  LeaderboardEntry({
    required this.studentName,
    required this.quizScore,
    required this.materialProgress,
    required this.quizzesCompleted,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      studentName: json['studentName'] as String,
      quizScore: json['quizScore'] as int,
      materialProgress: (json['materialProgress'] as num).toDouble(),
      quizzesCompleted: json['quizzesCompleted'] as int,
    );
  }
}