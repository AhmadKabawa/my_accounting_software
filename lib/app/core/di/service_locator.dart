import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:accounting_software/app/core/foundation/config/env_config.dart';
import 'package:accounting_software/app/core/foundation/localization/cubit/locale_cubit.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/app_settings_manager_sorage.dart';
import 'package:accounting_software/app/core/services/local_storage/shared_storage/prefs_storage_service.dart';
import 'package:accounting_software/app/core/services/network/api_client_interface.dart';
import 'package:accounting_software/app/core/services/network/dio/api_client.dart';
import 'package:accounting_software/app/core/services/network/dio/dio_service.dart';
import 'package:accounting_software/app/core/services/network/dio/interceptors/language_interceptor.dart';
import 'package:accounting_software/app/core/services/network/network_info/network_info.dart';
import 'package:accounting_software/app/core/services/network/network_info/network_info_impl.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/secure_storage_service.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/cubit/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

/// Registers core infrastructure only. Features register themselves from
/// the composition root (lib/app/app_di.dart).
Future<void> initCoreDI() async {
  //! ==================== External ====================
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      clientId: EnvConfig.googleClientId,
      scopes: ['email', 'profile'],
    ),
  );
  // Connectivity
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Network Info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(secureStorage: sl()),
  );

  sl.registerLazySingleton<TokenManager>(
    () => TokenManager(storage: sl<SecureStorageService>()),
  );
  // Dio

  sl.registerLazySingleton<DioService>(
    () => DioService(
      tokenManager: sl(),
      networkInfoImpl: sl(),
      languageProvider: sl(),
    ),
  );
  sl.registerLazySingleton<IApiClient>(() => ApiClient(dioService: sl()));

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<PrefsStorageService>(
    () => PrefsStorageService(prefs: sl()),
  );
  sl.registerLazySingleton<AppSettingsManager>(
    () => AppSettingsManager(storage: sl<PrefsStorageService>()),
  );

  //! ==================== Core ====================
  // StorageService (IMPORTANT)
  // sl.registerLazySingleton<StorageService>(
  //   () => PrefsStorageService(prefs: sl()),
  // );

  //! ==================== Theme & Localization ====================

  // Theme
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(appSettingsManager: sl()),
  );

  // Localization
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(appSettingsManager: sl()),
  );
  sl.registerLazySingleton<LanguageProvider>(
    () => AppLanguageProvider(localeCubit: sl()),
  );
}
