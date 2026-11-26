import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';

void main() {
  test('local filters switch the list to flat results', () {
    const query = CategoryListQuery();
    expect(query.hasActiveFilters, isFalse);
    expect(query.withStatus(CategoryStatusFilter.active).hasActiveFilters, isTrue);
    expect(query.withLevel(CategoryLevelFilter.roots).hasActiveFilters, isTrue);
    expect(query.withUsage(CategoryUsageFilter.withProducts).hasActiveFilters, isTrue);
    expect(query.withSearch('shoes').hasActiveFilters, isTrue);
  });

  test('sort alone does not turn the tree into flat results', () {
    const query = CategoryListQuery();
    final sorted = query.withSort(
      field: CategorySortField.name,
      ascending: false,
    );
    expect(sorted.hasActiveFilters, isFalse);
    expect(sorted.sortField, CategorySortField.name);
    expect(sorted.sortAscending, isFalse);
  });

  test('clear resets all local filters and sort while retaining expansion', () {
    final query = const CategoryListQuery(expandedIds: {1, 2})
        .withSearch('shoes')
        .withStatus(CategoryStatusFilter.inactive)
        .withLevel(CategoryLevelFilter.leaves)
        .withUsage(CategoryUsageFilter.withoutProducts)
        .withSort(field: CategorySortField.name, ascending: false);

    final cleared = query.cleared();
    expect(cleared.hasActiveFilters, isFalse);
    expect(cleared.status, CategoryStatusFilter.all);
    expect(cleared.level, CategoryLevelFilter.all);
    expect(cleared.usage, CategoryUsageFilter.all);
    expect(cleared.sortField, CategorySortField.sortOrder);
    expect(cleared.expandedIds, {1, 2});
  });
}
