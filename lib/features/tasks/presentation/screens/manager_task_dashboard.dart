import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import 'assign_task_screen.dart';

class ManagerTaskDashboard extends StatefulWidget {
  const ManagerTaskDashboard({super.key});

  @override
  State<ManagerTaskDashboard> createState() => _ManagerTaskDashboardState();
}

class _ManagerTaskDashboardState extends State<ManagerTaskDashboard> {
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
          .add(FetchManagerTasksRequested(authState.user.id));
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
                _buildInfoRow('Assigned To', task.assignedToName ?? 'Unknown'),
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
                  const Text(
                    'Feedback:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(task.feedback!),
                ],
              ],
            ),
          ),
          actions: [
            if (task.status == TaskStatus.submitted) ...[
              TextButton(
                onPressed: () {
                  context.read<TaskBloc>().add(
                        UpdateTaskStatusRequested(
                          task.id,
                          TaskStatus.rejected,
                          feedback: 'Task rejected by manager',
                        ),
                      );
                  Navigator.pop(dialogContext);
                  _loadTasks();
                },
                child: const Text(
                  'Reject',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<TaskBloc>().add(
                        UpdateTaskStatusRequested(
                          task.id,
                          TaskStatus.approved,
                          feedback: 'Task approved by manager',
                        ),
                      );
                  Navigator.pop(dialogContext);
                  _loadTasks();
                },
                child: const Text('Approve'),
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
        title: const Text('Task Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final taskBloc = context.read<TaskBloc>();
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: taskBloc,
                child: const AssignTaskScreen(),
              ),
            ),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Assign Task'),
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
                      'No tasks assigned yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the button below to assign a task',
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
                            'Assigned to: ${task.assignedToName ?? "Unknown"}'),
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
                    trailing: const Icon(Icons.chevron_right),
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
}
