import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class SubmitTaskRequested extends TaskEvent {
  final TaskEntity task;
  const SubmitTaskRequested(this.task);

  @override
  List<Object?> get props => [task];
}

class FetchTasksRequested extends TaskEvent {
  final String userId;
  const FetchTasksRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateTaskStatusRequested extends TaskEvent {
  final String taskId;
  final TaskStatus status;
  final String? feedback;

  const UpdateTaskStatusRequested(this.taskId, this.status, {this.feedback});

  @override
  List<Object?> get props => [taskId, status, feedback];
}

class FetchAssignedTasksRequested extends TaskEvent {
  final String employeeId;
  const FetchAssignedTasksRequested(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class FetchManagerTasksRequested extends TaskEvent {
  final String managerId;
  const FetchManagerTasksRequested(this.managerId);

  @override
  List<Object?> get props => [managerId];
}
