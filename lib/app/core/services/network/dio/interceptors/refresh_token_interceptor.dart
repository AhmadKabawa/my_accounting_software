import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/exceptions.dart';
import 'package:accounting_software/app/core/services/local_storage/secure_storage/token_manager.dart';
import 'package:accounting_software/app/core/services/network/api_end_points.dart';

/// Renews the Supabase session when a request fails with 401 and replays it.
///
/// - The refresh call uses its own bare [Dio] (same options, no interceptors),
///   so it can never be intercepted by this class or wait on itself.
/// - Concurrent 401s share one refresh (single-flight): Supabase rotates the
///   refresh token, so a second parallel refresh would invalidate the first.
/// - A replayed request is marked `authRetried` and is never refreshed twice.
/// - The session is cleared only when the server rejects the refresh token;
///   a network failure keeps it so the user is not logged out while offline.
class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor(this._dio, this._tokens)
    : _refreshDio = Dio(_dio.options.copyWith())
        ..httpClientAdapter = _dio.httpClientAdapter;

  final Dio _dio;
  final Dio _refreshDio;
  final TokenManager _tokens;

  Future<String?>? _refreshing;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        options.extra['requiresAuth'] == false ||
        options.extra['authRetried'] == true) {
      return handler.next(err);
    }

    final accessToken = await (_refreshing ??= _refresh().whenComplete(
      () => _refreshing = null,
    ));
    if (accessToken == null) return handler.next(err);

    try {
      handler.resolve(
        await _dio.fetch<dynamic>(
          options.copyWith(
            headers: {
              ...options.headers,
              'Authorization': 'Bearer $accessToken',
            },
            extra: {...options.extra, 'authRetried': true},
          ),
        ),
      );
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _refresh() async {
    final refreshToken = await _tokens.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokens.clearTokens();
      return null;
    }

    try {
      final res = await _refreshDio.post<Map<String, dynamic>>(
        AppEndpoints.auth.token.toStringPath(),
        queryParameters: {'grant_type': 'refresh_token'},
        data: {'refresh_token': refreshToken},
      );
      final accessToken = res.data?['access_token'] as String?;
      final newRefreshToken = res.data?['refresh_token'] as String?;
      if (accessToken == null) {
        await _tokens.clearTokens();
        return null;
      }

      await _tokens.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
      return accessToken;
    } on CacheException {
      // The storage rolled the half-written session back and signalled it.
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 400 || status == 401 || status == 403) {
        await _tokens.clearTokens();
      }
      return null;
    }
  }
}
