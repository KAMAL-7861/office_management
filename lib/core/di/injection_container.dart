import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../features/attendance/data/datasources/attendance_local_data_source.dart';
import '../../features/attendance/data/datasources/attendance_remote_data_source.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/attendance_usecases.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/tasks/data/datasources/task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/task_usecases.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/admin/presentation/bloc/employee_detail_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../network/network_info.dart';
import '../utils/storage_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
        signUpUseCase: sl(),
      ));
  sl.registerFactory(() => AttendanceBloc(
        checkInUseCase: sl(),
        checkOutUseCase: sl(),
        getHistoryUseCase: sl(),
        syncUseCase: sl(),
      ));
  sl.registerFactory(() => TaskBloc(
        submitTaskUseCase: sl(),
        getTasksUseCase: sl(),
        updateStatusUseCase: sl(),
        getAssignedTasksUseCase: sl(),
        getTasksAssignedByManagerUseCase: sl(),
      ));
  sl.registerFactory(() => EmployeeDetailBloc(
        getAttendanceHistoryUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetAllEmployeesUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizationUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrganizationSettingsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => CheckInUseCase(sl()));
  sl.registerLazySingleton(() => CheckOutUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistoryUseCase(sl()));
  sl.registerLazySingleton(() => SyncOfflineAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => GetAllAttendanceForDateUseCase(sl()));
  sl.registerLazySingleton(() => SubmitTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignedTasksUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksAssignedByManagerUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTasksUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<StorageRepository>(
      () => StorageRepositoryImpl(storage: sl()));

  // Features - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  // Features - Attendance
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AttendanceLocalDataSource>(
    () => AttendanceLocalDataSourceImpl(),
  );

  // Features - Tasks
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(firestore: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => Connectivity());
}
