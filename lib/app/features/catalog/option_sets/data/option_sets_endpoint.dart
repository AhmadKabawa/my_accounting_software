import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class OptionSetsEndpoint {
  static const collection = AppEndpoint('/rest/v1/option_sets');
  static const select =
      'id,name,code,selection_type,is_active,options(id,name,code,sort_order,is_active),attributes(count),product_type_option_sets(count)';
  static AppEndpoint options(int optionSetId) =>
      AppEndpoint('/rest/v1/options?option_set_id=eq.$optionSetId');
}
