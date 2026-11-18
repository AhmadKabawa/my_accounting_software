import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';

/// Build the route catalogue for the selected feature flags. Disabled
/// features are absent from the registry, not merely hidden in the UI.
List<RouteItem> buildRouteRegistry({
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
}) => [
  ...SplashRoutes.all,
  if (onboardingEnabled) ...OnBoardingRoutes.all,
  AuthRoutes.login,
  if (signupEnabled) AuthRoutes.register,
  if (forgotPasswordEnabled) ...[
    AuthRoutes.forgotPassword,
    AuthRoutes.resetPassword,
  ],
  ...HomeRoutes.all,
  ...ProfileRoutes.all,
];

/// Routes used by the running application.
final List<RouteItem> allRoutes = buildRouteRegistry();
