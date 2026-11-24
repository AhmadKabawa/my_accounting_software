import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/brands_list_config.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/pages/brands_screen.dart';

void main() {
  group('brandsListConfig', () {
    test('keeps the screen identity, permission and presentation modes', () {
      final config = brandsListConfig;

      expect(config.screenId, 'catalog.brands');
      expect(BrandsScreen.screenId, config.screenId);
      expect(config.manageAccess, Permissions.masterData.manage);
      expect(config.viewModes, [
        AppViewMode.table,
        AppViewMode.cards,
        AppViewMode.grid,
      ]);
      expect(config.capabilities.showCount, isFalse);
      expect(config.capabilities.duplicate, isTrue);
      expect(config.capabilities.bulkSelection, isTrue);
    });

    test('wires feature-owned filters, sorting, stats and providers', () {
      final config = brandsListConfig;

      expect(config.sort.options.map((option) => option.key), [
        'name',
        'newest',
        'updated',
        'status',
      ]);
      expect(config.filterControls, isNotNull);
      expect(config.activeFilters, isNotNull);
      expect(config.statsBuilder, isNotNull);
      expect(config.providersWrapper, isNotNull);
      expect(config.isMutationEffect, isNotNull);
      expect(config.onMutated, isNotNull);
    });

    test('wires record flows and all three bulk mutations', () {
      final config = brandsListConfig;

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
      expect(config.bulk!.activateLabelKey, BrandsKeys.bulkActivate);
      expect(config.bulk!.deactivateLabelKey, BrandsKeys.bulkDeactivate);
      expect(config.bulk!.deleteLabelKey, BrandsKeys.bulkDelete);
    });

    test('retains the feature-owned data section builder', () {
      expect(brandsListConfig.dataSection, isNotNull);
    });
  });
}
