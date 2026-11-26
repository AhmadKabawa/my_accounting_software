import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';

void main() {
  group('UnitListQuery', () {
    test('search resets page and marks filters active', () {
      const query = UnitListQuery(page: 4);
      final updated = query.withSearch('kg');
      expect(updated.search, 'kg');
      expect(updated.page, 1);
      expect(updated.hasActiveFilters, isTrue);
    });

    test('status and type filters are cleared together', () {
      const query = UnitListQuery(
        status: UnitStatusFilter.inactive,
        type: UnitType.weight,
        page: 3,
      );
      final cleared = query.cleared();
      expect(cleared.status, UnitStatusFilter.all);
      expect(cleared.type, isNull);
      expect(cleared.page, 1);
    });

    test('sort direction is part of the server query and resets the page', () {
      const query = UnitListQuery(page: 4);
      final sorted = query.withSort(false);
      expect(sorted.sortAscending, isFalse);
      expect(sorted.page, 1);
    });

    test('changing type can explicitly clear a previous type', () {
      const query = UnitListQuery(type: UnitType.length);
      expect(query.copyWith(clearType: true).type, isNull);
    });
  });
}
