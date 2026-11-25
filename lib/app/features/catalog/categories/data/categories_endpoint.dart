import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class CategoriesEndpoint {
  static const collection = AppEndpoint('/rest/v1/categories');

  /// Spec §19. `product_categories(count)` is the embedded usage count.
  static const select =
      'id,parent_id,name,slug,description,image,sort_order,is_active,'
      'product_categories(count)';

  /// Stable tree order; ids break ties so page boundaries do not move.
  static const order = 'sort_order.asc,name.asc,id.asc';
}
