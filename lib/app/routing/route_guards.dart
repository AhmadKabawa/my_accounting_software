import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/routing/app_go_router.dart';
import 'package:accounting_software/app/core/routing/routes.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';
import 'package:accounting_software/app/features/splash/presentation/cubit/splash_state.dart';

/// مسؤول عن توجيه الـ Splash فقط (يعمل مرة واحدة)
abstract class SplashRoutingLogic {
  static const _splashRoutes = {'/splash', '/'};

  /// يعيد redirect فقط إذا لم تكتمل الـ Splash
  static String? checkSplashCompletion(
    BuildContext context,
    String currentLocation,
  ) {
    // لا توجه من صفحة الـ Splash نفسها
    if (_splashRoutes.contains(currentLocation)) return null;

    final splashState = AppRouter.splashCubit.state;
    if (splashState is! SplashDone) {
      return AppRoutes.splash.path;
    }

    return null;
  }
}

/// مسؤول عن توجيه الـ Onboarding فقط
abstract class OnboardingRoutingLogic {
  static const _onboardingRoutes = {'/onboarding'}; //'/splash', '/'

  /// يعيد redirect للـ Onboarding إذا لم يكتمل
  static Future<String?> checkOnboardingCompletion(
    BuildContext context,
    String currentLocation,
  ) async {
    // لا توجه من صفحات البداية نفسها
    if (_onboardingRoutes.contains(currentLocation)) return null;

    final settings = AppRouter.settings;
    final isOnboarded = await settings.isOnboarded();

    if (!isOnboarded) {
      return AppRoutes.onboarding.path;
    }

    return null;
  }
}

/// مسؤول عن توجيه المصادقة فقط
abstract class AuthRoutingLogic {
  static const _protectedRoutes = {
    '/home',
    '/profile',
    '/products',
    '/settings',
  };

  static const _authRoutes = {'/login', '/register'};

  /// يعيد redirect للـ Login إذا حاول الوصول لصفحة محمية بدون تسجيل
  static String? requireAuthentication(
    BuildContext context,
    String currentLocation,
  ) {
    // تجاهل إذا لم تكن صفحة محمية
    if (!_protectedRoutes.contains(currentLocation)) return null;

    final authState = AppRouter.authCubit.state;

    if (authState is Authenticated) {
      return null; // لديه صلاحيات، لا توجيه
    }

    if (authState is AuthChecking) {
      return null; // انتظر انتهاء التحقق
    }

    return AppRoutes.login.path; // لم يسجل دخول
  }

  /// يعيد redirect للـ Home إذا حاول الوصول لصفحة تسجيل وهو مسجل دخول بالفعل
  static String? preventAuthenticatedAccess(
    BuildContext context,
    String currentLocation,
  ) {
    // تجاهل إذا لم تكن صفحة auth
    if (!_authRoutes.contains(currentLocation)) return null;

    final authState = AppRouter.authCubit.state;

    if (authState is Authenticated) {
      return AppRoutes.home.path; // أعده للـ Home
    }

    return null; // دعه يكمل في صفحة التسجيل
  }
}

/// مسؤول عن توجيه الصلاحيات فقط (UX؛ الخادم هو الحماية الفعلية).
abstract class AccessRoutingLogic {
  /// يُستخدم على أي مسار: `GoRoute(redirect: AccessRoutingLogic.require(Permissions.reports.view))`.
  /// يعيد المستخدم إلى [fallback] إن لم يملك [permission].
  /// يجب ألا يكون [fallback] نفسه محميًا بنفس الصلاحية لتجنب حلقة توجيه.
  static GoRouterRedirect require(
    Permission permission, {
    RouteItem fallback = AppRoutes.home,
  }) => (context, state) =>
      AppRouter.accessCubit.can(permission) ? null : fallback.path;
}
