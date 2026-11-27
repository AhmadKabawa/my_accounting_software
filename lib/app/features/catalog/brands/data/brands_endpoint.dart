import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class BrandsEndpoint {
  static const collection = AppEndpoint('/rest/v1/brands');
  static const statsRpc = AppEndpoint('/rest/v1/rpc/brand_stats');
  static const select =
      'id,name,slug,logo,description,is_active,created_at,updated_at';
  static const selectWithProductCount =
      'id,name,slug,logo,description,is_active,created_at,updated_at,products(count)';

  /// Storage bucket used for logos; uploads require the appropriate Storage policy.
  static const logoBucket = 'product-images';
  static const logoFolder = 'brands';

  static AppEndpoint logoUpload(String path) =>
      AppEndpoint('/storage/v1/object/$logoBucket/$path');

  static String logoPublicUrl(String baseUrl, String path) =>
      '$baseUrl/storage/v1/object/public/$logoBucket/$path';
}
