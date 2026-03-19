import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> submitTask(TaskEntity task) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.submitTask(TaskModel.fromEntity(task));
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ServerFailure('Connection required to submit tasks'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getTasks(userId);
        return Right(tasks);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ServerFailure('Connection required to fetch tasks'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(String organizationId) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getAllTasks(organizationId);
        return Right(tasks);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ServerFailure('Connection required to fetch tasks'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTaskStatus(
      String taskId, TaskStatus status,
      {String? feedback}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateTaskStatus(taskId, status,
            feedback: feedback);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(
          ServerFailure('Connection required to update task status'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAssignedTasks(
      String employeeId) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getAssignedTasks(employeeId);
        return Right(tasks);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ServerFailure('Connection required to fetch tasks'));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasksAssignedByManager(
      String managerId) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks =
            await remoteDataSource.getTasksAssignedByManager(managerId);
        return Right(tasks);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(ServerFailure('Connection required to fetch tasks'));
    }
  }
}
