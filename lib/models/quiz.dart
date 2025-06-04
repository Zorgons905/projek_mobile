class Quiz {
  final String id;
  final String classroomId;
  final String title;
  final DateTime? createdAt;
  final bool isRandomizeQuestion;
  final bool isRandomizeAnswer;

  Quiz({
    required this.id,
    required this.classroomId,
    required this.title,
    this.createdAt,
    required this.isRandomizeQuestion,
    required this.isRandomizeAnswer,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      classroomId: json['classroom_id'],
      title: json['title'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      isRandomizeQuestion: json['is_randomize_question'] ?? false,
      isRandomizeAnswer: json['is_randomize_answer'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classroom_id': classroomId,
      'title': title,
      'created_at': createdAt?.toIso8601String(),
      'is_randomize_question': isRandomizeQuestion,
      'is_randomize_answer': isRandomizeAnswer,
    };
  }
}
