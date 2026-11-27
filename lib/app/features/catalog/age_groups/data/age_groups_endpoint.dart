import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class AgeGroupsEndpoint {
  static const collection = AppEndpoint('/rest/v1/age_groups');
  static const select =
      'id,name,min_age,max_age,is_active,sort_order,product_age_groups(count)';
}
