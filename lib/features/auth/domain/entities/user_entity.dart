import 'package:equatable/equatable.dart';

enum UserRole { admin, hr, manager, employee }
enum UserStatus { active, pending, deactivated }

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final UserStatus status;
  final String department;
  final String? profileImageUrl;
  final String organizationId;
  final String? organizationName;

  final int failedLoginAttempts;
  final DateTime? lastFailedAttempt;
  final bool isAccountLocked;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = UserStatus.active,
    required this.department,
    this.profileImageUrl,
    required this.organizationId,
    this.organizationName,
    this.failedLoginAttempts = 0,
    this.lastFailedAttempt,
    this.isAccountLocked = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        status,
        department,
        profileImageUrl,
        organizationId,
        organizationName,
        failedLoginAttempts,
        lastFailedAttempt,
        isAccountLocked,
      ];
}
