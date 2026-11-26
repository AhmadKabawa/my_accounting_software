import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class AttributesEndpoint {
  static const collection = AppEndpoint('/rest/v1/attributes');
  static const select =
      'id,name,code,data_type,unit_id,option_set_id,is_filterable,is_active,units(id,name,symbol),option_sets(id,name,code),product_type_attributes(count),product_attribute_values(count)';
  static const unitsLookup = AppEndpoint('/rest/v1/units');
  static const optionSetsLookup = AppEndpoint('/rest/v1/option_sets');
}
