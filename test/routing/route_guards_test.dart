import 'dart:io';

import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/routing/brands_routes.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:accounting_software/app/routing/route_registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every `<feature>_routes.dart` under `features/*/presentation/routing/`.
Iterable<File> _featureRouteFiles() => Directory('lib/app/features')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) {
      final path = f.path.replaceAll(r'\', '/');
      return path.contains('/presentation/routing/') &&
          path.endsWith('_routes.dart');
    });

void main() {
  const unauth = SessionUnauthenticated();

  String? run(
    String location, {
    bool splashDone = true,
    bool onboarded = true,
    bool signupEnabled = false,
    bool forgotPasswordEnabled = false,
    bool onboardingEnabled = false,
    SessionStatus auth = unauth,
    bool branchRequired = false,
    bool mustChangePassword = false,
  }) => resolveRedirect(
    location: location,
    splashDone: splashDone,
    onboarded: onboarded,
    session: auth,
    mustChangePassword: mustChangePassword,
    branchSelectionRequired: branchRequired,
    signupEnabled: signupEnabled,
    forgotPasswordEnabled: forgotPasswordEnabled,
    onboardingEnabled: onboardingEnabled,
  );

  final authed = SessionAuthenticated(_user());

  group('splash', () {
    test('everything goes to splash until it is done', () {
      expect(run('/home', splashDone: false), '/');
      expect(run('/login', splashDone: false), '/');
    });

    test('stays on splash while it is running', () {
      expect(run('/', splashDone: false), isNull);
    });

    test('leaves splash once done', () {
      expect(
        run('/', onboarded: false, onboardingEnabled: true),
        '/onboarding',
      );
      expect(run('/'), '/login');
      expect(run('/', auth: authed), '/home');
    });
  });

  group('session check in progress', () {
    test('never redirects while checking', () {
      const checking = SessionChecking();
      expect(run('/profile', auth: checking), isNull);
      expect(run('/reports', auth: checking), isNull);
    });
  });

  group('forced password change (AUTH-02)', () {
    test('blocks all authenticated destinations until password change', () {
      expect(
        run('/home', auth: authed, mustChangePassword: true),
        '/change-password',
      );
      expect(
        run(
          '/select-branch',
          auth: authed,
          mustChangePassword: true,
          branchRequired: true,
        ),
        '/change-password',
      );
      expect(
        run('/login', auth: authed, mustChangePassword: true),
        '/change-password',
      );
      expect(
        run('/profile', auth: authed, mustChangePassword: true),
        '/change-password',
      );
    });

    test('allows only the change-password route while the flag is set', () {
      expect(
        run('/change-password', auth: authed, mustChangePassword: true),
        isNull,
      );
    });

    test('after completion, sends the user to branch selection or home', () {
      expect(
        run('/change-password', auth: authed, branchRequired: true),
        '/select-branch',
      );
      expect(run('/change-password', auth: authed), '/home');
    });

    test('the flag does not grant access to an unauthenticated user', () {
      expect(run('/change-password', mustChangePassword: true), '/login');
    });
  });

  group('branch selection (AUTH-03)', () {
    test('sends a signed-in user without a branch to the picker', () {
      const picker = '/select-branch';
      expect(run('/home', auth: authed, branchRequired: true), picker);
      expect(run('/login', auth: authed, branchRequired: true), picker);
    });

    test('stays on the picker while a branch is required', () {
      expect(run('/select-branch', auth: authed, branchRequired: true), isNull);
    });

    test('leaves the picker once no branch is required', () {
      expect(run('/select-branch', auth: authed), '/home');
    });

    test('never applies to signed-out users', () {
      expect(run('/select-branch'), '/login');
      expect(run('/home', branchRequired: true), '/login');
    });
  });

  group('onboarding', () {
    test('forces onboarding for every other route', () {
      expect(
        run('/home', onboarded: false, onboardingEnabled: true),
        '/onboarding',
      );
      expect(
        run('/login', onboarded: false, onboardingEnabled: true),
        '/onboarding',
      );
    });

    test('allows the onboarding page itself', () {
      expect(
        run('/onboarding', onboarded: false, onboardingEnabled: true),
        isNull,
      );
    });
  });

  group('route classification', () {
    test('every registered route is explicitly public or protected', () {
      final routeCatalog = buildRouteRegistry(
        signupEnabled: true,
        forgotPasswordEnabled: true,
        onboardingEnabled: true,
      );
      final publicPaths = buildPublicRoutes(
        signupEnabled: true,
        forgotPasswordEnabled: true,
        onboardingEnabled: true,
      );
      for (final route in routeCatalog) {
        final isPublic = publicPaths.contains(route.path);
        final isProtected = protectedRoutes.contains(route.path);
        expect(
          isPublic != isProtected,
          isTrue,
          reason:
              '${route.path} must be in exactly one of publicRoutes / '
              'protectedRoutes (public=$isPublic, protected=$isProtected)',
        );
      }
    });

    test('every classified path belongs to a registered route', () {
      final routeCatalog = buildRouteRegistry(
        signupEnabled: true,
        forgotPasswordEnabled: true,
        onboardingEnabled: true,
      );
      final publicPaths = buildPublicRoutes(
        signupEnabled: true,
        forgotPasswordEnabled: true,
        onboardingEnabled: true,
      );
      final registered = routeCatalog.map((r) => r.path).toSet();
      for (final path in {...publicPaths, ...protectedRoutes}) {
        expect(
          registered.contains(path),
          isTrue,
          reason:
              '$path is classified in route_guards.dart but no feature '
              'declares it (stale entry?)',
        );
      }
    });

    test('route paths and names are unique across features', () {
      final routeCatalog = buildRouteRegistry(
        signupEnabled: true,
        forgotPasswordEnabled: true,
        onboardingEnabled: true,
      );
      final paths = routeCatalog.map((r) => r.path).toList();
      final names = routeCatalog.map((r) => r.name).toList();
      expect(paths.toSet().length, paths.length, reason: 'duplicate path');
      expect(names.toSet().length, names.length, reason: 'duplicate name');
    });

    test('allRoutes lists every route declared in the features', () {
      final files = _featureRouteFiles().toList();
      expect(files, isNotEmpty, reason: 'no *_routes.dart file was found');

      final declaration = RegExp(
        r'^\s*static const \w+ = RouteItem\(',
        multiLine: true,
      );
      final declared = files
          .map((f) => declaration.allMatches(f.readAsStringSync()).length)
          .fold<int>(0, (sum, n) => sum + n);

      expect(
        buildRouteRegistry(
          signupEnabled: true,
          forgotPasswordEnabled: true,
          onboardingEnabled: true,
        ).length,
        declared,
        reason:
            'a route declared in a feature is missing from its `all` list, or '
            'the feature is not spread in route_registry.dart',
      );
    });

    test('password recovery pages are reachable while signed out', () {
      for (final route in [
        AuthRoutes.forgotPassword,
        AuthRoutes.resetPassword,
      ]) {
        expect(
          run(route.path, forgotPasswordEnabled: true),
          isNull,
          reason: route.path,
        );
      }
    });
  });

  group('CAT-07 master-data route alias', () {
    test('redirects to the Catalog hub, which links to Brands', () {
      expect(CatalogRoutes.masterData.path, '/catalog/master-data');
      expect(CatalogRoutes.hub.path, '/catalog');
      expect(catalogMasterDataRedirect(), CatalogRoutes.hub.path);
      expect(BrandsRoutes.brands.path, '/catalog/brands');
    });

    test('alias and Brands use the same protected session guards', () {
      for (final path in [
        CatalogRoutes.hub.path,
        CatalogRoutes.masterData.path,
        BrandsRoutes.brands.path,
      ]) {
        expect(protectedRoutes.contains(path), isTrue, reason: path);
        expect(publicRoutes.contains(path), isFalse, reason: path);
        expect(run(path), '/login', reason: '$path requires a session');
        expect(
          run(path, auth: authed),
          isNull,
          reason: '$path allows signed-in read access',
        );
        expect(
          run(path, auth: authed, branchRequired: true),
          '/select-branch',
          reason: '$path obeys branch selection',
        );
        expect(
          run(path, auth: authed, mustChangePassword: true),
          '/change-password',
          reason: '$path obeys forced password change',
        );
      }
    });
  });

  group('deny by default', () {
    test('protects unlisted routes such as /reports', () {
      expect(run('/reports'), '/login');
      expect(run('/profile'), '/login');
      expect(run('/anything/else'), '/login');
    });

    test('public routes stay open', () {
      expect(run('/login'), isNull);
      expect(run('/register', signupEnabled: true), isNull);
      expect(run('/onboarding', onboardingEnabled: true), isNull);
    });

    test('authenticated users reach protected routes', () {
      expect(run('/reports', auth: authed), isNull);
      expect(run('/home', auth: authed), isNull);
    });

    test('authenticated users are moved away from login/register', () {
      expect(run('/login', auth: authed), '/home');
      expect(run('/register', auth: authed, signupEnabled: true), '/home');
    });
  });
}

UserEntity _user() => const UserEntity(id: '1', email: 'a@b.c');
