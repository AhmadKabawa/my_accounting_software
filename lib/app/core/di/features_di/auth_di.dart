import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/cache_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_object_box.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_storage_service.dart';
import 'package:accounting_software/app/core/services/local_storage/storage_service.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source_impl.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/reset_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/verify_reset_code_usecase.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';

import '../../../features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

void initAuthDI() {
  // Auth Feature
  // Bloc
  sl.registerFactory(
    () => AuthCubit(
      login: sl(),
      register: sl(),
      logout: sl(),
      sendResetCode: sl(),
      verifyResetCode: sl(),
      confirmNewPassword: sl(),
      resetPassword: sl(),
      changePassword: sl(),
      updateProfile: sl(),
      googleSignIn: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );
  // ============ Use Cases ============
  // Basic Auth
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(repository: sl()));

  // Password Management
  sl.registerLazySingleton(() => SendResetCodeUseCase(repository: sl()));
  sl.registerLazySingleton(() => VerifyResetCodeUseCase(repository: sl()));
  sl.registerLazySingleton(() => ConfirmNewPasswordUseCase(repository: sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(repository: sl()));

  // Profile Management
  sl.registerLazySingleton(() => UpdateProfileUseCase(repository: sl()));

  // Session Management
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl(), googleSignIn: sl()),
  );

  // 1. HiveStorageService — للـ primitives والـ JSON
  sl.registerLazySingleton<HiveStorageService>(
    () => HiveStorageService(box: HiveManager.cacheBox),
  );

  // 2. HiveObjectBox — للـ UserModel مباشرة
  sl.registerLazySingleton<HiveObjectBox<UserModel>>(
    () => HiveObjectBox(HiveManager.usersBox),
  );

  // 3. CacheManager — يجمع الاثنين
  sl.registerLazySingleton(
    () => CacheManager(
      stringCache: sl<HiveStorageService>(),
      userBox: sl<HiveObjectBox<UserModel>>(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(cacheManager: sl(), tokenManager: sl()),
  );
}
