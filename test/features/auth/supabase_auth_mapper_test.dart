import 'package:flutter_test/flutter_test.dart';

import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/supabase_auth_mapper.dart';

void main() {
  const sessionJson = {
    'access_token': 'a',
    'refresh_token': 'r',
    'user': {
      'id': 'u1',
      'email': 'x@y.com',
      'phone': '',
      'created_at': '2026-01-02T03:04:05Z',
      'user_metadata': {'full_name': 'Ali', 'phone': '123'},
    },
  };

  test('maps a Supabase session to tokens and user', () {
    final result = sessionFromSupabase(Map.of(sessionJson));

    expect(result.tokens.accessToken, 'a');
    expect(result.tokens.refreshToken, 'r');
    expect(result.tokens.userId, 'u1');
    expect(result.user.fullName, 'Ali');
    expect(result.user.phone, '123');
    expect(result.user.createdAt, DateTime.utc(2026, 1, 2, 3, 4, 5));
  });

  test('a response without a session is rejected, not half-parsed', () {
    expect(
      () => sessionFromSupabase({'id': 'u1', 'email': 'x@y.com'}),
      throwsFormatException,
    );
  });
}
