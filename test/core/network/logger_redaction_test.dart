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
      'items': [
        {'secret': 's', 'name': 'x'},
      ],
      'code': '123456',
      'error_code': 'invalid_grant',
    });

    expect(out, {
      'email': 'a@b.c',
      'password': '***',
      'session': {
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
}
