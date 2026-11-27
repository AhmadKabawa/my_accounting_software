import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/genders_list_config.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';

void main() {
  group('gendersListConfig', () {
    test('uses the shared CRUD engine and expected access and view modes', () {
      final config = gendersListConfig;

      expect(config.screenId, 'catalog.genders');
      expect(config.manageAccess, Permissions.masterData.manage);
      expect(config.viewModes, [AppViewMode.table, AppViewMode.cards]);
      expect(config.capabilities.showCount, isTrue);
      expect(config.capabilities.bulkSelection, isTrue);
    });

    test('wires feature-owned search, status, sorting, stats and providers', () {
      final config = gendersListConfig;

      expect(config.sort.options.map((option) => option.key), [
        'order',
        'name',
        'code',
      ]);
      expect(config.filterControls, isNotNull);
      expect(config.activeFilters, isNotNull);
      expect(config.statsBuilder, isNotNull);
      expect(config.providersWrapper, isNotNull);
      expect(config.isMutationEffect, isNotNull);
      expect(config.onMutated, isNotNull);
    });

    test('wires create, edit, delete, status and bulk flows', () {
      final config = gendersListConfig;

      expect(config.flows, isNotNull);
      expect(config.flows!.showEditor, isNotNull);
      expect(config.flows!.onSaved, isNotNull);
      expect(config.flows!.delete, isNotNull);
      expect(config.flows!.activate, isNotNull);
      expect(config.flows!.deactivate, isNotNull);
      expect(config.flows!.canDelete, isNotNull);
      expect(config.bulk, isNotNull);
      expect(config.bulk!.activate, isNotNull);
      expect(config.bulk!.deactivate, isNotNull);
      expect(config.bulk!.delete, isNotNull);
      expect(config.bulk!.activateLabelKey, GendersKeys.bulkActivate);
      expect(config.bulk!.deactivateLabelKey, GendersKeys.bulkDeactivate);
      expect(config.bulk!.deleteLabelKey, GendersKeys.bulkDelete);
    });

    test('provides a data section with status and responsive card/grid builders', () {
      expect(gendersListConfig.dataSection, isNotNull);
    });
  });
}
