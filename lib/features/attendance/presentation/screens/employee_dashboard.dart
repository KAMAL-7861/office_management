import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/screens/employee_task_list_screen.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import 'check_in_screen.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<AttendanceBloc>()
          .add(FetchAttendanceHistory(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as Authenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.name}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${user.role.toString().split('.').last} | Dept: ${user.department}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _DashboardCard(
                    title: 'Check-In',
                    icon: Icons.location_on,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckInScreen()),
                    ).then((_) {
                      context
                          .read<AttendanceBloc>()
                          .add(FetchAttendanceHistory(user.id));
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DashboardCard(
                    title: 'My Tasks',
                    icon: Icons.assignment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<TaskBloc>(),
                            child: const EmployeeTaskListScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                String subtitle = 'Not checked in yet';
                if (state is AttendanceLoading) {
                  return const Card(
                    child: ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('Loading status...'),
                    ),
                  );
                } else if (state is AttendanceSuccess) {
                  subtitle =
                      'Checked in at ${state.attendance.checkIn.toLocal().toString().split('.')[0]}';
                } else if (state is AttendanceHistoryLoaded) {
                  final now = DateTime.now();
                  final todayAttendance = state.history
                      .where((e) =>
                          e.checkIn.year == now.year &&
                          e.checkIn.month == now.month &&
                          e.checkIn.day == now.day)
                      .toList();
                  if (todayAttendance.isNotEmpty) {
                    final latest = todayAttendance.last;
                    if (latest.checkOut != null) {
                      subtitle =
                          'Checked out at ${latest.checkOut!.toLocal().toString().split('.')[0]}';
                    } else {
                      subtitle =
                          'Checked in at ${latest.checkIn.toLocal().toString().split('.')[0]}';
                    }
                  }
                }

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Check-in status'),
                    subtitle: Text(subtitle),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
