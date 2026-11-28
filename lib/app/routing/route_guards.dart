import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/routing/route_registry.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';

Set<String> buildPublicRoutes({
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
}) => {
  SplashRoutes.splash.path,
  if (onboardingEnabled) OnBoardingRoutes.onboarding.path,
  AuthRoutes.login.path,
  if (signupEnabled) AuthRoutes.register.path,
  if (forgotPasswordEnabled) ...[
    AuthRoutes.forgotPassword.path,
    AuthRoutes.resetPassword.path,
  ],
};

final Set<String> publicRoutes = buildPublicRoutes();

/// Session-protected paths are derived from the feature route registry.
/// Adding a route to a feature's all list automatically classifies it here.
final Set<String> protectedRoutes = allRoutes
    .map((route) => route.path)
    .where((path) => !publicRoutes.contains(path))
    .toSet();

/// Pure navigation policy. A forced password change is evaluated before
/// branch selection and before every other authenticated destination.
String? resolveRedirect({
  required String location,
  required bool splashDone,
  required bool onboarded,
  required SessionStatus session,
  bool mustChangePassword = false,
  bool branchSelectionRequired = false,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
}) {
  final splash = SplashRoutes.splash.path;
  final onboarding = OnBoardingRoutes.onboarding.path;
  final login = AuthRoutes.login.path;
  final home = HomeRoutes.home.path;
  final changePassword = AuthRoutes.changePassword.path;
  final selectBranch = AuthRoutes.selectBranch.path;

  final disabledRoutes = {
    if (!signupEnabled) AuthRoutes.register.path,
    if (!forgotPasswordEnabled) ...[
      AuthRoutes.forgotPassword.path,
      AuthRoutes.resetPassword.path,
    ],
    if (!onboardingEnabled) OnBoardingRoutes.onboarding.path,
  };
  if (disabledRoutes.contains(location)) return null;
  if (!splashDone) return location == splash ? null : splash;
  if (session is SessionChecking) return null;

  final authenticated = session is SessionAuthenticated;
  if (authenticated && mustChangePassword) {
    return location == changePassword ? null : changePassword;
  }
  if (authenticated && location == changePassword) {
    return branchSelectionRequired ? selectBranch : home;
  }

  if (location == splash) {
    if (onboardingEnabled && !onboarded) return onboarding;
    if (!authenticated) return login;
    return branchSelectionRequired ? selectBranch : home;
  }

  if (onboardingEnabled && !onboarded) {
    return location == onboarding ? null : onboarding;
  }

  if (authenticated) {
    if (branchSelectionRequired) {
      return location == selectBranch ? null : selectBranch;
    }
    if (location == selectBranch) return home;
    final authEntryRoutes = {
      AuthRoutes.login.path,
      if (signupEnabled) AuthRoutes.register.path,
    };
    return authEntryRoutes.contains(location) ? home : null;
  }

  final enabledPublicRoutes = buildPublicRoutes(
    signupEnabled: signupEnabled,
    forgotPasswordEnabled: forgotPasswordEnabled,
    onboardingEnabled: onboardingEnabled,
  );
  return enabledPublicRoutes.contains(location) ? null : login;
}

/// UX-only permission routing. The database remains the security boundary.
abstract class AccessRoutingLogic {
  /// Pure decision used by route redirects and unit tests.
  static String? resolve({
    required bool isResolved,
    required bool allowed,
    RouteItem fallback = HomeRoutes.home,
  }) => !isResolved || allowed ? null : fallback.path;

  /// Builds a UI navigation guard without depending on the global router.
  /// The caller supplies the permission reader, keeping routing policy pure
  /// and breaking the route_guards.dart <-> app_go_router.dart import cycle.
  static GoRouterRedirect require(
    Permission permission, {
    required bool Function(Permission permission) can,
    bool Function()? isResolved,
    RouteItem fallback = HomeRoutes.home,
  }) =>
      (context, state) => resolve(
        isResolved: isResolved?.call() ?? true,
        allowed: can(permission),
        fallback: fallback,
      );
}
