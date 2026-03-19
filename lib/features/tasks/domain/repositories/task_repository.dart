import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, void>> submitTask(TaskEntity task);
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId);
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(String organizationId);
  Future<Either<Failure, void>> updateTaskStatus(
      String taskId, TaskStatus status,
      {String? feedback});
  Future<Either<Failure, List<TaskEntity>>> getAssignedTasks(String employeeId);
  Future<Either<Failure, List<TaskEntity>>> getTasksAssignedByManager(
      String managerId);
}
