import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/cache_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/hive_storage/hive_box_names.dart';
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

Future<void> initAuthDI() async {
  // The users box and its adapter belong to this feature, not to core.
  final usersBox = await HiveManager.openBox<UserModel>(
    HiveBoxNames.users,
    adapter: UserModelAdapter(),
  );

  // Auth Feature
  // Bloc — singleton: the router guards and the screens must observe the same
  // session state. Provide it with BlocProvider.value so it is never closed.
  sl.registerLazySingleton(
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
    () => HiveObjectBox(usersBox),
  );

  // 3. CacheManager — JSON cache العام
  sl.registerLazySingleton(
    () => CacheManager(stringCache: sl<HiveStorageService>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(userBox: sl(), tokenManager: sl()),
  );
}
