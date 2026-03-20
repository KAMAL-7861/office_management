import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/auth_usecases.dart';
import 'admin_employee_detail_screen.dart';

class AdminEmployeesScreen extends StatefulWidget {
  const AdminEmployeesScreen({super.key});

  @override
  State<AdminEmployeesScreen> createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  late Future<List<UserEntity>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  void _fetchEmployees() {
    setState(() {
      _employeesFuture = sl<GetAllEmployeesUseCase>().call().then(
            (result) => result.fold(
              (failure) => throw Exception(failure.message),
              (employees) => employees,
            ),
          );
    });
  }

  Color _statusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return AppColors.statusApproved;
      case UserStatus.pending:
        return AppColors.statusPending;
      default:
        return AppColors.statusRejected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050807),
      appBar: themedAppBar(
        title: 'Employees',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.teal),
            onPressed: _fetchEmployees,
          ),
        ],
      ),
      body: AppBackground(
        child: FutureBuilder<List<UserEntity>>(
          future: _employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.teal));
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.subtitleGrey),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline,
                        size: 60,
                        color: AppColors.labelGrey.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    const Text(
                      'No employees found.',
                      style: TextStyle(
                          color: AppColors.subtitleGrey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            final employees = snapshot.data!;
            return ListView.builder(
              itemCount: employees.length,
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              itemBuilder: (context, index) {
                final employee = employees[index];
                final statusColor = _statusColor(employee.status);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.08),
                        child: Text(
                          employee.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        employee.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${employee.role.name[0].toUpperCase()}${employee.role.name.substring(1)}  ·  ${employee.department}',
                            style: const TextStyle(
                                color: AppColors.subtitleGrey, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          statusChip(
                              employee.status.name.toUpperCase(), statusColor),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (employee.status == UserStatus.pending)
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline,
                                  color: AppColors.statusApproved),
                              tooltip: 'Approve',
                              onPressed: () async {
                                final result = await sl<
                                        ApproveEmployeeUseCase>()
                                    .call(employee.id);
                                result.fold(
                                  (failure) =>
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Error: ${failure.message}'))),
                                  (_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Employee approved')),
                                    );
                                    _fetchEmployees();
                                  },
                                );
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.info_outline,
                                color: AppColors.teal),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminEmployeeDetailScreen(
                                    employee: employee),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.statusRejected),
                            tooltip: 'Delete/Reject',
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Delete functionality coming soon')),
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
