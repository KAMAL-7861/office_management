import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/task_usecases.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final SubmitTaskUseCase submitTaskUseCase;
  final GetTasksUseCase getTasksUseCase;
  final UpdateTaskStatusUseCase updateStatusUseCase;
  final GetAssignedTasksUseCase getAssignedTasksUseCase;
  final GetTasksAssignedByManagerUseCase getTasksAssignedByManagerUseCase;

  TaskBloc({
    required this.submitTaskUseCase,
    required this.getTasksUseCase,
    required this.updateStatusUseCase,
    required this.getAssignedTasksUseCase,
    required this.getTasksAssignedByManagerUseCase,
  }) : super(TaskInitial()) {
    on<SubmitTaskRequested>(_onSubmitTaskRequested);
    on<FetchTasksRequested>(_onFetchTasksRequested);
    on<UpdateTaskStatusRequested>(_onUpdateTaskStatusRequested);
    on<FetchAssignedTasksRequested>(_onFetchAssignedTasksRequested);
    on<FetchManagerTasksRequested>(_onFetchManagerTasksRequested);
  }

  Future<void> _onSubmitTaskRequested(
      SubmitTaskRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await submitTaskUseCase(event.task);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => emit(TaskOperationSuccess()),
    );
  }

  Future<void> _onFetchTasksRequested(
      FetchTasksRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTasksUseCase(event.userId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }

  Future<void> _onUpdateTaskStatusRequested(
      UpdateTaskStatusRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await updateStatusUseCase(event.taskId, event.status,
        feedback: event.feedback);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => emit(TaskOperationSuccess()),
    );
  }

  Future<void> _onFetchAssignedTasksRequested(
      FetchAssignedTasksRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getAssignedTasksUseCase(event.employeeId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }

  Future<void> _onFetchManagerTasksRequested(
      FetchManagerTasksRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTasksAssignedByManagerUseCase(event.managerId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks)),
    );
  }
}
