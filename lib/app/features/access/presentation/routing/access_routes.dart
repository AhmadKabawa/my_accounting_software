import 'package:accounting_software/app/core/routing/route_item.dart';

abstract final class AccessRoutes {
  static const denied = RouteItem('/access-denied', 'access.denied');
  static const List<RouteItem> all = [denied];
}
