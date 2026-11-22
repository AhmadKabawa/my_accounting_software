import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';

void main() {
  test('sort fields map to whitelisted server columns', () {
    expect(BrandSortField.name.column, 'name');
    expect(BrandSortField.status.column, 'is_active');
    expect(BrandSortField.tryParse('status'), BrandSortField.status);
    expect(BrandSortField.tryParse('productCount'), isNull);
  });

  test('the query keeps its sort field in equality and copyWith', () {
    const base = BrandListQuery();
    final next = base.copyWith(sortField: BrandSortField.status);
    expect(next.sortField, BrandSortField.status);
    expect(next, isNot(base));
    expect(next.copyWith(page: 2).sortField, BrandSortField.status);
  });
}
