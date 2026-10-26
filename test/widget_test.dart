// Replaces the default counter smoke test, which referenced a counter app
// that no longer exists. Pure route-table checks need no DI or Hive setup.

import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/core/routing/routes.dart';

void main() {
  test('auth routes use the expected paths', () {
    expect(AppRoutes.login.path, '/login');
    expect(AppRoutes.register.path, '/register');
  });

  test('route paths are unique', () {
    final paths = [
      AppRoutes.splash,
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.mainPages,
      AppRoutes.home,
      AppRoutes.profile,
      AppRoutes.chat,
      AppRoutes.favorites,
      AppRoutes.products,
      AppRoutes.settings,
    ].map((r) => r.path).toList();

    expect(paths.toSet().length, paths.length);
  });
}
