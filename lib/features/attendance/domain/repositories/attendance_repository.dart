import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, AttendanceEntity>> checkIn(
      AttendanceEntity attendance);
  Future<Either<Failure, AttendanceEntity>> checkOut(
      String attendanceId, DateTime checkOutTime);
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistory(
      String userId);
  Future<Either<Failure, List<AttendanceEntity>>> getAllAttendanceForDate(
      DateTime date, String organizationId);
  Future<Either<Failure, void>> syncOfflineAttendance();
}
