import 'package:accounting_software/app/core/network/api_end_points.dart';
abstract final class MaterialsEndpoint {
 static const collection = AppEndpoint('/rest/v1/materials');
 static const select = 'id,name,code,material_type,description,is_active';
}