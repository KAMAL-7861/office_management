import '../../domain/entities/organization_entity.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    required super.name,
    required super.adminId,
    required super.createdAt,
    super.logoUrl,
    super.address,
    super.restrictConcurrentLogins,
    super.activeAdminId,
    super.isLocked,
    super.inviteCode,
    super.failedLoginThreshold,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      adminId: json['adminId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      logoUrl: json['logoUrl'] as String?,
      address: json['address'] as String?,
      restrictConcurrentLogins: json['restrictConcurrentLogins'] as bool? ?? false,
      activeAdminId: json['activeAdminId'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      inviteCode: json['inviteCode'] as String?,
      failedLoginThreshold: json['failedLoginThreshold'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'adminId': adminId,
      'createdAt': createdAt.toIso8601String(),
      'logoUrl': logoUrl,
      'address': address,
      'restrictConcurrentLogins': restrictConcurrentLogins,
      'activeAdminId': activeAdminId,
      'isLocked': isLocked,
      'inviteCode': inviteCode,
      'failedLoginThreshold': failedLoginThreshold,
    };
  }

  factory OrganizationModel.fromEntity(OrganizationEntity entity) {
    return OrganizationModel(
      id: entity.id,
      name: entity.name,
      adminId: entity.adminId,
      createdAt: entity.createdAt,
      logoUrl: entity.logoUrl,
      address: entity.address,
      restrictConcurrentLogins: entity.restrictConcurrentLogins,
      activeAdminId: entity.activeAdminId,
      isLocked: entity.isLocked,
      inviteCode: entity.inviteCode,
      failedLoginThreshold: entity.failedLoginThreshold,
    );
  }
}
