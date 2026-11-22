import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';

abstract interface class ColorStatsRemoteDataSource {
  Future<ApiResult<ColorStats>> getColorStats();
}
