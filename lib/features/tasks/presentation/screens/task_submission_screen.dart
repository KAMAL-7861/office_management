import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class TaskSubmissionScreen extends StatefulWidget {
  const TaskSubmissionScreen({super.key});

  @override
  State<TaskSubmissionScreen> createState() => _TaskSubmissionScreenState();
}

class _TaskSubmissionScreenState extends State<TaskSubmissionScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _submitTask() {
    final user = (context.read<AuthBloc>().state as Authenticated).user;
    final task = TaskEntity(
      id: const Uuid().v4(),
      userId: user.id,
      organizationId: user.organizationId,
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: DateTime.now(),
      status: TaskStatus.pending,
    );

    context.read<TaskBloc>().add(SubmitTaskRequested(task));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Daily Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskOperationSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task submitted successfully!')),
              );
            } else if (state is TaskError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 24),
                if (state is TaskLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitTask,
                    child: const Text('Submit Task'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
