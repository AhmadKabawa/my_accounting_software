import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/features/catalog/brands/data/brands_endpoint.dart';
import 'package:accounting_software/app/features/catalog/brands/data/datasources/brand_stats_remote_data_source_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StatsApiClient extends Fake implements IApiClient {
  _StatsApiClient({this.failure, this.row});
  final AppException? failure;
  final Map<String, dynamic>? row;
  AppEndpoint? requestedPath;
  dynamic requestedBody;

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
    requestedPath = path;
    requestedBody = data;
    if (failure != null) return ApiFailure<T>(failure!);
    return ApiSuccess<T>(fromJsonList!([row ?? {
      'total': 14, 'active': 9, 'inactive': 5, 'with_products': 6,
      'without_products': 8, 'most_used_brand_id': 4, 'most_used_count': 11,
    }]));
  }
}

void main() {
  test('calls the brand_stats RPC once and maps all returned aggregates', () async {
    final api = _StatsApiClient();
    final result = await BrandStatsRemoteDataSourceImpl(api).getBrandStats();
    expect(result, isA<ApiSuccess>());
    final stats = (result as ApiSuccess).data;
    expect(stats.total, 14);
    expect(stats.active, 9);
    expect(stats.inactive, 5);
    expect(stats.withProducts, 6);
    expect(stats.withoutProducts, 8);
    expect(stats.mostUsedBrandId, 4);
    expect(stats.mostUsedCount, 11);
    expect(api.requestedPath, BrandsEndpoint.statsRpc);
    expect(api.requestedBody, isEmpty);
  });

  test('preserves a nullable most-used brand and zero aggregates', () async {
    final api = _StatsApiClient(row: const {
      'total': 0, 'active': 0, 'inactive': 0, 'with_products': 0,
      'without_products': 0, 'most_used_brand_id': null, 'most_used_count': 0,
    });
    final result = await BrandStatsRemoteDataSourceImpl(api).getBrandStats();
    final stats = (result as ApiSuccess).data;
    expect(stats.total, 0);
    expect(stats.mostUsedBrandId, isNull);
    expect(stats.mostUsedCount, 0);
  });

  test('returns an RPC failure unchanged', () async {
    final failure = ApiException.forbidden();
    final result = await BrandStatsRemoteDataSourceImpl(
      _StatsApiClient(failure: failure),
    ).getBrandStats();
    expect(result, isA<ApiFailure>());
    expect((result as ApiFailure).exception, same(failure));
  });
}
