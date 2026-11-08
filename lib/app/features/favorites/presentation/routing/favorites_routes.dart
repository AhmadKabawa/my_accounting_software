import 'package:accounting_software/app/core/routing/route_item.dart';

/// Routes owned by the favorites feature.
abstract final class FavoritesRoutes {
  static const favorites = RouteItem('/favorites', 'favorites');

  /// Every route above. `route_registry.dart` collects this list, and
  /// `route_guards_test.dart` fails if a route is missing from it.
  static const List<RouteItem> all = [favorites];
}
