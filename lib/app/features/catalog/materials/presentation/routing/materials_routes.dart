import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class MaterialsRoutes {
  static const materials = RouteItem('/catalog/materials', 'catalog.materials');
  static const List<RouteItem> all = [materials];
}
