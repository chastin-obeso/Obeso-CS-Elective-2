class UserProfile {
  final String id;
  final String? email;
  final String? firstname;
  final String? lastname;
  final int? roleId;
  final String roleName;

  const UserProfile({
    required this.id,
    this.email,
    this.firstname,
    this.lastname,
    this.roleId,
    required this.roleName,
  });

  bool get isAdmin => roleName.toLowerCase() == 'admin';
  bool get isCustomer => roleName.toLowerCase() == 'customer';

  String get fullName {
    final parts = [firstname, lastname]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isEmpty) return email ?? 'User';
    return parts.join(' ');
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final roleData = json['roles'];
    String resolvedRole = 'customer';
    if (roleData is Map<String, dynamic> && roleData['role'] is String) {
      resolvedRole = roleData['role'] as String;
    } else if (json['role'] is String) {
      resolvedRole = json['role'] as String;
    }

    return UserProfile(
      id: (json['id'] as String?) ?? '',
      email: json['email'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      roleId: (json['role_id'] as num?)?.toInt(),
      roleName: resolvedRole,
    );
  }
}