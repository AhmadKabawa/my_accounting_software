import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class ColorsEndpoint {
  static const collection = AppEndpoint('/rest/v1/colors');
  static const select = 'id,name,code,hex_code,is_active,sort_order';
}
