import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/localization/cubit/locale_cubit.dart';
import 'package:accounting_software/app/core/storage/hive/cache_manager.dart';
import 'package:accounting_software/app/core/storage/hive/hive_manager.dart';
import 'package:accounting_software/app/core/storage/hive/hive_storage_service.dart';
import 'package:accounting_software/app/core/storage/secure/token_manager.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/prefs_storage_service.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/dio/api_client.dart';
import 'package:accounting_software/app/core/network/dio/dio_service.dart';
import 'package:accounting_software/app/core/network/dio/interceptors/language_interceptor.dart';
import 'package:accounting_software/app/core/network/network_info/network_info.dart';
import 'package:accounting_software/app/core/network/network_info/network_info_impl.dart';
import 'package:accounting_software/app/core/storage/secure/secure_storage_service.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/cubit/theme_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

/// Registers core infrastructure only. Features register themselves from
/// the composition root (lib/app/app_di.dart).
Future<void> initCoreDI() async {
  //! ==================== External ====================
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
  // Hive-backed cache. Lazy: `HiveManager.init()` (main) has opened the box by
  // the time anything resolves these.
  sl.registerLazySingleton<HiveStorageService>(
    () => HiveStorageService(box: HiveManager.cacheBox),
  );
  sl.registerLazySingleton<CacheManager>(
    () => CacheManager(stringCache: sl<HiveStorageService>()),
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

  // Messages that must survive a page change (sign-out, session expired...)
  sl.registerLazySingleton<FlashMessages>(FlashMessages.new);

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

  //! ==================== Access Control ====================
  // Singleton: guards, widgets and use cases must observe the same role.
  sl.registerLazySingleton<AccessCubit>(() => AccessCubit());
}
