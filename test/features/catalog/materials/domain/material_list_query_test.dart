import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';

void main() {
  group('MaterialListQuery', () {
    test('search resets page and activates filters', () {
      const query = MaterialListQuery(page: 4);
      final next = query.withSearch('cotton');
      expect(next.search, 'cotton');
      expect(next.page, 1);
      expect(next.hasActiveFilters, isTrue);
    });

    test('clear resets search/status/type and page', () {
      const query = MaterialListQuery(
        search: 'cotton',
        status: MaterialStatusFilter.inactive,
        type: 'natural',
        page: 3,
      );
      final cleared = query.cleared();
      expect(cleared.search, isEmpty);
      expect(cleared.status, MaterialStatusFilter.all);
      expect(cleared.type, isNull);
      expect(cleared.page, 1);
      expect(cleared.hasActiveFilters, isFalse);
    });

    test('page changes preserve filters', () {
      const query = MaterialListQuery(search: 'wool', type: 'natural');
      final next = query.withPage(2);
      expect(next.search, query.search);
      expect(next.type, query.type);
      expect(next.page, 2);
    });

    test('sort field parser accepts known fields only', () {
      expect(MaterialSortField.tryParse('code'), MaterialSortField.code);
      expect(MaterialSortField.tryParse('not-a-field'), isNull);
    });
  });
}
