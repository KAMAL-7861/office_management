import 'package:equatable/equatable.dart';

enum AttendanceStatus { onTime, late, earlyLeave, absent }

class AttendanceEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final double latitude;
  final double longitude;
  final AttendanceStatus status;
  final String organizationId;
  final String? deviceId;

  const AttendanceEntity({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.checkIn,
    this.checkOut,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.deviceId,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        organizationId,
        checkIn,
        checkOut,
        latitude,
        longitude,
        status,
        deviceId,
      ];
}
