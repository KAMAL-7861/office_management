import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: const Color(0xFF050807),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 18, 0, 0),
                  child: Row(
                    children: [
                      const Text(
                        'Smart Office',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Logout',
                        onPressed: () =>
                            context.read<AuthBloc>().add(LogoutRequested()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ── Greeting ──────────────────────────────────────
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: AppColors.subtitleGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.role.name[0].toUpperCase()}${user.role.name.substring(1)}  ·  ${user.department}',
                  style: const TextStyle(
                    color: AppColors.labelGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),
                // ── Quick action cards ────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _QuickCard(
                        title: 'Check-In',
                        icon: Icons.location_on_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CheckInScreen()),
                        ).then((_) {
                          context
                              .read<AttendanceBloc>()
                              .add(FetchAttendanceHistory(user.id));
                        }),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _QuickCard(
                        title: 'My Tasks',
                        icon: Icons.assignment_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => sl<TaskBloc>(),
                              child: const EmployeeTaskListScreen(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // ── Today's Summary ───────────────────────────────
                const Text(
                  "Today's Summary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) {
                    String subtitle = 'Not checked in yet';
                    IconData icon = Icons.access_time_outlined;

                    if (state is AttendanceLoading) {
                      return GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.teal,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Loading status...',
                              style: TextStyle(color: AppColors.subtitleGrey),
                            ),
                          ],
                        ),
                      );
                    } else if (state is AttendanceSuccess) {
                      subtitle =
                          'Checked in at ${state.attendance.checkIn.toLocal().toString().split('.')[0]}';
                      icon = Icons.check_circle_outline;
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
                          icon = Icons.logout;
                        } else {
                          subtitle =
                              'Checked in at ${latest.checkIn.toLocal().toString().split('.')[0]}';
                          icon = Icons.check_circle_outline;
                        }
                      }
                    }

                    return GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                            child: Icon(icon, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check-in Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: AppColors.subtitleGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        splashColor: AppColors.teal.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
