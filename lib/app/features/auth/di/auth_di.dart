import 'package:google_sign_in/google_sign_in.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/storage/hive/hive_box_names.dart';
import 'package:accounting_software/app/core/storage/hive/hive_manager.dart';
import 'package:accounting_software/app/core/storage/hive/hive_object_box.dart';
import 'package:accounting_software/app/core/storage/secure/token_manager.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/local_data_source/auth_local_data_source_impl.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:accounting_software/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/change_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/confirm_new_password_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/get_cached_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/login_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/logout_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/register_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/send_reset_code_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/signin_with_google_usecase.dart';
import 'package:accounting_software/app/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:accounting_software/app/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/auth_flow/auth_flow_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/profile/profile_cubit.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/session/session_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';


/// Storage this feature owns (the users box and its adapter). Runs before
/// [initAuthDI], which only registers dependencies.
Future<void> initAuthStorage() async {
  final usersBox = await HiveManager.openBox<UserModel>(
    HiveBoxNames.users,
    adapter: UserModelAdapter(),
  );
  sl.registerLazySingleton<HiveObjectBox<UserModel>>(
    () => HiveObjectBox(usersBox),
  );
}

/// Registers the auth feature. Needs `initCoreDI()` and `initAuthStorage()`.
void initAuthDI() {
  // ============ Cubits ============
  // The session is a singleton: the router, the splash and the screens must
  // observe the same state. Provide it with BlocProvider.value so it is never
  // closed. Splash and the router depend on it only through [SessionGate].
  sl.registerLazySingleton(
    () => SessionCubit(
      getCurrentUser: sl(),
      logout: sl(),
      sessionCleared: sl<TokenManager>().sessionCleared,
      flash: sl<FlashMessages>(),
    ),
  );
  sl.registerLazySingleton<SessionGate>(() => sl<SessionCubit>());

  // One flow cubit per page: loading never leaks between pages.
  sl.registerFactory(
    () => AuthFlowCubit(
      login: sl(),
      register: sl(),
      googleSignIn: sl(),
      sendResetCode: sl(),
      confirmNewPassword: sl(),
      session: sl(),
      flash: sl<FlashMessages>(),
    ),
  );
  sl.registerFactory(
    () => ProfileCubit(
      updateProfile: sl(),
      changePassword: sl(),
      session: sl(),
      flash: sl<FlashMessages>(),
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
  sl.registerLazySingleton(() => ConfirmNewPasswordUseCase(repository: sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(repository: sl()));

  // Profile Management
  sl.registerLazySingleton(() => UpdateProfileUseCase(repository: sl()));

  // Session Management
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), local: sl()),
  );

  // Google Sign-In belongs to this feature; the client ID comes from AppConfig.
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      clientId: AppConfig.googleClientId,
      scopes: ['email', 'profile'],
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl(), googleSignIn: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(userBox: sl(), tokenManager: sl()),
  );
}
