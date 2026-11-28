import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';

void main() {
  group('SeasonListQuery', () {
    test('defaults to start date ordering and no filters', () {
      const query = SeasonListQuery();
      expect(query.sortField, SeasonSortField.startDate);
      expect(query.sortAscending, isTrue);
      expect(query.hasActiveFilters, isFalse);
    });

    test('search resets page and marks filters active', () {
      const query = SeasonListQuery(page: 3);
      final next = query.withSearch('summer');
      expect(next.search, 'summer');
      expect(next.page, 1);
      expect(next.hasActiveFilters, isTrue);
    });

    test('cleared resets search, status and type but preserves sort', () {
      const query = SeasonListQuery(
        search: 'winter',
        status: SeasonStatusFilter.inactive,
        type: 'winter',
        sortField: SeasonSortField.name,
        sortAscending: false,
        page: 4,
      );
      final cleared = query.cleared();
      expect(cleared.search, isEmpty);
      expect(cleared.status, SeasonStatusFilter.all);
      expect(cleared.type, isNull);
      expect(cleared.sortField, SeasonSortField.name);
      expect(cleared.sortAscending, isFalse);
      expect(cleared.page, 1);
    });
  });
}
