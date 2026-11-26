import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_parser.dart';
import 'package:accounting_software/app/core/foundation/types/paginated_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/units/data/datasources/unit_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/units/data/units_endpoint.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';

class UnitStatsRemoteDataSourceImpl implements UnitStatsRemoteDataSource {
  const UnitStatsRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  @override
  Future<ApiResult<UnitStats>> getUnitStats() async {
    final totalResult = await _count(const {'select': 'id'});
    if (totalResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<UnitStats>(exception);
    }
    final total =
        (totalResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;

    final activeResult = await _count(const {
      'select': 'id',
      'is_active': 'eq.true',
    });
    if (activeResult case ApiFailure<PaginatedResult<int>>(:final exception)) {
      return ApiFailure<UnitStats>(exception);
    }
    final active =
        (activeResult as ApiSuccess<PaginatedResult<int>>).data.totalCount;

    return ApiSuccess(
      UnitStats(total: total, active: active, inactive: total - active),
    );
  }

  Future<ApiResult<PaginatedResult<int>>> _count(Map<String, dynamic> query) =>
      _apiClient.getPaginated<int>(
        UnitsEndpoint.collection,
        fromJson: (json) => json['id'] as int,
        queryParameters: query,
        parser: PaginatedParserPresets.supabase,
        page: 1,
        limit: 1,
      );
}
