import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/core/network/api_client_interface.dart';
import 'package:accounting_software/app/features/catalog/brands/data/brands_endpoint.dart';
import 'package:accounting_software/app/features/catalog/brands/data/datasources/brand_stats_remote_data_source.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';

class BrandStatsRemoteDataSourceImpl implements BrandStatsRemoteDataSource {
  const BrandStatsRemoteDataSourceImpl(this._apiClient);

  final IApiClient _apiClient;

  @override
  Future<ApiResult<BrandStats>> getBrandStats() =>
      _apiClient.post<BrandStats>(
        BrandsEndpoint.statsRpc,
        data: const <String, dynamic>{},
        fromJsonList: (rows) {
          if (rows.length != 1 || rows.single is! Map<String, dynamic>) {
            throw const FormatException('Expected one brand_stats row');
          }
          final row = rows.single as Map<String, dynamic>;
          int readInt(String key) {
            final value = row[key];
            if (value is num) return value.toInt();
            return int.tryParse(value?.toString() ?? '') ?? 0;
          }

          final brandId = row['most_used_brand_id'];
          return BrandStats(
            total: readInt('total'),
            active: readInt('active'),
            inactive: readInt('inactive'),
            withProducts: readInt('with_products'),
            withoutProducts: readInt('without_products'),
            mostUsedBrandId: brandId == null
                ? null
                : brandId is num
                    ? brandId.toInt()
                    : int.tryParse(brandId.toString()),
            mostUsedCount: readInt('most_used_count'),
          );
        },
      );
}
