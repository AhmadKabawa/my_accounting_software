import 'package:accounting_software/app/features/catalog/age_groups/domain/entity/age_group_list_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search and status changes reset page and clear all filters', () {
    const q = AgeGroupListQuery(page: 4, pageSize: 10);
    final searched = q.withSearch('Kids');
    expect(searched.page, 1);
    expect(searched.hasActiveFilters, isTrue);
    final filtered = searched.withStatus(AgeGroupStatusFilter.inactive);
    expect(filtered.page, 1);
    expect(filtered.status, AgeGroupStatusFilter.inactive);
    final cleared = filtered.cleared();
    expect(cleared.search, isEmpty);
    expect(cleared.status, AgeGroupStatusFilter.all);
    expect(cleared.hasActiveFilters, isFalse);
  });
  test('sort changes are stable and reset pagination', () {
    const q = AgeGroupListQuery(page: 3);
    final sorted = q.withSort(AgeGroupSortField.name, false);
    expect(sorted.page, 1);
    expect(sorted.sortField, AgeGroupSortField.name);
    expect(sorted.sortAscending, isFalse);
    expect(sorted.withSort(AgeGroupSortField.name, false), same(sorted));
  });
}
