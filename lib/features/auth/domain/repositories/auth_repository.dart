import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/organization_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> registerEmployee(
      UserEntity user, String password);
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? organizationName,
    String? inviteCode,
  });
  Future<Either<Failure, List<UserEntity>>> getAllEmployees();
  Future<Either<Failure, OrganizationEntity>> getOrganization(String organizationId);
  Future<Either<Failure, void>> updateOrganizationSettings(String organizationId, {bool? restrictConcurrentLogins, bool? isLocked});
  Future<Either<Failure, void>> approveEmployee(String userId);
}
