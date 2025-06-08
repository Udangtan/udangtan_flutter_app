class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.profileImageUrl,
    required this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      provider: json['provider'] ?? '',
    );
  }

  final String id;
  final String email;
  final String name;
  final String profileImageUrl;
  final String provider;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'provider': provider,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? provider,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      provider: provider ?? this.provider,
    );
  }
}
