class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String status;
  final bool isVerified;
  final bool isHero;
  final String? badge;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    required this.isVerified,
    this.isHero = false,
    this.badge,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'student',
      status: json['status'] ?? 'pending',
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      isHero: json['is_hero'] == 1 || json['is_hero'] == true,
      badge: json['badge'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'status': status,
      'is_verified': isVerified,
      'is_hero': isHero,
      'badge': badge,
    };
  }
}
