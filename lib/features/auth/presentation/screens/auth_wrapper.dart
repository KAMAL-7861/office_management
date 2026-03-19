import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';
import '../../../attendance/presentation/screens/employee_dashboard.dart';
import '../../../admin/presentation/screens/admin_dashboard.dart';
import '../../domain/entities/user_entity.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print('AuthWrapper: Building with state ${state.runtimeType}');

        if (state is Authenticated) {
          print(
              'AuthWrapper: User is authenticated - ${state.user.name}, Role: ${state.user.role}');
          if (state.user.role == UserRole.admin ||
              state.user.role == UserRole.hr ||
              state.user.role == UserRole.manager) {
            print('AuthWrapper: Navigating to AdminDashboard');
            return const AdminDashboard();
          }
          print('AuthWrapper: Navigating to EmployeeDashboard');
          return const EmployeeDashboard();
        } else if (state is Unauthenticated || state is AuthError) {
          print('AuthWrapper: Showing LoginScreen');
          return const LoginScreen();
        }
        print('AuthWrapper: Showing loading indicator');
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
