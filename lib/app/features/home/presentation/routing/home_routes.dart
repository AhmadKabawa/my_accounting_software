import 'package:accounting_software/app/core/routing/route_item.dart';

/// Routes owned by the home feature.
abstract final class HomeRoutes {
  static const home = RouteItem('/home', 'home');

  /// Every route above. `route_registry.dart` collects this list, and
  /// `route_guards_test.dart` fails if a route is missing from it.
  static const List<RouteItem> all = [home];
}
