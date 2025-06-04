class Classroom {
  final String id;
  final String name;
  final String? description;
  final String code;
  final String lecturerId;
  final DateTime? createdAt;

  Classroom({
    required this.id,
    required this.name,
    required this.code,
    required this.lecturerId,
    this.createdAt,
    this.description,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      code: json['code'],
      lecturerId: json['lecturer_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'code': code,
      'lecturer_id': lecturerId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Classroom copyWith({
    String? id,
    String? name,
    String? description,
    String? code,
    String? lecturerId,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      lecturerId: lecturerId ?? this.lecturerId,
    );
  }
}
