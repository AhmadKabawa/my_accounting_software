import 'package:accounting_software/app/core/network/api_end_points.dart';

abstract final class CollectionsEndpoint {
  static const collection = AppEndpoint('/rest/v1/collections');
  static const select =
      'id,name,code,description,image,start_date,end_date,is_active';
  static const imageBucket = 'product-images';
  static const imageFolder = 'collections';
}
