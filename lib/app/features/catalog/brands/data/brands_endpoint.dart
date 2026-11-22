import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class BrandsEndpoint {
  static const collection = AppEndpoint('/rest/v1/brands');
  static const select = 'id,name,slug,logo,description,is_active,updated_at';
  static const selectWithProductCount =
      'id,name,slug,logo,description,is_active,updated_at,products(count)';

  /// Storage bucket used for logos (docs/backend §7: public, 5 MB,
  /// JPEG/PNG/WebP; writes need `catalog.manage`).
  static const logoBucket = 'product-images';
  static const logoFolder = 'brands';

  static AppEndpoint logoUpload(String path) =>
      AppEndpoint('/storage/v1/object/$logoBucket/$path');

  /// Public URL stored in `brands.logo`.
  static String logoPublicUrl(String baseUrl, String path) =>
      '$baseUrl/storage/v1/object/public/$logoBucket/$path';
}
