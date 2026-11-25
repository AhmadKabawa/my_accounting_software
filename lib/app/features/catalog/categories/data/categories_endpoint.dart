import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class CategoriesEndpoint {
  static const collection = AppEndpoint('/rest/v1/categories');

  /// Preferred projection with the linked product usage count.
  static const select =
      'id,parent_id,name,slug,description,image,sort_order,is_active,'
      'product_categories(count)';

  /// Safe fallback when PostgREST cannot resolve the embedded relation.
  static const selectWithoutProductCount =
      'id,parent_id,name,slug,description,image,sort_order,is_active';

  static const order = 'sort_order.asc,name.asc,id.asc';
}
