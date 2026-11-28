import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class CareInstructionsEndpoint {
  static const collection = AppEndpoint('/rest/v1/care_instructions');
  static const select = 'id,name,code,care_type,description,is_active,sort_order,product_care_instructions(count),product_type_care_instructions(count)';
}
