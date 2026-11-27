import 'package:accounting_software/app/core/network/api_end_points.dart';
abstract final class FabricTypesEndpoint {
 static const collection = AppEndpoint('/rest/v1/fabric_types');
 static const select = 'id,name,code,fabric_category,is_named_fabric,description,is_active';
}