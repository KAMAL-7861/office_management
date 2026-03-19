import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/organization_entity.dart';
import '../repositories/auth_repository.dart';

class GetOrganizationUseCase {
  final AuthRepository repository;
  GetOrganizationUseCase(this.repository);

  Future<Either<Failure, OrganizationEntity>> call(String organizationId) async {
    return await repository.getOrganization(organizationId);
  }
}

class UpdateOrganizationSettingsUseCase {
  final AuthRepository repository;
  UpdateOrganizationSettingsUseCase(this.repository);

  Future<Either<Failure, void>> call(String organizationId,
      {bool? restrictConcurrentLogins, bool? isLocked}) async {
    return await repository.updateOrganizationSettings(organizationId,
        restrictConcurrentLogins: restrictConcurrentLogins, isLocked: isLocked);
  }
}

class ApproveEmployeeUseCase {
  final AuthRepository repository;
  ApproveEmployeeUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.approveEmployee(userId);
  }
}

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) async {
    return await repository.login(email, password);
  }
}

class LogoutUseCase {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? organizationName,
    String? inviteCode,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      name: name,
      role: role,
      organizationName: organizationName,
      inviteCode: inviteCode,
    );
  }
}

class GetAllEmployeesUseCase {
  final AuthRepository repository;
  GetAllEmployeesUseCase(this.repository);

  Future<Either<Failure, List<UserEntity>>> call() async {
    return await repository.getAllEmployees();
  }
}
