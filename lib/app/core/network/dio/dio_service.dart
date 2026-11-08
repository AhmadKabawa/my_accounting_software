// lib/core/network/dio_service.dart

import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/core/storage/secure/token_manager.dart';
import 'package:accounting_software/app/core/network/dio/interceptors/connectivity_interceptor.dart';
import 'package:accounting_software/app/core/network/dio/interceptors/language_interceptor.dart';
import 'package:accounting_software/app/core/network/network_info/network_info.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioService {
  late final Dio _dio;

  /// [refreshEndpoint] is the backend's token endpoint, used to renew the
  /// session after a 401. It comes from the composition root because core
  /// cannot import the feature that owns it.
  DioService({
    required TokenManager tokenManager,
    required NetworkInfo networkInfoImpl,
    required LanguageProvider languageProvider,
    required AppEndpoint refreshEndpoint,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: AppConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'apikey':
              AppConfig.supabaseAnonKey, // for Supabase or similar services
        },

        // validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.addAll([
      // 1. تحقق من الاتصال أولاً قبل أي شيء
      ConnectivityInterceptor(networkInfo: networkInfoImpl),
      LanguageInterceptor(languageProvider: languageProvider),
      // 2. أضف Auth token للـ request
      AuthInterceptor(tokenManager),

      // 3. جدّد الـ token عند 401
      RefreshTokenInterceptor(
        _dio,
        tokenManager,
        refreshEndpoint: refreshEndpoint,
      ),

      // 4. أعد المحاولة عند الفشل
      RetryInterceptor(_dio),

      // 5. سجّل الطلب النهائي (بعد كل التعديلات)
      LoggerInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}
