class StudentQuizResult {
  final String id;
  final String studentId;
  final String quizId;
  final double score;
  final DateTime? submittedAt;

  StudentQuizResult({
    required this.id,
    required this.studentId,
    required this.quizId,
    required this.score,
    this.submittedAt,
  });

  factory StudentQuizResult.fromJson(Map<String, dynamic> json) {
    return StudentQuizResult(
      id: json['id'],
      studentId: json['student_id'],
      quizId: json['quiz_id'],
      score: (json['score'] as num).toDouble(),
      submittedAt:
          json['submitted_at'] != null
              ? DateTime.parse(json['submitted_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'quiz_id': quizId,
      'score': score,
      'submitted_at': submittedAt?.toIso8601String(),
    };
  }
}
