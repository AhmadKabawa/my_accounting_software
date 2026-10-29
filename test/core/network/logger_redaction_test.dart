import 'package:accounting_software/app/core/services/network/dio/interceptors/logger_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('masks sensitive keys at any depth, case-insensitively', () {
    final out = redactSensitive({
      'email': 'a@b.c',
      'password': 'hunter2',
      'session': {
        'access_token': 'aaa',
        'Refresh_Token': 'rrr',
        'user': {'id': 1},
      },
      'profile': {
        'access_token': 'aaa',
        'Refresh_Token': 'rrr',
        'user': {'id': 1},
      },
      'items': [
        {'secret': 's', 'name': 'x'},
      ],
      'code': '123456',
      'error_code': 'invalid_grant',
    });

    expect(out, {
      'email': 'a@b.c',
      'password': '***',
      // `session` is itself a sensitive key now, so the whole object is masked.
      'session': '***',
      'profile': {
        'access_token': '***',
        'Refresh_Token': '***',
        'user': {'id': 1},
      },
      'items': [
        {'secret': '***', 'name': 'x'},
      ],
      'code': '***',
      'error_code': 'invalid_grant',
    });
  });

  test('parses JSON strings before masking', () {
    expect(
      redactSensitive('{"refresh_token":"abc","ok":true}'),
      {'refresh_token': '***', 'ok': true},
    );
  });

  test('does not print non-JSON bodies', () {
    expect(redactSensitive('token=abc'), '<non-JSON body, 9 chars>');
  });

  test('leaves scalars and null untouched', () {
    expect(redactSensitive(null), isNull);
    expect(redactSensitive(3), 3);
    expect(redactSensitive(true), true);
  });

  test('masks every extended sensitive key', () {
    const keys = [
      'password', 'passwd', 'token', 'access_token', 'refreshToken',
      'secret', 'Authorization', 'auth', 'session', 'sessionId', 'refresh',
      'access', 'jwt', 'Cookie', 'Set-Cookie', 'api_key', 'apikey', 'api-key',
      'pin', 'otp', 'code', 'verification_code', 'reset_code', 'sms_otp',
      'passcode',
    ];
    for (final key in keys) {
      expect(redactSensitive({key: 'v'}), {key: '***'}, reason: key);
    }
  });

  test('does not mask look-alike keys', () {
    for (final key in [
      'zipcode', 'option', 'spinner', 'email', 'name', 'error_code',
    ]) {
      expect(redactSensitive({key: 'v'}), {key: 'v'}, reason: key);
    }
  });

  group('redactUri', () {
    test('masks sensitive query values', () {
      final out = redactUri(Uri.parse('https://x.co/a?token=abc&page=2'));
      expect(out.queryParameters, {'token': '***', 'page': '2'});
    });

    test('masks JWT-like and long opaque path segments', () {
      const jwt = 'aaaaaaaaaa.bbbbbbbbbb.cccccccccc';
      final opaque = 'a' * 40;
      expect(
        redactUri(Uri.parse('https://x.co/verify/$jwt')).pathSegments,
        ['verify', '***'],
      );
      expect(
        redactUri(Uri.parse('https://x.co/reset/$opaque/done')).pathSegments,
        ['reset', '***', 'done'],
      );
    });

    test('leaves UUID resource ids readable', () {
      final uri = Uri.parse(
        'https://x.co/products/123e4567-e89b-12d3-a456-426614174000',
      );
      expect(redactUri(uri), uri);
    });

    test('leaves ordinary paths untouched', () {
      final uri = Uri.parse('https://x.co/products/42/reviews');
      expect(redactUri(uri), uri);
    });
  });
}
