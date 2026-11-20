import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class BrandsRoutes {
  static const brands = RouteItem('/brands', 'brands');
  static const List<RouteItem> all = [brands];
}
