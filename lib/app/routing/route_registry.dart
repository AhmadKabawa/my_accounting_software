import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';

/// Every route of the app, gathered from the features that own them.
///
/// A new feature with routes = one line here. `route_guards_test.dart` checks
/// this list against the `*_routes.dart` files and against the public/protected
/// classification in `route_guards.dart`.
const List<RouteItem> allRoutes = [
  ...SplashRoutes.all,
  ...OnBoardingRoutes.all,
  ...AuthRoutes.all,
  ...HomeRoutes.all,
  ...ProfileRoutes.all,
];
