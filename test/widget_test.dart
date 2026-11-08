// Replaces the default counter smoke test, which referenced a counter app
// that no longer exists. Pure route-table checks need no DI or Hive setup.

import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/routing/route_registry.dart';

void main() {
  test('auth routes use the expected paths', () {
    expect(AuthRoutes.login.path, '/login');
    expect(AuthRoutes.register.path, '/register');
  });

  test('route paths are unique', () {
    final paths = allRoutes.map((r) => r.path).toList();

    expect(paths.toSet().length, paths.length);
  });
}
