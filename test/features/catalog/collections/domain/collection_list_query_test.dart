import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';

void main() {
  group('CollectionListQuery', () {
    test('defaults to name ordering and no filters', () {
      const query = CollectionListQuery();
      expect(query.sortField, CollectionSortField.name);
      expect(query.hasActiveFilters, isFalse);
    });

    test('search resets page', () {
      const query = CollectionListQuery(page: 3);
      final next = query.withSearch('capsule');
      expect(next.search, 'capsule');
      expect(next.page, 1);
      expect(next.hasActiveFilters, isTrue);
    });

    test('cleared removes filters and preserves name ordering', () {
      const query = CollectionListQuery(
        search: 'capsule',
        status: CollectionStatusFilter.inactive,
        sortAscending: false,
        page: 4,
      );
      final cleared = query.cleared();
      expect(cleared.search, isEmpty);
      expect(cleared.status, CollectionStatusFilter.all);
      expect(cleared.sortField, CollectionSortField.name);
      expect(cleared.sortAscending, isFalse);
      expect(cleared.page, 1);
    });
  });
}
