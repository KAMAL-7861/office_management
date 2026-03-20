import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class EmployeeTaskListScreen extends StatefulWidget {
  const EmployeeTaskListScreen({super.key});

  @override
  State<EmployeeTaskListScreen> createState() => _EmployeeTaskListScreenState();
}

class _EmployeeTaskListScreenState extends State<EmployeeTaskListScreen> {
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<TaskBloc>()
          .add(FetchAssignedTasksRequested(authState.user.id));
    }
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.statusPending;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.submitted:
        return AppColors.statusSubmitted;
      case TaskStatus.approved:
        return AppColors.statusApproved;
      case TaskStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.hourglass_empty_rounded;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline_rounded;
      case TaskStatus.submitted:
        return Icons.upload_file_outlined;
      case TaskStatus.approved:
        return Icons.check_circle_outline_rounded;
      case TaskStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.submitted:
        return 'Submitted';
      case TaskStatus.approved:
        return 'Approved';
      case TaskStatus.rejected:
        return 'Rejected';
    }
  }

  void _showTaskDetailDialog(TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(task.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoRow('Assigned By', task.assignedByName ?? 'Unknown'),
                const SizedBox(height: 10),
                _infoRow('Status', _statusLabel(task.status)),
                const SizedBox(height: 10),
                _infoRow('Created',
                    task.createdAt.toLocal().toString().split('.')[0]),
                const SizedBox(height: 14),
                const Text(
                  'Description:',
                  style: TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(task.description,
                    style: const TextStyle(color: AppColors.subtitleGrey)),
                if (task.feedback != null && task.feedback!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _statusColor(task.status).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _statusColor(task.status).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manager Feedback:',
                          style: TextStyle(
                            color: _statusColor(task.status),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(task.feedback!,
                            style: const TextStyle(
                                color: AppColors.subtitleGrey)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (task.status == TaskStatus.pending) ...[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              TealButton(
                label: 'Start Working',
                height: 40,
                onTap: () {
                  context.read<TaskBloc>().add(UpdateTaskStatusRequested(
                        task.id,
                        TaskStatus.inProgress,
                      ));
                  Navigator.pop(dialogContext);
                  Future.delayed(
                      const Duration(milliseconds: 500), _loadTasks);
                },
              ),
            ] else if (task.status == TaskStatus.inProgress) ...[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              TealButton(
                label: 'Submit Task',
                height: 40,
                onTap: () {
                  context.read<TaskBloc>().add(UpdateTaskStatusRequested(
                        task.id,
                        TaskStatus.submitted,
                      ));
                  Navigator.pop(dialogContext);
                  Future.delayed(
                      const Duration(milliseconds: 500), _loadTasks);
                },
              ),
            ] else
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        Expanded(
            child: Text(value,
                style: const TextStyle(color: AppColors.subtitleGrey))),
      ],
    );
  }

  Widget? _getTrailingAction(TaskEntity task) {
    if (task.status == TaskStatus.pending) {
      return const Tooltip(
        message: 'Tap to start',
        child:
            Icon(Icons.play_arrow_rounded, color: AppColors.statusInProgress),
      );
    } else if (task.status == TaskStatus.inProgress) {
      return const Tooltip(
        message: 'Tap to submit',
        child: Icon(Icons.upload_rounded, color: AppColors.statusSubmitted),
      );
    }
    return const Icon(Icons.chevron_right, color: AppColors.labelGrey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050807),
      appBar: themedAppBar(
        title: 'My Tasks',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.teal),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: AppBackground(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            } else if (state is TaskError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.statusRejected),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}',
                        style:
                            const TextStyle(color: AppColors.subtitleGrey)),
                    const SizedBox(height: 16),
                    TealButton(
                        label: 'Retry', onTap: _loadTasks, height: 48),
                  ],
                ),
              );
            } else if (state is TasksLoaded) {
              if (state.tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 64,
                          color: AppColors.labelGrey.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      const Text(
                        'No tasks assigned to you',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.subtitleGrey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tasks assigned by your manager will appear here',
                        style: TextStyle(
                            color: AppColors.labelGrey, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  final color = _statusColor(task.status);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                              width: 1,
                            ),
                          ),
                          child: Icon(_statusIcon(task.status),
                              color: Colors.white, size: 20),
                        ),
                        title: Text(
                          task.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'From: ${task.assignedByName ?? "Unknown"}',
                              style: const TextStyle(
                                  color: AppColors.subtitleGrey,
                                  fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            statusChip(_statusLabel(task.status), color),
                          ],
                        ),
                        trailing: _getTrailingAction(task),
                        onTap: () => _showTaskDetailDialog(task),
                        isThreeLine: true,
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
                child: Text('Tap refresh to load tasks',
                    style: TextStyle(color: AppColors.subtitleGrey)));
          },
        ),
      ),
    );
  }
}
