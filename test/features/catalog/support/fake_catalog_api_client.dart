import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';

class CatalogApiRequest {
  const CatalogApiRequest({
    required this.method,
    required this.path,
    this.query = const {},
    this.body,
    this.options,
    this.page,
    this.limit,
  });

  final String method;
  final String path;
  final Map<String, dynamic> query;
  final Map<String, dynamic>? body;
  final Options? options;
  final int? page;
  final int? limit;
}

class FakeCatalogApiClient extends Fake implements IApiClient {
  final requests = <CatalogApiRequest>[];
  List<Map<String, dynamic>> rows = [];
  Map<String, dynamic> writeRow = {};
  AppException? nextPaginatedFailure;
  AppException? nextGetFailure;
  AppException? nextPostFailure;
  AppException? nextPatchFailure;
  AppException? nextDeleteFailure;
  AppException? activeStatsFailure;
  int totalCount = 0;
  int activeCount = 0;
  int inactiveCount = 0;
  int filterableCount = 0;

  CatalogApiRequest get lastRequest => requests.last;

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
    final query = Map<String, dynamic>.of(queryParameters ?? {});
    requests.add(
      CatalogApiRequest(
        method: 'GET_PAGE',
        path: path.toStringPath(),
        query: query,
        options: options,
        page: page,
        limit: limit,
      ),
    );
    if (nextPaginatedFailure case final failure?) {
      nextPaginatedFailure = null;
      return ApiFailure<PaginatedResult<T>>(failure);
    }
    if (query['select'] == 'id' && query['is_active'] == 'eq.true') {
      final failure = activeStatsFailure;
      if (failure != null) {
        return ApiFailure<PaginatedResult<T>>(failure);
      }
    }
    final isCount = query['select'] == 'id';
    final source = isCount
        ? <Map<String, dynamic>>[
            {'id': 1},
          ]
        : rows;
    final items = source.map(fromJson).toList();
    final count = _countFor(query, isCount);
    return ApiSuccess(
      PaginatedResult<T>(
        items: items,
        totalCount: count,
        currentPage: page,
        totalPages: count == 0 ? 0 : (count / limit).ceil(),
      ),
    );
  }

  Map<String, dynamic> _project(
    Map<String, dynamic> row,
    String select,
  ) {
    final projected = Map<String, dynamic>.of(row);
    if (!select.contains('product_variants(count)')) {
      projected.remove('product_variants');
    }
    if (!select.contains('options(count)')) projected.remove('options');
    if (!select.contains('attributes(count)')) projected.remove('attributes');
    if (!select.contains('product_type_option_sets(count)')) {
      projected.remove('product_type_option_sets');
    }
    if (!select.contains('product_type_attributes(count)')) {
      projected.remove('product_type_attributes');
    }
    if (!select.contains('product_attribute_values(count)')) {
      projected.remove('product_attribute_values');
    }
    return projected;
  }

  int _countFor(Map<String, dynamic> query, bool isCount) {
    if (!isCount) return totalCount;
    if (query['is_active'] == 'eq.true') return activeCount;
    if (query['is_active'] == 'eq.false') return inactiveCount;
    if (query['is_filterable'] == 'eq.true') return filterableCount;
    return totalCount;
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
    requests.add(
      CatalogApiRequest(
        method: 'GET',
        path: path.toStringPath(),
        query: Map<String, dynamic>.of(queryParameters ?? {}),
        options: options,
      ),
    );
    if (nextGetFailure case final failure?) {
      nextGetFailure = null;
      return ApiFailure<T>(failure);
    }
    if (fromJsonList != null) {
      return ApiSuccess<T>(fromJsonList(rows));
    }
    if (fromJson != null && rows.isNotEmpty) {
      return ApiSuccess<T>(fromJson(rows.first));
    }
    throw StateError('A response parser and response row are required.');
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
    requests.add(
      CatalogApiRequest(
        method: 'POST',
        path: path.toStringPath(),
        query: Map<String, dynamic>.of(queryParameters ?? {}),
        body: data is Map ? Map<String, dynamic>.from(data) : null,
        options: options,
      ),
    );
    if (nextPostFailure case final failure?) {
      nextPostFailure = null;
      return ApiFailure<T>(failure);
    }
    if (fromJsonList != null) {
      return ApiSuccess<T>(fromJsonList([writeRow]));
    }
    if (fromJson != null) return ApiSuccess<T>(fromJson(writeRow));
    if (T == Unit) return ApiSuccess<T>(unit as T);
    throw StateError('A response parser is required.');
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
    requests.add(
      CatalogApiRequest(
        method: 'PATCH',
        path: path.toStringPath(),
        query: Map<String, dynamic>.of(queryParameters ?? {}),
        body: data is Map ? Map<String, dynamic>.from(data) : null,
        options: options,
      ),
    );
    if (nextPatchFailure case final failure?) {
      nextPatchFailure = null;
      return ApiFailure<T>(failure);
    }
    if (T == Unit) return ApiSuccess<T>(unit as T);
    if (fromJsonList != null) {
      return ApiSuccess<T>(fromJsonList([writeRow]));
    }
    if (fromJson != null) return ApiSuccess<T>(fromJson(writeRow));
    throw StateError('A response parser is required.');
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
    requests.add(
      CatalogApiRequest(
        method: 'DELETE',
        path: path.toStringPath(),
        query: Map<String, dynamic>.of(queryParameters ?? {}),
        body: data is Map ? Map<String, dynamic>.from(data) : null,
        options: options,
      ),
    );
    if (nextDeleteFailure case final failure?) {
      nextDeleteFailure = null;
      return ApiFailure<Unit>(failure);
    }
    return const ApiSuccess<Unit>(unit);
  }
}
