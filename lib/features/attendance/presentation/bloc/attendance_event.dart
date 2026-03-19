import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class CheckInRequested extends AttendanceEvent {
  final AttendanceEntity attendance;
  const CheckInRequested(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

class CheckOutRequested extends AttendanceEvent {
  final String attendanceId;
  final DateTime checkOutTime;
  const CheckOutRequested(this.attendanceId, this.checkOutTime);

  @override
  List<Object?> get props => [attendanceId, checkOutTime];
}

class FetchAttendanceHistory extends AttendanceEvent {
  final String userId;
  const FetchAttendanceHistory(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SyncOfflineAttendance extends AttendanceEvent {}
