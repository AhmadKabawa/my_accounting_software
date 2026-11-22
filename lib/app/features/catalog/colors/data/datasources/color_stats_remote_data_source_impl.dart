import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/colors/data/colors_endpoint.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/color_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';

class ColorStatsRemoteDataSourceImpl implements ColorStatsRemoteDataSource {
  const ColorStatsRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  @override
  Future<ApiResult<ColorStats>> getColorStats() async {
    final totalResult = await _apiClient.getPaginated<int>(
      ColorsEndpoint.collection,
      fromJson: (json) => json['id'] as int,
      queryParameters: const {'select': 'id'},
      parser: PaginatedParserPresets.supabase,
      page: 1,
      limit: 1,
    );
    if (totalResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<ColorStats>(exception);
    }
    final total =
        (totalResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;

    final activeResult = await _apiClient.getPaginated<int>(
      ColorsEndpoint.collection,
      fromJson: (json) => json['id'] as int,
      queryParameters: const {'select': 'id', 'is_active': 'eq.true'},
      parser: PaginatedParserPresets.supabase,
      page: 1,
      limit: 1,
    );
    if (activeResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<ColorStats>(exception);
    }
    final active =
        (activeResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;

    return ApiSuccess(
      ColorStats(total: total, active: active, inactive: total - active),
    );
  }
}
