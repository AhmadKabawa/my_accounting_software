import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';

void main() {
  group('FabricTypeListQuery', () {
    test('search resets page and activates filters', () {
      const query = FabricTypeListQuery(page: 4);
      final next = query.withSearch('rib');
      expect(next.search, 'rib');
      expect(next.page, 1);
      expect(next.hasActiveFilters, isTrue);
    });

    test('clear resets search/status/category and page', () {
      const query = FabricTypeListQuery(
        search: 'rib',
        status: FabricTypeStatusFilter.inactive,
        category: 'knit',
        page: 3,
      );
      final cleared = query.cleared();
      expect(cleared.search, isEmpty);
      expect(cleared.status, FabricTypeStatusFilter.all);
      expect(cleared.category, isNull);
      expect(cleared.page, 1);
      expect(cleared.hasActiveFilters, isFalse);
    });

    test('page changes preserve filters', () {
      const query = FabricTypeListQuery(search: 'rib', category: 'knit');
      final next = query.withPage(2);
      expect(next.search, query.search);
      expect(next.category, query.category);
      expect(next.page, 2);
    });

    test('preserves ordered multi-sort criteria', () {
      const query = FabricTypeListQuery();
      final sorted = query.withSorts(const [
        FabricTypeSort(FabricTypeSortField.code, false),
        FabricTypeSort(FabricTypeSortField.name, true),
      ]);
      expect(sorted.sorts, const [
        FabricTypeSort(FabricTypeSortField.code, false),
        FabricTypeSort(FabricTypeSortField.name, true),
      ]);
      expect(sorted.page, 1);
    });

    test('sort field parser accepts known fields only', () {
      expect(FabricTypeSortField.tryParse('code'), FabricTypeSortField.code);
      expect(FabricTypeSortField.tryParse('not-a-field'), isNull);
    });
  });
}
