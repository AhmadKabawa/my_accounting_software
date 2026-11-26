import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class UnitsEndpoint {
  static const collection = AppEndpoint('/rest/v1/units');
  static const baseSelect = 'id,name,symbol,unit_type,is_active,updated_at';
  static const select =
      'id,name,symbol,unit_type,is_active,updated_at,product_variants(count),attributes(count)';
}
