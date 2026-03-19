import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.userId,
    required super.organizationId,
    required super.checkIn,
    super.checkOut,
    required super.latitude,
    required super.longitude,
    required super.status,
    super.deviceId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      checkIn: json['checkIn'] != null ? (json['checkIn'] as Timestamp).toDate() : DateTime.now(),
      checkOut: json['checkOut'] != null
          ? (json['checkOut'] as Timestamp).toDate()
          : null,
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AttendanceStatus.onTime,
      ),
      deviceId: json['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'organizationId': organizationId,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.toString().split('.').last,
      'deviceId': deviceId,
    };
  }

  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    return AttendanceModel(
      id: entity.id,
      userId: entity.userId,
      organizationId: entity.organizationId,
      checkIn: entity.checkIn,
      checkOut: entity.checkOut,
      latitude: entity.latitude,
      longitude: entity.longitude,
      status: entity.status,
      deviceId: entity.deviceId,
    );
  }
}
