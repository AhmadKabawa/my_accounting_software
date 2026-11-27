import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/attributes_endpoint.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/datasources/attribute_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_stats.dart';

class AttributeStatsRemoteDataSourceImpl
    implements AttributeStatsRemoteDataSource {
  static const _countPage = 1;
  static const _countLimit = 1;

  const AttributeStatsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;
  @override
  Future<ApiResult<AttributeStats>> getAttributeStats() async {
    final all = await _count(const {});
    if (all case ApiFailure<PaginatedResult<int>>(:final exception))
      return ApiFailure<AttributeStats>(exception);
    final active = await _count(const {'is_active': 'eq.true'});
    if (active case ApiFailure<PaginatedResult<int>>(:final exception))
      return ApiFailure<AttributeStats>(exception);
    final inactive = await _count(const {'is_active': 'eq.false'});
    if (inactive case ApiFailure<PaginatedResult<int>>(:final exception))
      return ApiFailure<AttributeStats>(exception);
    final filterable = await _count(const {'is_filterable': 'eq.true'});
    if (filterable case ApiFailure<PaginatedResult<int>>(:final exception))
      return ApiFailure<AttributeStats>(exception);
    return ApiSuccess(
      AttributeStats(
        all: (all as ApiSuccess<PaginatedResult<int>>).data.totalCount,
        active: (active as ApiSuccess<PaginatedResult<int>>).data.totalCount,
        inactive:
            (inactive as ApiSuccess<PaginatedResult<int>>).data.totalCount,
        filterable:
            (filterable as ApiSuccess<PaginatedResult<int>>).data.totalCount,
      ),
    );
  }

  Future<ApiResult<PaginatedResult<int>>> _count(
    Map<String, dynamic> filters,
  ) => _apiClient.getPaginated<int>(
    AttributesEndpoint.collection,
    fromJson: (json) => json['id'] as int,
    queryParameters: {'select': 'id', ...filters},
    parser: PaginatedParserPresets.supabase,
    page: _countPage,
    limit: _countLimit,
  );
}
