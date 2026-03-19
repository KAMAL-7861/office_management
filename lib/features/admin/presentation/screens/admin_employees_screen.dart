import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchEmployees,
          ),
        ],
      ),
      body: FutureBuilder<List<UserEntity>>(
        future: _employeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No employees found.'));
          }

          final employees = snapshot.data!;
          return ListView.builder(
            itemCount: employees.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final employee = employees[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(employee.name[0].toUpperCase()),
                  ),
                  title: Text(employee.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role: ${employee.role.name} | Dept: ${employee.department}'),
                      Row(
                        children: [
                          const Text('Status: '),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: employee.status == UserStatus.active
                                  ? Colors.green.withOpacity(0.1)
                                  : employee.status == UserStatus.pending
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              employee.status.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: employee.status == UserStatus.active
                                    ? Colors.green
                                    : employee.status == UserStatus.pending
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (employee.status == UserStatus.pending)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          tooltip: 'Approve',
                          onPressed: () async {
                            final result = await sl<ApproveEmployeeUseCase>().call(employee.id);
                            result.fold(
                              (failure) => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${failure.message}')),
                              ),
                              (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Employee approved')),
                                );
                                _fetchEmployees();
                              },
                            );
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminEmployeeDetailScreen(employee: employee),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'Delete/Reject',
                        onPressed: () {
                          // TODO: Implement delete/deactivate usecase
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Delete functionality coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
