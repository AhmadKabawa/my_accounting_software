import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_stats.dart';

abstract interface class SportStatsRemoteDataSource {
  Future<ApiResult<SportStats>> getSportStats();
}
