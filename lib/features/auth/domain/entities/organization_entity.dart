import 'package:equatable/equatable.dart';

class OrganizationEntity extends Equatable {
  final String id;
  final String name;
  final String adminId;
  final DateTime createdAt;
  final String? logoUrl;
  final String? address;
  final bool restrictConcurrentLogins;
  final String? activeAdminId;
  final bool isLocked;
  final String? inviteCode;
  final int failedLoginThreshold;

  const OrganizationEntity({
    required this.id,
    required this.name,
    required this.adminId,
    required this.createdAt,
    this.logoUrl,
    this.address,
    this.restrictConcurrentLogins = false,
    this.activeAdminId,
    this.isLocked = false,
    this.inviteCode,
    this.failedLoginThreshold = 5,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        adminId,
        createdAt,
        logoUrl,
        address,
        restrictConcurrentLogins,
        activeAdminId,
        isLocked,
        inviteCode,
        failedLoginThreshold,
      ];
}
