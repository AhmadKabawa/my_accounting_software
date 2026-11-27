import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';

class FakeBrandsApiClient extends Fake implements IApiClient {
  Map<String, dynamic> lastQueryParameters = {};
  Map<String, dynamic>? lastBody;
  String? lastPath;
  int? lastPage;
  int? lastLimit;
  dynamic lastRawBody;
  Options? lastOptions;
  AppException? postFailure;
  AppException? patchFailure;
  AppException? deleteFailure;
  AppException? activeStatsFailure;
  int statsTotalCount = 12;
  int statsActiveCount = 7;
  final List<Map<String, dynamic>> paginatedQueries = [];

  Map<String, dynamic> get _brandJson => {
    'id': 12,
    'name': 'Northwind',
    'slug': 'northwind',
    'logo': null,
    'description': null,
    'is_active': true,
    'products': [
      {'count': 2},
    ],
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
    paginatedQueries.add(Map<String, dynamic>.of(lastQueryParameters));
    lastPage = page;
    lastLimit = limit;
    final isCountRequest = lastQueryParameters['select'] == 'id';
    final isActiveRequest = lastQueryParameters['is_active'] == 'eq.true';
    if (isCountRequest && isActiveRequest && activeStatsFailure != null) {
      return ApiFailure<PaginatedResult<T>>(activeStatsFailure!);
    }
    final json = isCountRequest ? {'id': 12} : _brandJson;
    final totalCount = !isCountRequest
        ? 1
        : isActiveRequest
        ? statsActiveCount
        : statsTotalCount;
    return ApiSuccess(
      PaginatedResult<T>(
        items: [fromJson(json)],
        totalCount: totalCount,
        currentPage: page,
        totalPages: totalCount == 0 ? 0 : (totalCount / limit).ceil(),
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
    lastRawBody = data;
    lastOptions = options;
    lastBody = data is Map<String, dynamic> ? data : null;
    if (postFailure case final failure?) return ApiFailure<T>(failure);
    if (path.toStringPath() == '/rest/v1/rpc/brand_stats') {
      return ApiSuccess<T>(
        fromJsonList!([
          {
            'total': statsTotalCount,
            'active': statsActiveCount,
            'inactive': statsTotalCount - statsActiveCount,
            'with_products': 6,
            'without_products': statsTotalCount - 6,
            'most_used_brand_id': 12,
            'most_used_count': 3,
          },
        ]),
      );
    }
    if (fromJsonList != null) {
      return ApiSuccess<T>(fromJsonList([_brandJson]));
    }
    if (fromJson != null) return ApiSuccess<T>(fromJson(_brandJson));
    throw StateError('A response parser is required in this fake');
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
    lastBody = data as Map<String, dynamic>?;
    if (patchFailure case final failure?) return ApiFailure<T>(failure);
    if (T == Unit) return ApiSuccess<T>(unit as T);
    if (fromJsonList != null) {
      return ApiSuccess<T>(fromJsonList([_brandJson]));
    }
    if (fromJson != null) return ApiSuccess<T>(fromJson(_brandJson));
    throw StateError('A response parser is required in this fake');
  }

  @override
  Future<ApiResult<Unit>> delete(
    AppEndpoint path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    lastPath = path.toStringPath();
    lastQueryParameters = queryParameters ?? {};
    if (deleteFailure case final failure?) return ApiFailure<Unit>(failure);
    return const ApiSuccess<Unit>(unit);
  }
}
