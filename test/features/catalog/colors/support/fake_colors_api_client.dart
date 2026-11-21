import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:mocktail/mocktail.dart';

class FakeColorsApiClient extends Fake implements IApiClient {
  Map<String, dynamic> lastQueryParameters = {};
  Map<String, dynamic>? lastBody;
  String? lastPath;
  int? lastPage;
  int? lastLimit;
  Options? lastOptions;
  AppException? postFailure;
  AppException? patchFailure;

  static const Map<String, dynamic> colorJson = {
    'id': 7,
    'name': 'Navy',
    'code': 'NAVY',
    'hex_code': '#1E3A8A',
    'is_active': true,
    'sort_order': 2,
  };

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
  }) async {
    lastPath = path.toStringPath();
    lastQueryParameters = queryParameters ?? {};
    lastPage = page;
    lastLimit = limit;
    return ApiSuccess(
      PaginatedResult<T>(
        items: [fromJson(colorJson)],
        totalCount: 1,
        currentPage: page,
        totalPages: 1,
      ),
    );
  }

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
  }) async {
    lastPath = path.toStringPath();
    lastOptions = options;
    lastBody = data as Map<String, dynamic>?;
    if (postFailure case final failure?) return ApiFailure<T>(failure);
    return ApiSuccess<T>(fromJsonList!([colorJson]));
  }

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
  }) async {
    lastPath = path.toStringPath();
    lastQueryParameters = queryParameters ?? {};
    lastOptions = options;
    lastBody = data as Map<String, dynamic>?;
    if (patchFailure case final failure?) return ApiFailure<T>(failure);
    if (T == Unit) return ApiSuccess<T>(unit as T);
    return ApiSuccess<T>(fromJsonList!([colorJson]));
  }
}
