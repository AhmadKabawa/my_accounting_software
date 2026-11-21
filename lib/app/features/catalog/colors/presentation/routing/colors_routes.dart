import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class ColorsRoutes {
  static const colors = RouteItem('/catalog/colors', 'catalog.colors');
  static const List<RouteItem> all = [colors];
}
