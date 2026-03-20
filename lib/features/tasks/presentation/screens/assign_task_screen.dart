import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
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
      (failure) => setState(() {
        _employeeError = failure.message;
        _loadingEmployees = false;
      }),
      (employees) => setState(() {
        _employees =
            employees.where((e) => e.role == UserRole.employee).toList();
        _loadingEmployees = false;
      }),
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
      backgroundColor: AppColors.bgBase,
      appBar: themedAppBar(title: 'Assign Task'),
      body: AppBackground(
        child: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task assigned successfully!')),
              );
              Navigator.pop(context, true);
            } else if (state is TaskError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              child: Form(
                key: _formKey,
                child: GlassCard(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Heading ──────────────────────────────
                      const Text(
                        'New Task',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Fill in the details and assign to an employee.',
                        style: TextStyle(
                            color: AppColors.subtitleGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 28),

                      // ── Employee selector ────────────────────
                      const Text(
                        'Assign To',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_loadingEmployees)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                                color: AppColors.teal),
                          ),
                        )
                      else if (_employeeError != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.statusRejected.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.statusRejected
                                    .withOpacity(0.3)),
                          ),
                          child: Text(
                            'Error loading employees: $_employeeError',
                            style: const TextStyle(
                                color: AppColors.statusRejected),
                          ),
                        )
                      else if (_employees.isEmpty)
                        const Text(
                          'No employees found.',
                          style:
                              TextStyle(color: AppColors.subtitleGrey),
                        )
                      else
                        DropdownButtonFormField<UserEntity>(
                          dropdownColor: const Color(0xFF1A2B1C),
                          value: _selectedEmployee,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.labelGrey,
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Choose an employee',
                            prefixIcon: Icon(Icons.person_outline_rounded,
                                color: AppColors.labelGrey),
                          ),
                          items: _employees.map((employee) {
                            return DropdownMenuItem(
                              value: employee,
                              child: Text(
                                '${employee.name} · ${employee.department}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedEmployee = value),
                          validator: (value) => value == null
                              ? 'Please select an employee'
                              : null,
                        ),

                      // ── Selected employee preview ─────────────
                      if (_selectedEmployee != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.teal.withOpacity(0.25)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    AppColors.teal.withOpacity(0.2),
                                child: Text(
                                  _selectedEmployee!.name[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedEmployee!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _selectedEmployee!.department,
                                    style: const TextStyle(
                                        color: AppColors.subtitleGrey,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Title ────────────────────────────────
                      const Text(
                        'Task Title',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter a task title'
                            : null,
                        decoration:
                            const InputDecoration(hintText: 'e.g. Prepare report'),
                      ),
                      const SizedBox(height: 22),

                      // ── Description ──────────────────────────
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 15),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter a description'
                            : null,
                        decoration: const InputDecoration(
                            hintText: 'Describe what needs to be done...'),
                      ),
                      const SizedBox(height: 32),

                      // ── Submit ───────────────────────────────
                      TealButton(
                        label: 'Assign Task',
                        isLoading: state is TaskLoading,
                        onTap: _assignTask,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
