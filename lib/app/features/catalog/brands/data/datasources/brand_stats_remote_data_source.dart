import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';

abstract interface class BrandStatsRemoteDataSource {
  Future<ApiResult<BrandStats>> getBrandStats();
}
