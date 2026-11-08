import 'package:accounting_software/app/core/routing/route_item.dart';

/// Routes owned by the on_boarding feature.
abstract final class OnBoardingRoutes {
  static const onboarding = RouteItem('/onboarding', 'onboarding');

  /// Every route above. `route_registry.dart` collects this list, and
  /// `route_guards_test.dart` fails if a route is missing from it.
  static const List<RouteItem> all = [onboarding];
}
