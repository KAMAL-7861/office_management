import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class AppStarted extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  final String? organizationName;
  final String? inviteCode;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.organizationName,
    this.inviteCode,
  });

  @override
  List<Object?> get props => [email, password, name, role, organizationName, inviteCode];
}
