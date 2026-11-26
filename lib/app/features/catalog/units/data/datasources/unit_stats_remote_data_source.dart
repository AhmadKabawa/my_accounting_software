import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';

abstract interface class UnitStatsRemoteDataSource {
  Future<ApiResult<UnitStats>> getUnitStats();
}
