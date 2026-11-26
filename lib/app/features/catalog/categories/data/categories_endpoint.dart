import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class CategoriesEndpoint {
  static const collection = AppEndpoint('/rest/v1/categories');

  /// Public bucket reused for category images. Its current write policy is
  /// catalog.manage, so backend approval is required for masterdata.manage.
  static const imageBucket = 'product-images';
  static const imageFolder = 'categories';

  /// Preferred projection with the linked product usage count.
  static const select =
      'id,parent_id,name,slug,description,image,sort_order,is_active,updated_at,'
      'product_categories(count)';

  /// Safe fallback when PostgREST cannot resolve the embedded relation.
  static const selectWithoutProductCount =
      'id,parent_id,name,slug,description,image,sort_order,is_active,updated_at';

  static const order = 'sort_order.asc,name.asc,id.asc';
}
