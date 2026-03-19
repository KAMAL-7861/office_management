import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../datasources/attendance_remote_data_source.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AttendanceEntity>> checkIn(
      AttendanceEntity attendance) async {
    final model = AttendanceModel.fromEntity(attendance);
    if (await networkInfo.isConnected) {
      try {
        final remoteAttendance = await remoteDataSource.checkIn(model);
        return Right(remoteAttendance);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        await localDataSource.cacheAttendance(model);
        return Right(attendance); // Representing successful local save
      } on CacheException {
        return const Left(CacheFailure('Failed to cache attendance'));
      }
    }
  }

  @override
  Future<Either<Failure, AttendanceEntity>> checkOut(
      String attendanceId, DateTime checkOutTime) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAttendance =
            await remoteDataSource.checkOut(attendanceId, checkOutTime);
        return Right(remoteAttendance);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(CacheFailure(
          'Offline check-out not supported yet. Please connect to internet.'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAttendanceHistory(
      String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteHistory =
            await remoteDataSource.getAttendanceHistory(userId);
        return Right(remoteHistory);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(CacheFailure('Cannot fetch history while offline'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceEntity>>> getAllAttendanceForDate(
      DateTime date, String organizationId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteDataSource.getAllAttendanceForDate(date, organizationId);
        return Right(remoteData);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(CacheFailure('Cannot fetch data while offline'));
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineAttendance() async {
    if (await networkInfo.isConnected) {
      try {
        final localData = await localDataSource.getCachedAttendance();
        for (var attendance in localData) {
          await remoteDataSource.checkIn(attendance);
        }
        await localDataSource.clearCache();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on CacheException {
        return const Left(CacheFailure('Failed to sync local data'));
      }
    }
    return const Left(ServerFailure('Connect to internet to sync'));
  }
}
