import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/sports/data/sports_endpoint.dart';
import 'package:accounting_software/app/features/catalog/sports/data/datasources/sport_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_stats.dart';

class SportStatsRemoteDataSourceImpl implements SportStatsRemoteDataSource {
  const SportStatsRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  @override
  Future<ApiResult<SportStats>> getSportStats() async {
    final totalResult = await _apiClient.getPaginated<int>(
      SportsEndpoint.collection,
      fromJson: (json) => json['id'] as int,
      queryParameters: const {'select': 'id'},
      parser: PaginatedParserPresets.supabase,
      page: 1,
      limit: 1,
    );
    if (totalResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<SportStats>(exception);
    }
    final total =
        (totalResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;

    final activeResult = await _apiClient.getPaginated<int>(
      SportsEndpoint.collection,
      fromJson: (json) => json['id'] as int,
      queryParameters: const {'select': 'id', 'is_active': 'eq.true'},
      parser: PaginatedParserPresets.supabase,
      page: 1,
      limit: 1,
    );
    if (activeResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<SportStats>(exception);
    }
    final active =
        (activeResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;

    return ApiSuccess(
      SportStats(total: total, active: active, inactive: total - active),
    );
  }
}
