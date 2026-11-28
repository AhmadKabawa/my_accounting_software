import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class SeasonsEndpoint {
  static const collection = AppEndpoint('/rest/v1/seasons');
  static const select =
      'id,name,code,season_type,description,start_date,end_date,is_active';
}
