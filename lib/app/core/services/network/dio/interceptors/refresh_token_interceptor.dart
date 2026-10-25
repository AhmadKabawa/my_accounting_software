import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:accounting_software/app/core/services/network/api_end_points.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final TokenManager _tokenStorage;

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  RefreshTokenInterceptor(this._dio, this._tokenStorage);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);
    if (err.requestOptions.path.contains('/auth/v1/refresh')) {
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }

    if (_isRefreshing) {
      _queue.add(_PendingRequest(err, handler));
      return;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        return handler.next(err);
      }

      final res = await _dio.post(
        AppEndpoints.auth.refresh.toStringPath(),
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'requiresAuth': false}),
      );

      final newAccess = res.data['access_token'] as String;
      final newRefresh = res.data['refresh_token'] as String?;

      await _tokenStorage.saveAccessToken(newAccess);
      if (newRefresh != null) {
        await _tokenStorage.saveAccessToken(newRefresh);
      }

      // Retry original
      handler.resolve(await _retry(err.requestOptions, newAccess));

      // Retry queued
      for (final p in _queue) {
        try {
          p.handler.resolve(await _retry(p.error.requestOptions, newAccess));
        } catch (_) {
          p.handler.next(p.error);
        }
      }
    } catch (_) {
      await _tokenStorage.clearTokens();
      for (final p in _queue) p.handler.next(p.error);
      handler.next(err);
    } finally {
      _queue.clear();
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions o, String token) =>
      _dio.request(
        o.path,
        data: o.data,
        queryParameters: o.queryParameters,
        options: Options(
          method: o.method,
          headers: {...o.headers, 'Authorization': 'Bearer $token'},
        ),
      );
}

class _PendingRequest {
  final DioException error;
  final ErrorInterceptorHandler handler;
  _PendingRequest(this.error, this.handler);
}
