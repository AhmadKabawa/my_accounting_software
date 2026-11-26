import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class SportsEndpoint {
  static const collection = AppEndpoint('/rest/v1/sports');
  static const select = 'id,name,code,description,is_active,sort_order';
}
