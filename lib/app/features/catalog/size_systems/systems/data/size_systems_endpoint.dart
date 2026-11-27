import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class SizeSystemsEndpoint {
  static const collection = AppEndpoint('/rest/v1/size_systems');

  /// Preferred projection with the linked group count.
  static const select =
      'id,name,code,description,is_active,updated_at,size_groups(count)';

  /// Safe fallback when PostgREST rejects the embedded relation (HTTP 400).
  static const selectWithoutCount =
      'id,name,code,description,is_active,updated_at';
}
