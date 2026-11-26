import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class UnitsRoutes {
  static const units = RouteItem('/catalog/units', 'catalog.units');
  static const List<RouteItem> all = [units];
}
