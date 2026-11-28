import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class SeasonsRoutes {
  static const seasons = RouteItem('/catalog/seasons', 'catalog.seasons');
  static const List<RouteItem> all = [seasons];
}
