import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/routing/app_go_router.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';

/// المسارات المتاحة دون تسجيل دخول. المسارات المعطّلة غير مسجلة أصلاً.
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

/// المسارات المحمية، مذكورة صراحةً.
final Set<String> protectedRoutes = {
  AuthRoutes.selectBranch.path,
  HomeRoutes.home.path,
  ProfileRoutes.profile.path,
};

/// دالة نقية تحدد وجهة التوجيه. المسارات المعطّلة تُترك لـ GoRouter
/// كي يعرض NotFoundScreen لأنها غير موجودة في شجرة المسارات.
String? resolveRedirect({
  required String location,
  required bool splashDone,
  required bool onboarded,
  required SessionStatus session,
  bool branchSelectionRequired = false,
  bool onboardingEnabled = AppConfig.onboardingEnabled,
  bool signupEnabled = AppConfig.signupEnabled,
  bool forgotPasswordEnabled = AppConfig.forgotPasswordEnabled,
}) {
  final splash = SplashRoutes.splash.path;
  final onboarding = OnBoardingRoutes.onboarding.path;
  final login = AuthRoutes.login.path;
  final home = HomeRoutes.home.path;

  final disabledRoutes = {
    if (!signupEnabled) AuthRoutes.register.path,
    if (!forgotPasswordEnabled) ...[
      AuthRoutes.forgotPassword.path,
      AuthRoutes.resetPassword.path,
    ],
    if (!onboardingEnabled) OnBoardingRoutes.onboarding.path,
  };
  // Let GoRouter's errorPageBuilder render NotFoundScreen for disabled paths.
  if (disabledRoutes.contains(location)) return null;

  if (!splashDone) return location == splash ? null : splash;

  if (session is SessionChecking) return null;

  final authenticated = session is SessionAuthenticated;

  if (location == splash) {
    if (onboardingEnabled && !onboarded) return onboarding;
    return authenticated ? home : login;
  }

  if (onboardingEnabled && !onboarded) {
    return location == onboarding ? null : onboarding;
  }

  if (authenticated) {
    final selectBranch = AuthRoutes.selectBranch.path;
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

/// مسؤول عن توجيه الصلاحيات فقط (UX؛ الخادم هو الحماية الفعلية).
abstract class AccessRoutingLogic {
  /// يُستخدم على أي مسار: `GoRoute(redirect: AccessRoutingLogic.require(Permissions.reports.view))`.
  /// يعيد المستخدم إلى [fallback] إن لم يملك [permission].
  /// يجب ألا يكون [fallback] نفسه محميًا بنفس الصلاحية لتجنب حلقة توجيه.
  static GoRouterRedirect require(
    Permission permission, {
    RouteItem fallback = HomeRoutes.home,
  }) =>
      (context, state) =>
          AppRouter.accessCubit.can(permission) ? null : fallback.path;
}
