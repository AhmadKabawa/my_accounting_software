import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:accounting_software/app/core/localization/cubit/locale_cubit.dart';
import 'package:accounting_software/app/core/storage/hive/cache_manager.dart';
import 'package:accounting_software/app/core/storage/hive/hive_manager.dart';
import 'package:accounting_software/app/core/storage/hive/hive_storage_service.dart';
import 'package:accounting_software/app/core/storage/secure/token_manager.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/prefs_storage_service.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/network/dio/api_client.dart';
import 'package:accounting_software/app/core/network/dio/dio_service.dart';
import 'package:accounting_software/app/core/network/dio/interceptors/language_interceptor.dart';
import 'package:accounting_software/app/core/network/network_info/network_info.dart';
import 'package:accounting_software/app/core/network/network_info/network_info_impl.dart';
import 'package:accounting_software/app/core/network/storage/storage_image_uploader.dart';
import 'package:accounting_software/app/core/platform/platform_capabilities.dart';
import 'package:accounting_software/app/core/storage/secure/secure_storage_service.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/cubit/theme_cubit.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_message/flash_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

/// Registers shared infrastructure. Feature/core access dependencies are
/// registered by their own DI entry points from the composition root.
Future<void> initCoreDI({required AppEndpoint refreshEndpoint}) async {
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
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
  sl.registerLazySingleton<HiveStorageService>(
    () => HiveStorageService(box: HiveManager.cacheBox),
  );
  sl.registerLazySingleton<CacheManager>(
    () => CacheManager(stringCache: sl<HiveStorageService>()),
  );
  sl.registerLazySingleton<RequestSendTimeoutCapability>(
    () => const PlatformRequestSendTimeoutCapability(),
  );
  sl.registerLazySingleton<DioService>(
    () => DioService(
      tokenManager: sl(),
      networkInfoImpl: sl(),
      languageProvider: sl(),
      refreshEndpoint: refreshEndpoint,
      requestSendTimeoutCapability: sl(),
    ),
  );
  sl.registerLazySingleton<IApiClient>(() => ApiClient(dioService: sl()));
  sl.registerLazySingleton<StorageImageUploader>(
    () => StorageImageUploader(sl<IApiClient>()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<PrefsStorageService>(
    () => PrefsStorageService(prefs: sl()),
  );
  sl.registerLazySingleton<AppSettingsManager>(
    () => AppSettingsManager(storage: sl<PrefsStorageService>()),
  );
  sl.registerLazySingleton<FlashMessages>(FlashMessages.new);
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(appSettingsManager: sl()),
  );
  sl.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(appSettingsManager: sl()),
  );
  sl.registerLazySingleton<LanguageProvider>(
    () => AppLanguageProvider(localeCubit: sl()),
  );
}
