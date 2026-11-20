import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class BrandsRoutes {
  static const brands = RouteItem('/catalog/brands', 'catalog.brands');
  static const List<RouteItem> all = [brands];
}
