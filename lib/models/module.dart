class Module {
  final String id;
  final String classroomId;
  final String title;
  final String? fileUrl;
  final String? fileType;
  final DateTime? uploadedAt;

  Module({
    required this.id,
    required this.classroomId,
    required this.title,
    this.fileUrl,
    this.fileType,
    this.uploadedAt,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      classroomId: json['classroom_id'],
      title: json['title'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      uploadedAt:
          json['uploaded_at'] != null
              ? DateTime.parse(json['uploaded_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classroom_id': classroomId,
      'title': title,
      'file_url': fileUrl,
      'file_type': fileType,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }
}
