import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/colors/data/colors_endpoint.dart';
import 'package:accounting_software/app/features/catalog/colors/data/datasources/color_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';

class ColorStatsRemoteDataSourceImpl implements ColorStatsRemoteDataSource {
  const ColorStatsRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  @override
  Future<ApiResult<ColorStats>> getColorStats() => _apiClient.post<ColorStats>(
    ColorsEndpoint.statsRpc,
    data: const <String, dynamic>{},
    fromJsonList: (rows) {
      if (rows.length != 1 || rows.single is! Map<String, dynamic>) {
        throw const FormatException('Expected one color_stats row');
      }
      final row = rows.single as Map<String, dynamic>;
      int readInt(String key) {
        final value = row[key];
        if (value is num) return value.toInt();
        return int.tryParse(value?.toString() ?? '') ?? 0;
      }

      return ColorStats(
        total: readInt('total'),
        active: readInt('active'),
        inactive: readInt('inactive'),
        used: readInt('used'),
        unused: readInt('unused'),
      );
    },
  );
}
