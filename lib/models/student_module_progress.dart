class StudentModuleProgress {
  final String id;
  final String studentId;
  final String moduleId;
  final double progressPercent;
  final DateTime? lastReadAt;

  StudentModuleProgress({
    required this.id,
    required this.studentId,
    required this.moduleId,
    required this.progressPercent,
    this.lastReadAt,
  });

  factory StudentModuleProgress.fromJson(Map<String, dynamic> json) {
    return StudentModuleProgress(
      id: json['id'],
      studentId: json['student_id'],
      moduleId: json['module_id'],
      progressPercent: (json['progress_percent'] as num).toDouble(),
      lastReadAt:
          json['last_read_at'] != null
              ? DateTime.parse(json['last_read_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'module_id': moduleId,
      'progress_percent': progressPercent,
      'last_read_at': lastReadAt?.toIso8601String(),
    };
  }
}
