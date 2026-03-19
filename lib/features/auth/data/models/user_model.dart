import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.status,
    required super.department,
    super.profileImageUrl,
    required super.organizationId,
    super.organizationName,
    super.failedLoginAttempts,
    super.lastFailedAttempt,
    super.isAccountLocked,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.employee,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => UserStatus.active,
      ),
      department: json['department'] as String? ?? 'Unknown',
      profileImageUrl: json['profileImageUrl'] as String?,
      organizationId: json['organizationId'] as String? ?? '',
      organizationName: json['organizationName'] as String?,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      lastFailedAttempt: json['lastFailedAttempt'] != null
          ? DateTime.parse(json['lastFailedAttempt'] as String)
          : null,
      isAccountLocked: json['isAccountLocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'department': department,
      'profileImageUrl': profileImageUrl,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'failedLoginAttempts': failedLoginAttempts,
      'lastFailedAttempt': lastFailedAttempt?.toIso8601String(),
      'isAccountLocked': isAccountLocked,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      status: entity.status,
      department: entity.department,
      profileImageUrl: entity.profileImageUrl,
      organizationId: entity.organizationId,
      organizationName: entity.organizationName,
      failedLoginAttempts: entity.failedLoginAttempts,
      lastFailedAttempt: entity.lastFailedAttempt,
      isAccountLocked: entity.isAccountLocked,
    );
  }
}
