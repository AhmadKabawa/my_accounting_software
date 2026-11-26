import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class SportsRoutes {
  static const sports = RouteItem('/catalog/sports', 'catalog.sports');
  static const List<RouteItem> all = [sports];
}
