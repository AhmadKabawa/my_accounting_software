// lib/core/network/api_client_interface.dart

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/services/network/api_end_points.dart';

typedef JsonFactory<T> = T Function(Map<String, dynamic>);

abstract interface class IApiClient {
  Future<ApiResult<T>> get<T>(
    AppEndpoint path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
  });

  Future<ApiResult<T>> post<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
  });

  Future<ApiResult<T>> put<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
  });

  Future<ApiResult<T>> patch<T>(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
  });

  Future<ApiResult<Unit>> delete(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
  });

  Future<ApiResult<T>> upload<T>(
    AppEndpoint path, {
    required FormData formData,
    JsonFactory<T>? fromJson,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
  });

  Future<ApiResult<PaginatedResult<T>>> getPaginated<T>(
    AppEndpoint path, {
    required JsonFactory<T> fromJson,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
    PaginatedParser parser,
    int page,
    int limit,
  });

  Future<ApiResult<PaginatedResult<T>>> postPaginated<T>(
    AppEndpoint path, {
    required JsonFactory<T> fromJson,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken, // ← جديد
    bool requiresAuth,
    PaginatedParser parser,
  });
}
