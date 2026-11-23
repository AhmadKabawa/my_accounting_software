import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';

void main() {
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
