import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';

void main() {
  test('withSort equals withSorts for every field and direction', () {
    const base = BrandListQuery(
      page: 4,
      thenSorts: [BrandSort(BrandSortField.updated, false)],
    );
    for (final field in BrandSortField.values) {
      for (final ascending in [true, false]) {
        final expected = base.withSort(field: field, ascending: ascending);
        final actual = base.withSorts([BrandSort(field, ascending)]);
        expect(actual, expected, reason: '${field.name}, ascending=$ascending');
      }
    }
  });

  test('withSorts retains every distinct criterion in priority order', () {
    const expected = [
      BrandSort(BrandSortField.status, false),
      BrandSort(BrandSortField.newest, true),
      BrandSort(BrandSortField.updated, false),
      BrandSort(BrandSortField.name, true),
    ];
    final query = const BrandListQuery().withSorts(expected);
    expect(query.sorts, expected);
  });
}
