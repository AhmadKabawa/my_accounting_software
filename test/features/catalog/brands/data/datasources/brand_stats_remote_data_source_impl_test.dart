import 'package:accounting_software/app/core/error/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/error/exceptions/app_exception.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/core/network/api_end_points.dart';
import 'package:accounting_software/app/features/catalog/brands/data/datasources/brand_stats_remote_data_source_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StatsApiClient extends Fake implements IApiClient {
  _StatsApiClient({
    this.total = 12,
    this.active = 7,
    this.totalFailure,
    this.activeFailure,
    this.malformedTotal = false,
  });

  final int total;
  final int active;
  final AppException? totalFailure;
  final AppException? activeFailure;
  final bool malformedTotal;
  final List<Map<String, dynamic>> queries = [];

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
    final query = queryParameters ?? <String, dynamic>{};
    queries.add(Map<String, dynamic>.of(query));
    final isActive = query['is_active'] == 'eq.true';
    if (!isActive && malformedTotal) {
      fromJson({'id': 'not-an-integer'});
    }
    final failure = isActive ? activeFailure : totalFailure;
    if (failure != null) return ApiFailure<PaginatedResult<T>>(failure);
    final count = isActive ? active : total;
    return ApiSuccess(
      PaginatedResult<T>(
        items: <T>[],
        totalCount: count,
        currentPage: page,
        totalPages: count == 0 ? 0 : 1,
      ),
    );
  }
}

void main() {
  test('returns total, active and derived inactive counts', () async {
    final api = _StatsApiClient(total: 14, active: 9);
    final result = await BrandStatsRemoteDataSourceImpl(api).getBrandStats();

    expect(result, isA<ApiSuccess>());
    final stats = (result as ApiSuccess).data;
    expect(stats.total, 14);
    expect(stats.active, 9);
    expect(stats.inactive, 5);
    expect(api.queries, [
      {'select': 'id'},
      {'select': 'id', 'is_active': 'eq.true'},
    ]);
  });

  test('returns the total-count request failure', () async {
    final failure = ApiException.forbidden();
    final result = await BrandStatsRemoteDataSourceImpl(
      _StatsApiClient(totalFailure: failure),
    ).getBrandStats();

    expect(result, isA<ApiFailure>());
    expect((result as ApiFailure).exception, same(failure));
  });

  test('returns the active-count request failure', () async {
    final failure = ApiException.server();
    final result = await BrandStatsRemoteDataSourceImpl(
      _StatsApiClient(activeFailure: failure),
    ).getBrandStats();

    expect(result, isA<ApiFailure>());
    expect((result as ApiFailure).exception, same(failure));
  });

  test('supports zero total and zero active counts', () async {
    final result = await BrandStatsRemoteDataSourceImpl(
      _StatsApiClient(total: 0, active: 0),
    ).getBrandStats();

    final stats = (result as ApiSuccess).data;
    expect(stats.total, 0);
    expect(stats.active, 0);
    expect(stats.inactive, 0);
  });

  test('rejects a malformed count response row', () async {
    final source = BrandStatsRemoteDataSourceImpl(
      _StatsApiClient(malformedTotal: true),
    );

    await expectLater(source.getBrandStats(), throwsA(isA<TypeError>()));
  });
}
