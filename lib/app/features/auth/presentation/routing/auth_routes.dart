import 'package:accounting_software/app/core/routing/route_item.dart';

/// Routes owned by the auth feature.
abstract final class AuthRoutes {
  static const login = RouteItem('/login', 'login');
  static const register = RouteItem('/register', 'register');

  // Password recovery: reached by people who cannot sign in, so public.
  static const forgotPassword = RouteItem('/forgot-password', 'forgotPassword');

  // The e-mailed code is verified together with the new password, so there is
  // no separate "verify code" route (see `confirmNewPassword`).
  static const resetPassword = RouteItem(
    '/forgot-password/reset',
    'resetPassword',
  );

  /// Every route above. `route_registry.dart` collects this list, and
  /// `route_guards_test.dart` fails if a route is missing from it.
  static const List<RouteItem> all = [
    login,
    register,
    forgotPassword,
    resetPassword,
  ];
}
