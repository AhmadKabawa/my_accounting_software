import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/cubit/fabric_types_list_effect.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/widgets/fabric_types_data_section.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/dialogs/fabric_types_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/localization/fabric_types_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

CrudListConfig<
  CatalogFabricType,
  FabricTypeListQuery,
  FabricTypesListCubit,
  FabricTypesListEffect
>
get fabricTypesListConfig => CrudListConfig(
  screenId: 'catalog.fabric_types',
  titleKey: FabricTypesKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: FabricTypesKeys.searchHint,
  addLabelKey: FabricTypesKeys.add,
  createCubit: () => sl<FabricTypesListCubit>(),
  rowId: (e) => e.id,
  itemLabel: (e) => e.name,
  sort: CrudSortConfig<FabricTypeListQuery, FabricTypesListCubit>(
    options: [
      FilterBarSortOption(key: 'name', label: FabricTypesKeys.sortByName),
      FilterBarSortOption(key: 'code', label: FabricTypesKeys.sortByCode),
      FilterBarSortOption(key: 'status', label: FabricTypesKeys.sortByStatus),
    ],
    current: (q) => [
      for (final s in q.sorts) FilterBarSort(s.field.name, s.ascending),
    ],
    tableKey: (q) => q.sortField.name,
    tableAscending: (q) => q.sortAscending,
    apply: (c, s) {
      final values = <FabricTypeSort>[];
      for (final item in s) {
        final field = FabricTypeSortField.tryParse(item.key);
        if (field != null) values.add(FabricTypeSort(field, item.ascending));
      }
      c.setSorts(values);
    },
    applyTable: (c, s) {
      final field = FabricTypeSortField.tryParse(s.key);
      if (field != null) c.setSorts([FabricTypeSort(field, s.ascending)]);
    },
  ),
  filterControls: (slot) => [
    SearchableDropdown<FabricTypeStatusFilter>(
      options: const [
        FabricTypeStatusFilter.active,
        FabricTypeStatusFilter.inactive,
      ],
      labelKey: FabricTypesKeys.status,
      optionLabel: (v) =>
          (v == FabricTypeStatusFilter.active
                  ? FabricTypesKeys.active
                  : FabricTypesKeys.inactive)
              .tr(context: slot.context),
      value: slot.state.query.status == FabricTypeStatusFilter.all
          ? null
          : slot.state.query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: FabricTypesKeys.allStatuses,
      onChanged: (v) => slot.cubit.setStatus(v ?? FabricTypeStatusFilter.all),
    ),
    SearchableDropdown<FabricCategory>(
      options: FabricCategory.values,
      labelKey: FabricTypesKeys.category,
      optionLabel: (v) => _fabricCategoryLabel(v).tr(context: slot.context),
      value: FabricCategory.tryParse(slot.state.query.category),
      clearable: true,
      mode: SearchableDropdownMode.panel,
      onChanged: (value) => slot.cubit.setCategory(value?.name),
    ),
  ],
  activeFilters: (slot) => [
    if (slot.state.query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: FabricTypesKeys.searchHint,
        value: slot.state.query.search,
        onRemove: () => slot.cubit.searchChanged(''),
      ),
    if (slot.state.query.category != null)
      FilterBarFilter(
        id: 'category',
        label: FabricTypesKeys.category,
        value: _fabricCategoryLabel(
          FabricCategory.tryParse(slot.state.query.category),
        ).tr(context: slot.context),
        onRemove: () => slot.cubit.setCategory(null),
      ),
    if (slot.state.query.status != FabricTypeStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: FabricTypesKeys.status,
        value:
            (slot.state.query.status == FabricTypeStatusFilter.active
                    ? FabricTypesKeys.active
                    : FabricTypesKeys.inactive)
                .tr(context: slot.context),
        onRemove: () => slot.cubit.setStatus(FabricTypeStatusFilter.all),
      ),
  ],
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: FabricTypesKeys.title),
    ],
  ),
  capabilities: const CrudCapabilities(duplicate: false, bulkSelection: true),
  isMutationEffect: (e) => e is FabricTypesMutatedEffect,
  flows: CrudFlowsConfig<CatalogFabricType, FabricTypesListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showFabricTypeEditor(context, item: item, duplicate: duplicate),
    onSaved: (c, {required isNew}) => c.onSaved(isNew: isNew),
    itemLabel: (e) => e.name,
    delete: (c, e) => c.delete(e),
    activate: (c, e) => c.activate(e.id),
    deactivate: (c, e) => c.deactivate(e.id),
    labels: fabricTypesCrudLabels,
    messageArgs: (e) => {'name': e.name},
    isActive: (e) => e.isActive,
  ),
  bulk: CrudBulkConfig<CatalogFabricType, FabricTypesListCubit>(
    activateLabelKey: FabricTypesKeys.bulkActivate,
    deactivateLabelKey: FabricTypesKeys.bulkDeactivate,
    deleteLabelKey: FabricTypesKeys.bulkDelete,
    deactivateTitleKey: FabricTypesKeys.bulkDeactivateTitle,
    deactivateMessageKey: FabricTypesKeys.bulkDeactivateMessage,
    deleteTitleKey: FabricTypesKeys.bulkDeleteTitle,
    deleteMessageKey: FabricTypesKeys.bulkDeleteMessage,
    activate: (c, items) => c.bulkActivate(items),
    deactivate: (c, items) => c.bulkDeactivate(items),
    delete: (c, items) => c.bulkDelete(items),
  ),
  dataSection: buildFabricTypesDataSection,
);


AppKey _fabricCategoryLabel(FabricCategory? category) => switch (category) {
  FabricCategory.knit => FabricTypesKeys.knit,
  FabricCategory.woven => FabricTypesKeys.woven,
  FabricCategory.fleece => FabricTypesKeys.fleece,
  null => FabricTypesKeys.notSpecified,
};
