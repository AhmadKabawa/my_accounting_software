import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/utility/brand_slug_from.dart';

void main() {
  test('normalizes English words', () {
    expect(brandSlugFrom('Vaude Store'), 'vaude-store');
  });

  test('collapses punctuation and repeated separators', () {
    expect(brandSlugFrom('A&B  Co.'), 'a-b-co');
  });

  test('does not transliterate Arabic names', () {
    expect(brandSlugFrom('ماركة عربية'), '');
  });

  test('preserves digits', () {
    expect(brandSlugFrom('Brand 2026'), 'brand-2026');
    expect(brandSlugFrom('12345'), '12345');
  });
}
