// lib/core/network/api_client.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/services/network/api_client_interface.dart';
import 'package:accounting_software/app/core/services/network/api_end_points.dart';
import 'package:accounting_software/app/core/utils/logger.dart';
import 'dio_service.dart';

typedef JsonFactory<T> = T Function(Map<String, dynamic>);

class ApiClient implements IApiClient {
  const ApiClient({required DioService dioService}) : _dioService = dioService;
  final DioService _dioService;

  Dio get _dio => _dioService.dio;

  // ── GET ───────────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<T>> get<T>(
    AppEndpoint path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) => _execute(
    () => _dio.get(
      path.toStringPath(),
      queryParameters: queryParameters,
      options: _buildOptions(options, requiresAuth),
      cancelToken: cancelToken,
    ),
    fromJson,
    fromJsonList,
  );

  // ── POST ──────────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<T>> post<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) => _execute(
    () => _dio.post(
      path.toStringPath(),
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(options, requiresAuth),
      cancelToken: cancelToken,
    ),
    fromJson,
    fromJsonList,
  );

  // ── PUT ───────────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<T>> put<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) => _execute(
    () => _dio.put(
      path.toStringPath(),
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(options, requiresAuth),
      cancelToken: cancelToken,
    ),
    fromJson,
    fromJsonList,
  );

  // ── PATCH ─────────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<T>> patch<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) => _execute(
    () => _dio.patch(
      path.toStringPath(),
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(options, requiresAuth),
      cancelToken: cancelToken,
    ),
    fromJson,
    fromJsonList,
  );

  // ── DELETE ────────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<Unit>> delete(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) => _execute<Unit>(
    () => _dio.delete(
      path.toStringPath(),
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(options, requiresAuth),
      cancelToken: cancelToken,
    ),
    (_) => unit,
  );

  // ── UPLOAD ────────────────────────────────────────────────────────────────
  @override
  Future<ApiResult<T>> upload<T>(
    AppEndpoint path, {
    required FormData formData,
    JsonFactory<T>? fromJson,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) => _execute(
    () => _dio.post(
      path.toStringPath(),
      data: formData,
      onSendProgress: onSendProgress,
      options: _buildOptions(null, requiresAuth),
      cancelToken: cancelToken,
    ),
    fromJson,
    null,
  );

  // ── PAGINATED GET ─────────────────────────────────────────────────────────
  @override
  Future<ApiResult<PaginatedResult<T>>> getPaginated<T>(
    AppEndpoint path, {
    required JsonFactory<T> fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
    PaginatedParser parser = PaginatedParserPresets.supabase,
    int page = 1,
    int limit = 20,
  }) => _guard(() async {
    final res = await _dio.get(
      path.toStringPath(),
      queryParameters: queryParameters,
      options: _buildOptions(options, requiresAuth, page: page, limit: limit),
      cancelToken: cancelToken,
    );

    if (!_isSuccess(res.statusCode)) {
      return ApiFailure<PaginatedResult<T>>(
        ApiException.server(
          statusCode: res.statusCode,
          serverMessage: _extractMessage(res.data),
        ),
      );
    }

    final total = _parseTotalFromContentRange(
      res.headers.value('content-range'),
    );

    return ApiSuccess(
      parser.parse<T>(
        res.data,
        (json) => fromJson(json as Map<String, dynamic>),
        page: page,
        limit: limit,
        totalFromHeader: total,
      ),
    );
  });

  // ── PAGINATED POST ────────────────────────────────────────────────────────
  @override
  Future<ApiResult<PaginatedResult<T>>> postPaginated<T>(
    AppEndpoint path, {
    required JsonFactory<T> fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
    PaginatedParser parser = PaginatedParserPresets.standard,
  }) => _execute<PaginatedResult<T>>(
    () => _dio.post(
      path.toStringPath(),
      data: data,
      queryParameters: queryParameters,
      options: _buildOptions(options, requiresAuth),
      cancelToken: cancelToken,
    ),
    (json) =>
        parser.parse<T>(json, (item) => fromJson(item as Map<String, dynamic>)),
  );

  // ── Private ───────────────────────────────────────────────────────────────

  Future<ApiResult<T>> _execute<T>(
    Future<Response> Function() request,
    JsonFactory<T>? fromJson, [
    JsonListFactory<T>? fromJsonList,
  ]) => _guard(
    () async => _handleResponse(await request(), fromJson, fromJsonList),
  );

  /// Every request goes through here so nothing escapes as an exception:
  /// Dio errors are mapped, and any other failure becomes an [ApiException].
  Future<ApiResult<T>> _guard<T>(Future<ApiResult<T>> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      // Cancel ليس خطأ — هو قرار واعٍ من الـ ViewModel
      if (CancelToken.isCancel(e)) return ApiFailure(ApiException.cancelled());
      return ApiFailure(_mapException(e));
    } catch (e, st) {
      // Programming errors (null checks, bad casts) are turned into a failure
      // so the app does not crash, but they must stay visible while
      // developing: log the full exception and stack trace (debug only).
      Logger.error(
        'ApiClient: unexpected error',
        error: e,
        stackTrace: st,
        name: 'ApiClient',
      );
      return ApiFailure(ApiException.unknown(serverMessage: e.toString()));
    }
  }

  ApiResult<T> _handleResponse<T>(
    Response r,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
  ) {
    if (!_isSuccess(r.statusCode)) {
      return ApiFailure(
        ApiException.server(
          statusCode: r.statusCode,
          serverMessage: _extractMessage(r.data),
        ),
      );
    }

    final data = r.data;

    // 204 No Content أو response فارغ
    if (r.statusCode == 204 || data == null) {
      if (T == Unit) return ApiSuccess(unit as T);
      return ApiFailure(
        ApiException.unknown(serverMessage: 'Unexpected empty response'),
      );
    }

    // بدون parser — نُعيد الـ data إذا كان من النوع المطلوب فعلاً
    if (fromJson == null && fromJsonList == null) {
      return data is T
          ? ApiSuccess(data)
          : ApiFailure(
              ApiException.unknown(
                serverMessage: 'Expected $T, got ${data.runtimeType}',
              ),
            );
    }

    try {
      return switch (data) {
        Map<String, dynamic>() when fromJson != null => ApiSuccess(
          fromJson(data),
        ),
        List<dynamic>() when fromJsonList != null => ApiSuccess(
          fromJsonList(data),
        ),
        _ => ApiFailure(
          ApiException.unknown(
            serverMessage: 'Unexpected JSON shape: ${data.runtimeType}',
          ),
        ),
      };
    } catch (e, st) {
      Logger.error(
        'ApiClient: parse error',
        error: e,
        stackTrace: st,
        name: 'ApiClient',
      );
      return ApiFailure(ApiException.unknown(serverMessage: 'Parse error: $e'));
    }
  }

  /// خيارات الـ request — pagination منفصلة عن باقي الـ requests
  Options _buildOptions(
    Options? base,
    bool requiresAuth, {
    int? page,
    int? limit,
  }) {
    final isPaginated = page != null && limit != null;
    final offset = isPaginated ? (page - 1) * limit : null;

    final paginationHeaders = isPaginated
        ? {
            'Range': '$offset-${offset! + limit - 1}',
            'Range-Unit': 'items',
            'Prefer': 'count=exact',
          }
        : <String, dynamic>{};

    return (base ?? Options()).copyWith(
      extra: {...?base?.extra, 'requiresAuth': requiresAuth},
      headers: {...?base?.headers, ...paginationHeaders},
    );
  }

  bool _isSuccess(int? statusCode) =>
      statusCode != null && statusCode >= 200 && statusCode < 300;

  ApiException _mapException(DioException e) {
    return switch (e.type) {
      // The link can be up without reaching the internet (captive portal,
      // router with no uplink), so connectivity_plus alone says "online".
      // Failing to even establish the connection is reported as "no
      // internet"; only a slow *established* request is a plain timeout.
      DioExceptionType.connectionTimeout ||
      DioExceptionType.connectionError => ApiException.noInternet(),
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => ApiException.timeout(),
      DioExceptionType.cancel => ApiException.cancelled(),
      DioExceptionType.badResponse => _mapStatusCode(e),
      _ => ApiException.unknown(serverMessage: e.message),
    };
  }

  ApiException _mapStatusCode(DioException e) {
    return switch (e.response?.statusCode) {
      400 => ApiException.badRequest(
        serverMessage: _extractMessage(e.response?.data),
      ),
      401 => ApiException.unauthorized(
        serverMessage: _extractMessage(e.response?.data),
      ),
      403 => ApiException.forbidden(),
      404 => ApiException.notFound(),
      409 => ApiException.conflict(
        serverMessage: _extractMessage(e.response?.data),
      ),
      422 => ApiException.validationError(
        serverMessage: _extractMessage(e.response?.data),
      ),
      503 => ApiException.serviceUnavailable(),
      _ => ApiException.server(
        statusCode: e.response?.statusCode,
        serverMessage: _extractMessage(e.response?.data),
      ),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      if (data['errors'] is List) {
        final list = data['errors'] as List;
        if (list.isNotEmpty) return list.first?.toString();
      }
      if (data['errors'] is Map) {
        final map = data['errors'] as Map;
        if (map.isNotEmpty) {
          final first = map.values.first;
          if (first is List && first.isNotEmpty) return first.first?.toString();
          if (first is String) return first;
        }
      }
      return data['message']?.toString() ??
          data['error_description']?.toString() ??
          data['error']?.toString() ??
          data['msg']?.toString();
    }
    return null;
  }

  int? _parseTotalFromContentRange(String? contentRange) {
    if (contentRange == null) return null;
    final parts = contentRange.split('/');
    if (parts.length == 2) return int.tryParse(parts[1].trim());
    return null;
  }
}
