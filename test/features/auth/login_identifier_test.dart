import 'package:accounting_software/app/features/auth/domain/login_identifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const domain = 'store.local';

  group('resolveLoginEmail (decision 66)', () {
    test('a plain username becomes username@domain', () {
      expect(resolveLoginEmail('admin', domain: domain), 'admin@store.local');
    });

    test('the username is trimmed and lower-cased', () {
      expect(
        resolveLoginEmail('  Ahmad ', domain: domain),
        'ahmad@store.local',
      );
    });

    test('a full e-mail is used as typed (only trimmed)', () {
      expect(
        resolveLoginEmail(' Admin@Real.com ', domain: domain),
        'Admin@Real.com',
      );
    });

    test('an empty domain leaves the value unchanged', () {
      expect(resolveLoginEmail('admin', domain: ''), 'admin');
    });

    test('a username that already carries the domain is not doubled', () {
      expect(
        resolveLoginEmail('admin@store.local', domain: domain),
        'admin@store.local',
      );
    });
  });
}
