class Profile {
  final String id;
  final String? role;
  final String? name;
  final String? bio;
  final String? profilePictureUrl;
  final DateTime? createdAt;

  Profile({
    required this.id,
    this.role,
    this.name,
    this.bio,
    this.profilePictureUrl,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      role: json['role'],
      name: json['name'],
      bio: json['bio'],
      profilePictureUrl: json['profile_picture_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? name,
    String? bio,
    String? profilePictureUrl,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
