import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/on_boarding/presentation/routing/on_boarding_routes.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/routing/route_registry.dart';

void main() {
  group('v1 feature flags', () {
    test('all deferred features are disabled by default', () {
      expect(AppConfig.signupEnabled, isFalse);
      expect(AppConfig.googleSignInEnabled, isFalse);
      expect(AppConfig.forgotPasswordEnabled, isFalse);
      expect(AppConfig.onboardingEnabled, isFalse);
    });

    test('disabled routes are absent from the registry and public routes', () {
      final routes = buildRouteRegistry().map((route) => route.path).toSet();

      expect(routes, isNot(contains(AuthRoutes.register.path)));
      expect(routes, isNot(contains(AuthRoutes.forgotPassword.path)));
      expect(routes, isNot(contains(AuthRoutes.resetPassword.path)));
      expect(routes, isNot(contains(OnBoardingRoutes.onboarding.path)));

      expect(publicRoutes, isNot(contains(AuthRoutes.register.path)));
      expect(publicRoutes, isNot(contains(AuthRoutes.forgotPassword.path)));
      expect(publicRoutes, isNot(contains(AuthRoutes.resetPassword.path)));
      expect(publicRoutes, isNot(contains(OnBoardingRoutes.onboarding.path)));
    });

    test('direct links to disabled routes are left for the not-found page', () {
      const session = SessionUnauthenticated();
      final disabledPaths = [
        AuthRoutes.register.path,
        AuthRoutes.forgotPassword.path,
        AuthRoutes.resetPassword.path,
        OnBoardingRoutes.onboarding.path,
      ];

      for (final path in disabledPaths) {
        expect(
          resolveRedirect(
            location: path,
            splashDone: true,
            onboarded: true,
            session: session,
          ),
          isNull,
          reason: '$path must not be redirected to another feature',
        );
      }
    });

    test('enabled signup route is registered and public', () {
      final routes = buildRouteRegistry(
        signupEnabled: true,
      ).map((route) => route.path).toSet();
      final public = buildPublicRoutes(signupEnabled: true);

      expect(routes, contains(AuthRoutes.register.path));
      expect(public, contains(AuthRoutes.register.path));
    });

    test('enabled password recovery routes are registered and public', () {
      final routes = buildRouteRegistry(
        forgotPasswordEnabled: true,
      ).map((route) => route.path).toSet();
      final public = buildPublicRoutes(forgotPasswordEnabled: true);

      expect(routes, contains(AuthRoutes.forgotPassword.path));
      expect(routes, contains(AuthRoutes.resetPassword.path));
      expect(public, contains(AuthRoutes.forgotPassword.path));
      expect(public, contains(AuthRoutes.resetPassword.path));
    });

    test('enabled onboarding route is registered and public', () {
      expect(
        OnBoardingRoutes.all(enabled: true),
        [OnBoardingRoutes.onboarding],
      );
      expect(OnBoardingRoutes.all(enabled: false), isEmpty);

      final routes = buildRouteRegistry(
        onboardingEnabled: true,
      ).map((route) => route.path).toSet();
      final public = buildPublicRoutes(onboardingEnabled: true);

      expect(routes, contains(OnBoardingRoutes.onboarding.path));
      expect(public, contains(OnBoardingRoutes.onboarding.path));
    });

    test('all enabled flags restore every deferred route', () {
      final routes = buildRouteRegistry(
        signupEnabled: true,
        forgotPasswordEnabled: true,
        onboardingEnabled: true,
      ).map((route) => route.path).toSet();

      expect(
        routes,
        containsAll([
          AuthRoutes.register.path,
          AuthRoutes.forgotPassword.path,
          AuthRoutes.resetPassword.path,
          OnBoardingRoutes.onboarding.path,
        ]),
      );
    });
  });
}
