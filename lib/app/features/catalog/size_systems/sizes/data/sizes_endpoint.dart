import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class SizesEndpoint {
  static const collection = AppEndpoint('/rest/v1/sizes');

  static const _base =
      'id,size_group_id,name,code,numeric_value,sort_order,is_active,'
      'updated_at';

  /// Preferred projection with the product usage count.
  static const select = '$_base,product_sizes(count)';

  /// Safe fallback when PostgREST rejects the embedded relation (HTTP 400).
  static const selectWithoutCount = _base;
}
