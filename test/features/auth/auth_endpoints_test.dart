import 'package:accounting_software/app/features/auth/data/auth_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The refresh interceptor in core is given `AuthEndpoints.token` by the
  // composition root, so a change here changes what the session renewal calls.
  test('the auth endpoints point at Supabase Auth (GoTrue)', () {
    expect(AuthEndpoints.token.path, '/auth/v1/token');
    expect(AuthEndpoints.signup.path, '/auth/v1/signup');
    expect(AuthEndpoints.logout.path, '/auth/v1/logout');
    expect(AuthEndpoints.user.path, '/auth/v1/user');
    expect(AuthEndpoints.recover.path, '/auth/v1/recover');
    expect(AuthEndpoints.verify.path, '/auth/v1/verify');
  });
}
