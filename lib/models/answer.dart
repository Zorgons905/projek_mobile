class Answer {
  final String id;
  final String questionId;
  final String content;
  final bool isCorrect;

  Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      questionId: json['question_id'],
      content: json['content'],
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'content': content,
      'is_correct': isCorrect,
    };
  }
}
