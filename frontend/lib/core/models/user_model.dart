enum UserRole {
  operator('operator'),
  engineer('engineer'),
  supervisor('supervisor');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String? roleStr) {
    return UserRole.values.firstWhere(
      (e) => e.value.toLowerCase() == roleStr?.toLowerCase(),
      orElse: () => UserRole.operator,
    );
  }
}

class UserModel {
  final String uid;
  final String email;
  final UserRole role;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role.value,
    };
  }
}
