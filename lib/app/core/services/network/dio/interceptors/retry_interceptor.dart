import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';

/// Retries transient failures, but only for requests that are safe to repeat.
///
/// Writes (POST/PATCH/PUT/DELETE) are never retried automatically because a
/// timeout does not prove the server did not execute them, and repeating a
/// financial write would duplicate it. A request that is known to be
/// idempotent can opt in with `Options(extra: {'idempotent': true})`.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.baseDelay = const Duration(milliseconds: AppConfig.retryDelay),
  });

  final Dio _dio;
  final Duration baseDelay;

  static const _safeMethods = {'GET', 'HEAD', 'OPTIONS'};

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final retries = (options.extra['retryCount'] as int?) ?? 0;

    if (!_isSafeToRetry(options) ||
        !_isTransient(err) ||
        retries >= AppConfig.maxRetries) {
      return handler.next(err);
    }

    await Future<void>.delayed(baseDelay * (retries + 1));

    try {
      final response = await _dio.fetch<dynamic>(
        options.copyWith(extra: {...options.extra, 'retryCount': retries + 1}),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isSafeToRetry(RequestOptions o) =>
      _safeMethods.contains(o.method.toUpperCase()) ||
      o.extra['idempotent'] == true;

  bool _isTransient(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.connectionError ||
      (e.response?.statusCode ?? 0) >= 500;
}
