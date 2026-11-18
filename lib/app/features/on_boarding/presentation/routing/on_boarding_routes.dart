import 'package:accounting_software/app/core/routing/route_item.dart';

/// Routes owned by the on_boarding feature.
abstract final class OnBoardingRoutes {
  static const onboarding = RouteItem('/onboarding', 'onboarding');

  /// Builds the route list from the injected feature flag. The registry
  /// must not capture AppConfig.onboardingEnabled in a const at load time.
  static List<RouteItem> all({required bool enabled}) =>
      enabled ? const [onboarding] : const [];
}
