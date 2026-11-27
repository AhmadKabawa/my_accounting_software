import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/domain/entity/size_group_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/datasources/sizes_remote_data_source_impl.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/domain/entity/catalog_size_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';

void main() {
  group('SizeSystemListQuery', () {
    test('defaults: name ascending, page 1, no filters', () {
      const query = SizeSystemListQuery();
      expect(query.sortField, SizeSystemSortField.name);
      expect(query.sortAscending, isTrue);
      expect(query.page, 1);
      expect(query.hasActiveFilters, isFalse);
    });

    test('search and status reset the page and mark filters active', () {
      final query = const SizeSystemListQuery(page: 4)
          .withSearch('eu')
          .withStatus(SizeStatusFilter.active);
      expect(query.page, 1);
      expect(query.hasActiveFilters, isTrue);
      expect(query.cleared().hasActiveFilters, isFalse);
    });
  });

  group('SizeGroupListQuery', () {
    test('is always scoped to its system, even after clearing', () {
      final query = const SizeGroupListQuery(sizeSystemId: 9)
          .withSearch('men')
          .withGender(2);
      expect(query.hasActiveFilters, isTrue);
      final cleared = query.cleared();
      expect(cleared.sizeSystemId, 9);
      expect(cleared.genderId, isNull);
      expect(cleared.search, isEmpty);
    });

    test('withGender(null) removes the gender filter', () {
      final query = const SizeGroupListQuery(sizeSystemId: 1)
          .withGender(3)
          .withGender(null);
      expect(query.genderId, isNull);
    });

    test('changing the gender goes back to page 1', () {
      final query = const SizeGroupListQuery(
        sizeSystemId: 1,
        page: 3,
      ).withGender(2);
      expect(query.page, 1);
    });
  });

  group('CatalogSizeListQuery and ordering', () {
    test('is scoped to its group and sorts by the natural order by default', () {
      const query = CatalogSizeListQuery(sizeGroupId: 4);
      expect(query.sizeGroupId, 4);
      expect(
        SizesRemoteDataSourceImpl.order(query),
        'sort_order.asc,numeric_value.asc.nullslast,id.asc',
      );
    });

    test('other sorts keep id as the tie-breaker', () {
      const query = CatalogSizeListQuery(sizeGroupId: 4);
      expect(
        SizesRemoteDataSourceImpl.order(
          query.withSort(CatalogSizeSortField.name, false),
        ),
        'name.desc,id.asc',
      );
      expect(
        SizesRemoteDataSourceImpl.order(
          query.withSort(CatalogSizeSortField.value, true),
        ),
        'numeric_value.asc.nullslast,id.asc',
      );
    });
  });
}
