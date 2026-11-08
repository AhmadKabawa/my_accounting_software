import 'dart:io';

import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/domain/session/session_gate.dart';
import 'package:accounting_software/app/features/auth/presentation/routing/auth_routes.dart';
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
    SessionStatus auth = unauth,
  }) => resolveRedirect(
    location: location,
    splashDone: splashDone,
    onboarded: onboarded,
    session: auth,
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
      expect(run('/', onboarded: false), '/onboarding');
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

  group('onboarding', () {
    test('forces onboarding for every other route', () {
      expect(run('/home', onboarded: false), '/onboarding');
      expect(run('/login', onboarded: false), '/onboarding');
    });

    test('allows the onboarding page itself', () {
      expect(run('/onboarding', onboarded: false), isNull);
    });
  });

  group('route classification', () {
    test('every registered route is explicitly public or protected', () {
      for (final route in allRoutes) {
        final isPublic = publicRoutes.contains(route.path);
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
      final registered = allRoutes.map((r) => r.path).toSet();
      for (final path in {...publicRoutes, ...protectedRoutes}) {
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
      final paths = allRoutes.map((r) => r.path).toList();
      final names = allRoutes.map((r) => r.name).toList();
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
        allRoutes.length,
        declared,
        reason:
            'a route declared in a feature is missing from its `all` list, or '
            'the feature is not spread in route_registry.dart',
      );
    });

    test('password recovery pages are reachable while signed out', () {
      for (final route in [AuthRoutes.forgotPassword, AuthRoutes.resetPassword]) {
        expect(run(route.path), isNull, reason: route.path);
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
      expect(run('/register'), isNull);
      expect(run('/onboarding'), isNull);
    });

    test('authenticated users reach protected routes', () {
      expect(run('/reports', auth: authed), isNull);
      expect(run('/home', auth: authed), isNull);
    });

    test('authenticated users are moved away from login/register', () {
      expect(run('/login', auth: authed), '/home');
      expect(run('/register', auth: authed), '/home');
    });
  });
}

UserEntity _user() => const UserEntity(id: '1', email: 'a@b.c');
