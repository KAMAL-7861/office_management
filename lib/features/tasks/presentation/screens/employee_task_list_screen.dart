import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.submitted:
        return Colors.purple;
      case TaskStatus.approved:
        return Colors.green;
      case TaskStatus.rejected:
        return Colors.red;
    }
  }

  IconData _statusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.hourglass_empty;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline;
      case TaskStatus.submitted:
        return Icons.upload_file;
      case TaskStatus.approved:
        return Icons.check_circle;
      case TaskStatus.rejected:
        return Icons.cancel;
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
                _buildInfoRow(
                  'Assigned By',
                  task.assignedByName ?? 'Unknown',
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Status', _statusLabel(task.status)),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Created',
                  task.createdAt.toLocal().toString().split('.')[0],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(task.description),
                if (task.feedback != null && task.feedback!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: task.status == TaskStatus.approved
                        ? Colors.green.shade50
                        : task.status == TaskStatus.rejected
                            ? Colors.red.shade50
                            : Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manager Feedback:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(task.feedback!),
                        ],
                      ),
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
              ElevatedButton(
                onPressed: () {
                  context.read<TaskBloc>().add(
                        UpdateTaskStatusRequested(
                          task.id,
                          TaskStatus.inProgress,
                        ),
                      );
                  Navigator.pop(dialogContext);
                  // Small delay to let the update happen
                  Future.delayed(const Duration(milliseconds: 500), _loadTasks);
                },
                child: const Text('Start Working'),
              ),
            ] else if (task.status == TaskStatus.inProgress) ...[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<TaskBloc>().add(
                        UpdateTaskStatusRequested(
                          task.id,
                          TaskStatus.submitted,
                        ),
                      );
                  Navigator.pop(dialogContext);
                  Future.delayed(const Duration(milliseconds: 500), _loadTasks);
                },
                icon: const Icon(Icons.check),
                label: const Text('Submit Task'),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Retry'),
                  ),
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
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No tasks assigned to you',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tasks assigned by your manager will appear here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _statusColor(task.status).withOpacity(0.2),
                      child: Icon(
                        _statusIcon(task.status),
                        color: _statusColor(task.status),
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'From: ${task.assignedByName ?? "Unknown"}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(task.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _statusColor(task.status).withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _statusLabel(task.status),
                            style: TextStyle(
                              fontSize: 12,
                              color: _statusColor(task.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: _getTrailingAction(task),
                    onTap: () => _showTaskDetailDialog(task),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Tap refresh to load tasks'));
        },
      ),
    );
  }

  Widget? _getTrailingAction(TaskEntity task) {
    if (task.status == TaskStatus.pending) {
      return const Tooltip(
        message: 'Tap to start',
        child: Icon(Icons.play_arrow, color: Colors.blue),
      );
    } else if (task.status == TaskStatus.inProgress) {
      return const Tooltip(
        message: 'Tap to submit',
        child: Icon(Icons.upload, color: Colors.purple),
      );
    } else {
      return const Icon(Icons.chevron_right);
    }
  }
}
