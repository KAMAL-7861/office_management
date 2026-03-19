import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class CheckInUseCase {
  final AttendanceRepository repository;
  CheckInUseCase(this.repository);

  Future<Either<Failure, AttendanceEntity>> call(
 AttendanceEntity attendance) async {
    return await repository.checkIn(attendance);
  }
}

class CheckOutUseCase {
  final AttendanceRepository repository;
  CheckOutUseCase(this.repository);

  Future<Either<Failure, AttendanceEntity>> call(
      String attendanceId, DateTime checkOutTime) async {
    return await repository.checkOut(attendanceId, checkOutTime);
  }
}

class GetAttendanceHistoryUseCase {
  final AttendanceRepository repository;
  GetAttendanceHistoryUseCase(this.repository);

  Future<Either<Failure, List<AttendanceEntity>>> call(String userId) async {
    return await repository.getAttendanceHistory(userId);
  }
}

class SyncOfflineAttendanceUseCase {
  final AttendanceRepository repository;
  SyncOfflineAttendanceUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.syncOfflineAttendance();
  }
}

class GetAllAttendanceForDateUseCase {
  final AttendanceRepository repository;
  GetAllAttendanceForDateUseCase(this.repository);

  Future<Either<Failure, List<AttendanceEntity>>> call(
      DateTime date, String organizationId) async {
    return await repository.getAllAttendanceForDate(date, organizationId);
  }
}
