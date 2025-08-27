class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? userType; // Added userType for ObjectId-based admin system
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.userType,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      userType: json['userType'],
      avatar: json['avatar'],
    );
  }

  factory User.fromJWT(Map<String, dynamic> jwtPayload) {
    return User(
      id: jwtPayload['_id'] ?? jwtPayload['id'] ?? '',
      name: jwtPayload['name'] ?? jwtPayload['username'] ?? '',
      email: jwtPayload['email'] ?? '',
      role: jwtPayload['role'] ?? 'user',
      userType: jwtPayload['userType'], // Extract userType ObjectId
      avatar: jwtPayload['avatar'],
    );
  }
}
