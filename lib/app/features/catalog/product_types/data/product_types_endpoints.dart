import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class ProductTypeEndpoints {
  static const collection = AppEndpoint('/rest/v1/product_types');
  static const select =
      'id,name,code,description,is_active,sort_order,updated_at,'
      'products(count),product_type_size_groups(count),'
      'product_type_attributes(count),product_type_option_sets(count),'
      'product_type_care_instructions(count)';
  static const selectWithoutUsageCounts =
      'id,name,code,description,is_active,sort_order,updated_at';
  static const order = 'sort_order.asc,name.asc,id.asc';
}
