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
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material_list_query.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/cubit/materials_list_effect.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/widgets/materials_data_section.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/dialogs/materials_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/localization/materials_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

CrudListConfig<
  CatalogMaterial,
  MaterialListQuery,
  MaterialsListCubit,
  MaterialsListEffect
>
get materialsListConfig => CrudListConfig(
  screenId: 'catalog.materials',
  titleKey: MaterialsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: MaterialsKeys.searchHint,
  addLabelKey: MaterialsKeys.add,
  createCubit: () => sl<MaterialsListCubit>(),
  rowId: (e) => e.id,
  itemLabel: (e) => e.name,
  sort: CrudSortConfig<MaterialListQuery, MaterialsListCubit>(
    options: [
      FilterBarSortOption(key: 'name', label: MaterialsKeys.sortByName),
      FilterBarSortOption(key: 'code', label: MaterialsKeys.sortByCode),
      FilterBarSortOption(key: 'status', label: MaterialsKeys.sortByStatus),
    ],
    current: (q) => [
      for (final s in q.sorts) FilterBarSort(s.field.name, s.ascending),
    ],
    tableKey: (q) => q.sortField.name,
    tableAscending: (q) => q.sortAscending,
    apply: (c, s) {
      final values = <MaterialSort>[];
      for (final item in s) {
        final field = MaterialSortField.tryParse(item.key);
        if (field != null) values.add(MaterialSort(field, item.ascending));
      }
      c.setSorts(values);
    },
    applyTable: (c, s) {
      final field = MaterialSortField.tryParse(s.key);
      if (field != null) c.setSorts([MaterialSort(field, s.ascending)]);
    },
  ),
  filterControls: (slot) => [
    SearchableDropdown<MaterialStatusFilter>(
      options: const [
        MaterialStatusFilter.active,
        MaterialStatusFilter.inactive,
      ],
      labelKey: MaterialsKeys.status,
      optionLabel: (v) =>
          (v == MaterialStatusFilter.active
                  ? MaterialsKeys.active
                  : MaterialsKeys.inactive)
              .tr(context: slot.context),
      value: slot.state.query.status == MaterialStatusFilter.all
          ? null
          : slot.state.query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: MaterialsKeys.allStatuses,
      onChanged: (v) => slot.cubit.setStatus(v ?? MaterialStatusFilter.all),
    ),
    SearchableDropdown<String>(
      options: const ['natural', 'synthetic', 'blended'],
      labelKey: MaterialsKeys.type,
      optionLabel: (v) => switch (v) {
        'natural' => MaterialsKeys.natural.tr(context: slot.context),
        'synthetic' => MaterialsKeys.synthetic.tr(context: slot.context),
        _ => MaterialsKeys.blended.tr(context: slot.context),
      },
      value: slot.state.query.type,
      clearable: true,
      mode: SearchableDropdownMode.panel,
      onChanged: slot.cubit.setType,
    ),
  ],
  activeFilters: (slot) => [
    if (slot.state.query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: MaterialsKeys.searchHint,
        value: slot.state.query.search,
        onRemove: () => slot.cubit.searchChanged(''),
      ),
    if (slot.state.query.type != null)
      FilterBarFilter(
        id: 'type',
        label: MaterialsKeys.type,
        value: switch (slot.state.query.type) {
          'natural' => MaterialsKeys.natural.tr(context: slot.context),
          'synthetic' => MaterialsKeys.synthetic.tr(context: slot.context),
          _ => MaterialsKeys.blended.tr(context: slot.context),
        },
        onRemove: () => slot.cubit.setType(null),
      ),
    if (slot.state.query.status != MaterialStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: MaterialsKeys.status,
        value:
            (slot.state.query.status == MaterialStatusFilter.active
                    ? MaterialsKeys.active
                    : MaterialsKeys.inactive)
                .tr(context: slot.context),
        onRemove: () => slot.cubit.setStatus(MaterialStatusFilter.all),
      ),
  ],
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: MaterialsKeys.title),
    ],
  ),
  capabilities: const CrudCapabilities(duplicate: false, bulkSelection: true),
  isMutationEffect: (e) => e is MaterialsMutatedEffect,
  flows: CrudFlowsConfig<CatalogMaterial, MaterialsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showMaterialEditor(context, item: item, duplicate: duplicate),
    onSaved: (c, {required isNew}) => c.onSaved(isNew: isNew),
    itemLabel: (e) => e.name,
    delete: (c, e) => c.delete(e),
    activate: (c, e) => c.activate(e.id),
    deactivate: (c, e) => c.deactivate(e.id),
    labels: materialsCrudLabels,
    messageArgs: (e) => {'name': e.name},
    isActive: (e) => e.isActive,
  ),
  bulk: CrudBulkConfig<CatalogMaterial, MaterialsListCubit>(
    activateLabelKey: MaterialsKeys.bulkActivate,
    deactivateLabelKey: MaterialsKeys.bulkDeactivate,
    deleteLabelKey: MaterialsKeys.bulkDelete,
    deactivateTitleKey: MaterialsKeys.bulkDeactivateTitle,
    deactivateMessageKey: MaterialsKeys.bulkDeactivateMessage,
    deleteTitleKey: MaterialsKeys.bulkDeleteTitle,
    deleteMessageKey: MaterialsKeys.bulkDeleteMessage,
    activate: (c, items) => c.bulkActivate(items),
    deactivate: (c, items) => c.bulkDeactivate(items),
    delete: (c, items) => c.bulkDelete(items),
  ),
  dataSection: buildMaterialsDataSection,
);
