import 'package:accounting_software/app/features/auth/domain/entity/user/user_entity.dart';
import 'package:accounting_software/app/features/auth/presentation/cubit/states/auth_states.dart';
import 'package:accounting_software/app/routing/route_guards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const unauth = AuthState.unauthenticated();

  String? run(
    String location, {
    bool splashDone = true,
    bool onboarded = true,
    AuthState auth = unauth,
  }) => resolveRedirect(
    location: location,
    splashDone: splashDone,
    onboarded: onboarded,
    authState: auth,
  );

  final authed = AuthState.authenticated(user: _user());

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

  group('auth in progress', () {
    test('never redirects while checking or loading', () {
      for (final s in [const AuthState.checking(), const AuthState.loading()]) {
        expect(run('/profile', auth: s), isNull);
        expect(run('/favorites', auth: s), isNull);
      }
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

  group('deny by default', () {
    test('protects unlisted routes such as /favorites', () {
      expect(run('/favorites'), '/login');
      expect(run('/profile'), '/login');
      expect(run('/anything/else'), '/login');
    });

    test('public routes stay open', () {
      expect(run('/login'), isNull);
      expect(run('/register'), isNull);
      expect(run('/onboarding'), isNull);
    });

    test('authenticated users reach protected routes', () {
      expect(run('/favorites', auth: authed), isNull);
      expect(run('/home', auth: authed), isNull);
    });

    test('authenticated users are moved away from login/register', () {
      expect(run('/login', auth: authed), '/home');
      expect(run('/register', auth: authed), '/home');
    });
  });
}

UserEntity _user() => const UserEntity(id: '1', email: 'a@b.c');
