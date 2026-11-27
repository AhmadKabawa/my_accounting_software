import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenderListQuery', () {
    test('search resets pagination and is an active filter', () {
      const query = GenderListQuery(page: 4, pageSize: 10);
      final searched = query.withSearch('Women');
      expect(searched.search, 'Women');
      expect(searched.page, 1);
      expect(searched.hasActiveFilters, isTrue);
    });

    test('status filter resets pagination and clear removes it', () {
      const query = GenderListQuery(page: 3);
      final filtered = query.withStatus(GenderStatusFilter.inactive);
      expect(filtered.page, 1);
      expect(filtered.hasActiveFilters, isTrue);
      final cleared = filtered.cleared();
      expect(cleared.status, GenderStatusFilter.all);
      expect(cleared.search, isEmpty);
      expect(cleared.hasActiveFilters, isFalse);
    });

    test('sort criteria are retained in priority order', () {
      const query = GenderListQuery();
      final sorted = query.withSorts(const [
        GenderSort(GenderSortField.code, false),
        GenderSort(GenderSortField.name, true),
      ]);
      expect(sorted.sorts, const [
        GenderSort(GenderSortField.code, false),
        GenderSort(GenderSortField.name, true),
      ]);
      expect(sorted.withSorts(sorted.sorts), same(sorted));
    });
  });
}
