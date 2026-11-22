import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/brands/data/brands_endpoint.dart';
import 'package:accounting_software/app/features/catalog/brands/data/datasources/brand_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';

class BrandStatsRemoteDataSourceImpl implements BrandStatsRemoteDataSource {
  const BrandStatsRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  @override
  Future<ApiResult<BrandStats>> getBrandStats() async {
    // Temporary two-request count; replace with one RPC when available.
    final results =
        await Future.wait<ApiResult<PaginatedResult<_BrandCountRow>>>([
          _apiClient.getPaginated<_BrandCountRow>(
            BrandsEndpoint.collection,
            fromJson: _BrandCountRow.fromJson,
            page: 1,
            limit: 1,
            parser: PaginatedParserPresets.supabase,
            queryParameters: {'select': 'id'},
          ),
          _apiClient.getPaginated<_BrandCountRow>(
            BrandsEndpoint.collection,
            fromJson: _BrandCountRow.fromJson,
            page: 1,
            limit: 1,
            parser: PaginatedParserPresets.supabase,
            queryParameters: {'select': 'id', 'is_active': 'eq.true'},
          ),
        ]);

    final totalResult = results[0];
    final activeResult = results[1];
    if (totalResult case ApiFailure<PaginatedResult<_BrandCountRow>>(
      :final exception,
    )) {
      return ApiFailure<BrandStats>(exception);
    }
    if (activeResult case ApiFailure<PaginatedResult<_BrandCountRow>>(
      :final exception,
    )) {
      return ApiFailure<BrandStats>(exception);
    }

    final total = (totalResult as ApiSuccess<PaginatedResult<_BrandCountRow>>)
        .data
        .totalCount;
    final active = (activeResult as ApiSuccess<PaginatedResult<_BrandCountRow>>)
        .data
        .totalCount;
    return ApiSuccess(
      BrandStats(total: total, active: active, inactive: total - active),
    );
  }
}

class _BrandCountRow {
  const _BrandCountRow(this.id);

  final int id;

  factory _BrandCountRow.fromJson(Map<String, dynamic> json) =>
      _BrandCountRow(json['id'] as int);
}
