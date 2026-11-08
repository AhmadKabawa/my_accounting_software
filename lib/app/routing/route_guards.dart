import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/routing/app_go_router.dart';
import 'package:accounting_software/app/core/routing/route_item.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/favorites/presentation/routing/favorites_routes.dart';
import 'package:accounting_software/app/features/home/presentation/routing/home_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/features/profile/presentation/routing/profile_routes.dart';
import 'package:accounting_software/app/features/splash/presentation/routing/splash_routes.dart';

/// المسارات المتاحة دون تسجيل دخول. أي مسار آخر محمي افتراضيًا (deny by default).
final Set<String> publicRoutes = {
  SplashRoutes.splash.path,
  OnBoardingRoutes.onboarding.path,
  AuthRoutes.login.path,
  AuthRoutes.register.path,
  AuthRoutes.forgotPassword.path,
  AuthRoutes.resetPassword.path,
};

/// المسارات المحمية، مذكورة صراحةً. أي مسار جديد في `allRoutes`
/// (`route_registry.dart`) يجب أن يظهر هنا أو في [publicRoutes] وإلا يفشل
/// `route_guards_test.dart`، ويفشل كذلك إن بقي هنا مسار لم يعد مسجلاً.
final Set<String> protectedRoutes = {
  HomeRoutes.home.path,
  FavoritesRoutes.favorites.path,
  ProfileRoutes.profile.path,
};

final Set<String> _authOnlyEntryRoutes = {
  AuthRoutes.login.path,
  AuthRoutes.register.path,
};

/// دالة نقية تحدد وجهة التوجيه. تعيد null عند عدم الحاجة لأي توجيه.
///
/// الترتيب: Splash ← Onboarding ← المصادقة. لا يحدث أي توجيه أثناء
/// [SessionChecking] حتى لا يُطرد المستخدم قبل التحقق من جلسته. الراوتر يعتمد
/// على عقد [SessionStatus] فقط، لا على أي Cubit.
String? resolveRedirect({
  required String location,
  required bool splashDone,
  required bool onboarded,
  required SessionStatus session,
}) {
  final splash = SplashRoutes.splash.path;
  final onboarding = OnBoardingRoutes.onboarding.path;
  final login = AuthRoutes.login.path;
  final home = HomeRoutes.home.path;

  if (!splashDone) return location == splash ? null : splash;

  if (session is SessionChecking) return null;

  final authenticated = session is SessionAuthenticated;

  if (location == splash) {
    if (!onboarded) return onboarding;
    return authenticated ? home : login;
  }

  if (!onboarded) return location == onboarding ? null : onboarding;

  if (authenticated) {
    return _authOnlyEntryRoutes.contains(location) ? home : null;
  }

  return publicRoutes.contains(location) ? null : login;
}

/// مسؤول عن توجيه الصلاحيات فقط (UX؛ الخادم هو الحماية الفعلية).
abstract class AccessRoutingLogic {
  /// يُستخدم على أي مسار: `GoRoute(redirect: AccessRoutingLogic.require(Permissions.reports.view))`.
  /// يعيد المستخدم إلى [fallback] إن لم يملك [permission].
  /// يجب ألا يكون [fallback] نفسه محميًا بنفس الصلاحية لتجنب حلقة توجيه.
  static GoRouterRedirect require(
    Permission permission, {
    RouteItem fallback = HomeRoutes.home,
  }) => (context, state) =>
      AppRouter.accessCubit.can(permission) ? null : fallback.path;
}
