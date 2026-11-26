import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class TagsEndpoint {
  static const collection = AppEndpoint('/rest/v1/tags');
  static const select = 'id,name,slug,is_active';
}
