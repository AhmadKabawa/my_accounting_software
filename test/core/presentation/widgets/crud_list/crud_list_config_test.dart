import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar_sort.dart';

void main() {
  group('CrudCapabilities', () {
    test('uses safe shared defaults', () {
      const capabilities = CrudCapabilities();

      expect(capabilities.showCount, isTrue);
      expect(capabilities.duplicate, isTrue);
      expect(capabilities.bulkSelection, isTrue);
    });

    test('allows features to opt out independently', () {
      const capabilities = CrudCapabilities(
        showCount: false,
        duplicate: false,
        bulkSelection: false,
      );

      expect(capabilities.showCount, isFalse);
      expect(capabilities.duplicate, isFalse);
      expect(capabilities.bulkSelection, isFalse);
    });
  });

  group('CrudSortConfig', () {
    test('forwards table sort values to the feature adapter', () {
      DataTableSort? applied;
      final config = CrudSortConfig<int, String>(
        current: (_) => const [],
        tableKey: (_) => null,
        tableAscending: (_) => true,
        apply: (_, _) {},
        applyTable: (_, sort) => applied = sort,
      );

      config.applyTable('feature-cubit', const DataTableSort('name', false));

      expect(applied?.key, 'name');
      expect(applied?.ascending, isFalse);
    });

    test('exposes the feature query sort projection', () {
      final config = CrudSortConfig<int, String>(
        current: (query) => [FilterBarSort('field-$query', true)],
        tableKey: (query) => 'table-$query',
        tableAscending: (_) => false,
        apply: (_, _) {},
        applyTable: (_, _) {},
      );

      expect(config.current(3).single.key, 'field-3');
      expect(config.tableKey(3), 'table-3');
      expect(config.tableAscending(3), isFalse);
    });
  });
}
