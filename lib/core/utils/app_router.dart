import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/auth_wrapper.dart';
import '../../features/attendance/presentation/screens/employee_dashboard.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/employee_dashboard':
        return MaterialPageRoute(builder: (_) => const EmployeeDashboard());
      case '/admin_dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboard());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
