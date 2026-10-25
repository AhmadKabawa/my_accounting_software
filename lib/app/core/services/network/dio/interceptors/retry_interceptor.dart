// lib/core/network/interceptors/retry_interceptor.dart

import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  RetryInterceptor(this._dio);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retries = (err.requestOptions.extra['retryCount'] as int?) ?? 0;

    if (!_shouldRetry(err) || retries >= AppConfig.maxRetries) {
      return handler.next(err);
    }

    await Future.delayed(
      Duration(milliseconds: AppConfig.retryDelay * (retries + 1)),
    );
    err.requestOptions.extra['retryCount'] = retries + 1;

    try {
      final res = await _dio.request(
        err.requestOptions.path,
        data: err.requestOptions.data,
        queryParameters: err.requestOptions.queryParameters,
        options: Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: err.requestOptions.extra,
        ),
      );
      handler.resolve(res);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError ||
      (e.response?.statusCode != null && e.response!.statusCode! >= 500);
}
/**⚠️ ملاحظة مهمة

لو كان الطلب:

Upload file كبير

Payment API

عملية غير idempotent (مثل إنشاء طلب شراء)

يجب الحذر عند إعادة المحاولة حتى لا يتكرر التنفيذ. */