import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/datasources/option_set_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/option_sets/data/option_sets_endpoint.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';

class OptionSetStatsRemoteDataSourceImpl
    implements OptionSetStatsRemoteDataSource {
  const OptionSetStatsRemoteDataSourceImpl(this._apiClient);
  final IApiClient _apiClient;

  @override
  Future<ApiResult<OptionSetStats>> getOptionSetStats() async {
    final totalResult = await _count(const {'select': 'id'});
    if (totalResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<OptionSetStats>(exception);
    }
    final total =
        (totalResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;
    final activeResult = await _count(const {
      'select': 'id',
      'is_active': 'eq.true',
    });
    if (activeResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<OptionSetStats>(exception);
    }
    final active =
        (activeResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;
    return ApiSuccess(
      OptionSetStats(total: total, active: active, inactive: total - active),
    );
  }

  Future<ApiResult<PaginatedResult<int>>> _count(Map<String, dynamic> query) =>
      _apiClient.getPaginated<int>(
        OptionSetsEndpoint.collection,
        fromJson: (json) => json['id'] as int,
        queryParameters: query,
        parser: PaginatedParserPresets.supabase,
        page: 1,
        limit: 1,
      );
}
