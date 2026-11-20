import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class BrandsEndpoint {
  static const collection = AppEndpoint('/rest/v1/brands');
  static const select = 'id,name,slug,logo,description,is_active,created_at,updated_at';
}
