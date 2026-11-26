import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class ProductTypeLinksEndpoints {
  static const sizeGroupLinks = AppEndpoint('/rest/v1/product_type_size_groups');
  static const attributeLinks = AppEndpoint('/rest/v1/product_type_attributes');
  static const optionSetLinks = AppEndpoint('/rest/v1/product_type_option_sets');
  static const sizeGroups = AppEndpoint('/rest/v1/size_groups');
  static const attributes = AppEndpoint('/rest/v1/attributes');
  static const optionSets = AppEndpoint('/rest/v1/option_sets');
  static const genders = AppEndpoint('/rest/v1/genders');
  static const products = AppEndpoint('/rest/v1/products');

  static const sizeGroupLinkSelect =
      'id,size_group_id,gender_id,is_default,sort_order,'
      'size_groups(id,name,code,size_systems(name)),genders(id,name)';
  static const attributeLinkSelect =
      'attribute_id,is_required,sort_order,attributes(id,name,code,data_type)';
  static const optionSetLinkSelect =
      'option_set_id,is_required,sort_order,option_sets(id,name,code)';
}
