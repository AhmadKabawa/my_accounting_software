import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/validation/slug.dart';

void main() {
  group('Slug.from', () {
    test('lowercases and joins words with hyphens', () {
      expect(Slug.from('Vaude Store'), 'vaude-store');
    });

    test('collapses runs of symbols and trims edge hyphens', () {
      expect(Slug.from('  --A&B  Co.--  '), 'a-b-co');
    });

    test('returns empty for text without ASCII letters or digits', () {
      expect(Slug.from('تصنيف عربي'), '');
    });

    test('keeps digits', () {
      expect(Slug.from('Class 2026'), 'class-2026');
    });
  });

  group('Slug.isValid', () {
    test('accepts lowercase alphanumeric groups', () {
      expect(Slug.isValid('men-shoes-2'), isTrue);
    });

    test('rejects uppercase, spaces, edge or double hyphens and null', () {
      for (final bad in [
        'Men',
        'men shoes',
        '-men',
        'men-',
        'men--shoes',
        '',
      ]) {
        expect(Slug.isValid(bad), isFalse, reason: bad);
      }
      expect(Slug.isValid(null), isFalse);
    });
  });
}
