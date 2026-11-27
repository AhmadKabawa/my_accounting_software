import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class ColorsEndpoint {
  static const collection = AppEndpoint('/rest/v1/colors');
  static const statsRpc = AppEndpoint('/rest/v1/rpc/color_stats');
  static const usageView = AppEndpoint('/rest/v1/v_color_usage');
  static const select =
      'id,name,code,hex_code,is_active,sort_order,created_at';
}
