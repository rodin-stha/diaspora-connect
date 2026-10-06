class User {
  final int id;
  final String? name;
  final String? displayName;
  final String? email;
  final String phone;
  final bool isActive;
  final String role;
  final List<String> permissions;

  const User({
    required this.id,
    this.name,
    this.displayName,
    this.email,
    required this.phone,
    required this.isActive,
    required this.role,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String?,
    displayName: json['display_name'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String,
    isActive: json['is_active'] as bool,
    role: json['role'] as String,
    permissions: (json['permissions'] as List).cast<String>(),
  );
}
