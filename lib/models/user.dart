enum UserRole {
  admin,
  agent,
  driver,
  asstDriver,
  customer,
}

class User {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? branchId;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.branchId,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      branchId: json['branch_id'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'branch_id': branchId,
      'is_active': isActive,
    };
  }
}
