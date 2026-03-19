import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class SubmitTaskUseCase {
  final TaskRepository repository;
  SubmitTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(TaskEntity task) async {
    return await repository.submitTask(task);
  }
}

class GetTasksUseCase {
  final TaskRepository repository;
  GetTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String userId) async {
    return await repository.getTasks(userId);
  }
}

class UpdateTaskStatusUseCase {
  final TaskRepository repository;
  UpdateTaskStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String taskId, TaskStatus status,
      {String? feedback}) async {
    return await repository.updateTaskStatus(taskId, status,
        feedback: feedback);
  }
}

class GetAssignedTasksUseCase {
  final TaskRepository repository;
  GetAssignedTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String employeeId) async {
    return await repository.getAssignedTasks(employeeId);
  }
}

class GetTasksAssignedByManagerUseCase {
  final TaskRepository repository;
  GetTasksAssignedByManagerUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String managerId) async {
    return await repository.getTasksAssignedByManager(managerId);
  }
}

class GetAllTasksUseCase {
  final TaskRepository repository;
  GetAllTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String organizationId) async {
    return await repository.getAllTasks(organizationId);
  }
}
