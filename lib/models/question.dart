class Question {
  final String id;
  final String quizId;
  final String content;
  final int orderNumber;
  final String? pictureUrl;

  Question({
    required this.id,
    required this.quizId,
    required this.content,
    required this.orderNumber,
    this.pictureUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      quizId: json['quiz_id'],
      content: json['content'],
      orderNumber: json['order_number'],
      pictureUrl: json['picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'content': content,
      'order_number': orderNumber,
      'picture_url': pictureUrl,
    };
  }
}
