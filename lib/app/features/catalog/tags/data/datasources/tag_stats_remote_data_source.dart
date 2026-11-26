import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_stats.dart';

abstract interface class TagStatsRemoteDataSource {
  Future<ApiResult<TagStats>> getTagStats();
}
