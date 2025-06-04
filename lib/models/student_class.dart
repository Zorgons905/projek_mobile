class StudentClass {
  final String id;
  final String classroomId;
  final String studentId;
  final DateTime? createdAt;

  StudentClass({
    required this.id,
    required this.classroomId,
    required this.studentId,
    this.createdAt,
  });

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    return StudentClass(
      id: json['id'],
      classroomId: json['classroom_id'],
      studentId: json['student_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classroom_id': classroomId,
      'student_id': studentId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
