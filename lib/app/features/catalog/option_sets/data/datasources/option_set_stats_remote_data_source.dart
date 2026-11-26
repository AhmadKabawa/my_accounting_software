import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';

abstract interface class OptionSetStatsRemoteDataSource {
  Future<ApiResult<OptionSetStats>> getOptionSetStats();
}
