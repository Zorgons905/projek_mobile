import 'dart:typed_data';

class File {
  final String id;
  final String name;
  final String ownerId;
  final Uint8List data;
  final DateTime createdAt;

  File({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.data,
    required this.createdAt,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      name: json['name'],
      ownerId: json['owner_id'],
      data: Uint8List.fromList(List<int>.from(json['data'])),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'data': data.toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
