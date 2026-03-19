import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<UserEntity> _employees = [];
  UserEntity? _selectedEmployee;
  bool _loadingEmployees = true;
  String? _employeeError;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final result = await sl<GetAllEmployeesUseCase>().call();
    result.fold(
      (failure) {
        setState(() {
          _employeeError = failure.message;
          _loadingEmployees = false;
        });
      },
      (employees) {
        // Filter to only show employees (not admins/managers)
        final filteredEmployees =
            employees.where((e) => e.role == UserRole.employee).toList();
        setState(() {
          _employees = filteredEmployees;
          _loadingEmployees = false;
        });
      },
    );
  }

  void _assignTask() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final manager = authState.user;
    final task = TaskEntity(
      id: const Uuid().v4(),
      userId: manager.id,
      organizationId: manager.organizationId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      status: TaskStatus.pending,
      assignedTo: _selectedEmployee!.id,
      assignedToName: _selectedEmployee!.name,
      assignedBy: manager.id,
      assignedByName: manager.name,
    );

    context.read<TaskBloc>().add(SubmitTaskRequested(task));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Task')),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task assigned successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Employee selection
                  const Text(
                    'Select Employee',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingEmployees)
                    const Center(child: CircularProgressIndicator())
                  else if (_employeeError != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Error loading employees: $_employeeError',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    )
                  else if (_employees.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('No employees found.'),
                      ),
                    )
                  else
                    DropdownButtonFormField<UserEntity>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose an employee',
                        prefixIcon: Icon(Icons.person),
                      ),
                      value: _selectedEmployee,
                      items: _employees.map((employee) {
                        return DropdownMenuItem(
                          value: employee,
                          child: Text(
                            '${employee.name} (${employee.department})',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEmployee = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an employee';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),

                  // Task title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Task description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Task Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 80),
                        child: Icon(Icons.description),
                      ),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a task description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Selected employee info card
                  if (_selectedEmployee != null)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                _selectedEmployee!.name[0].toUpperCase(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assigning to: ${_selectedEmployee!.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Department: ${_selectedEmployee!.department}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Submit button
                  if (state is TaskLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _assignTask,
                        icon: const Icon(Icons.assignment_turned_in),
                        label: const Text(
                          'Assign Task',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
