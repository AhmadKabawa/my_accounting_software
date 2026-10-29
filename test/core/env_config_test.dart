import 'package:accounting_software/app/core/foundation/config/env_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void validate({
    String url = 'https://x.supabase.co',
    String key = 'anon',
    String google = '',
    bool web = false,
  }) => EnvConfig.validate(
    supabaseUrl: url,
    supabaseAnonKey: key,
    googleClientId: google,
    isWeb: web,
  );

  test('missing Supabase settings are rejected on every platform', () {
    expect(() => validate(url: ''), throwsStateError);
    expect(() => validate(key: ''), throwsStateError);
  });

  test('an empty Google client ID is fine off the web', () {
    expect(() => validate(), returnsNormally);
  });

  test('an empty Google client ID is rejected on the web with a clear message',
      () {
    expect(
      () => validate(web: true),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('GOOGLE_CLIENT_ID'),
        ),
      ),
    );
  });

  test('a Google client ID satisfies the web check', () {
    expect(() => validate(web: true, google: 'id.apps.googleusercontent.com'),
        returnsNormally);
  });
}
