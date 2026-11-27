import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class SizeGroupsEndpoint {
  static const collection = AppEndpoint('/rest/v1/size_groups');

  /// Light read source for the gender picker/filter (id, name, is_active).
  static const genders = AppEndpoint('/rest/v1/genders');
  static const gendersSelect = 'id,name,is_active';
  static const gendersOrder = 'name.asc,id.asc';

  static const _base =
      'id,size_system_id,gender_id,name,code,description,is_active,updated_at';

  /// Preferred projection with the three usage counts.
  static const select =
      '$_base,sizes(count),product_type_size_groups(count),'
      'product_size_groups(count)';

  /// Safe fallback when PostgREST rejects the embedded relations (HTTP 400).
  static const selectWithoutCounts = _base;
}
