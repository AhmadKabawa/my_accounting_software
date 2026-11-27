import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_stats.dart';

abstract interface class AttributeStatsRemoteDataSource {
  Future<ApiResult<AttributeStats>> getAttributeStats();
}
