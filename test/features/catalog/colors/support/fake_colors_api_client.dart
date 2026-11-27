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
  final List<Map<String, dynamic>> paginatedQueries = [];
  int totalCount = 1;
  int activeCount = 1;
  Map<String, dynamic>? lastBody;
  String? lastPath;
  int? lastPage;
  int? lastLimit;
  Options? lastOptions;
  AppException? postFailure;
  AppException? patchFailure;
  AppException? deleteFailure;
  AppException? usageFailure;
  Map<String, dynamic>? usageQuery;

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
    paginatedQueries.add(Map<String, dynamic>.from(lastQueryParameters));
    lastPage = page;
    lastLimit = limit;
    return ApiSuccess(
      PaginatedResult<T>(
        items: [fromJson(colorJson)],
        totalCount: lastQueryParameters['is_active'] == 'eq.true'
            ? activeCount
            : totalCount,
        currentPage: page,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<ApiResult<T>> get<T>(
    AppEndpoint path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    JsonFactory<T>? fromJson,
    JsonListFactory<T>? fromJsonList,
    CancelToken? cancelToken,
    bool requiresAuth = true,
  }) async {
    usageQuery = queryParameters;
    final failure = usageFailure;
    if (failure != null) return ApiFailure<T>(failure);
    return ApiSuccess<T>(
      fromJsonList!([
        {'color_id': 7, 'product_count': 4, 'component_count': 9},
      ]),
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
    final response = path.toStringPath() == '/rest/v1/rpc/color_stats'
        ? <Map<String, dynamic>>[
            {
              'total': totalCount,
              'active': activeCount,
              'inactive': totalCount - activeCount,
              'used': 6,
              'unused': 2,
            },
          ]
        : <Map<String, dynamic>>[colorJson];
    return ApiSuccess<T>(fromJsonList!(response));
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
