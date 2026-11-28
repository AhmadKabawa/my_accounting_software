import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection.dart';
import 'package:accounting_software/app/features/catalog/collections/domain/entity/collection_list_query.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/cubit/collections_list_effect.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/widgets/collections_data_section.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/dialogs/collections_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/collections/presentation/localization/collections_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

CrudListConfig<CatalogCollection, CollectionListQuery, CollectionsListCubit, CollectionsListEffect>
get collectionsListConfig => CrudListConfig(
  screenId: 'catalog.collections',
  titleKey: CollectionsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: CollectionsKeys.searchHint,
  addLabelKey: CollectionsKeys.add,
  createCubit: () => sl<CollectionsListCubit>(),
  rowId: (e) => e.id,
  itemLabel: (e) => e.name,
  sort: CrudSortConfig<CollectionListQuery, CollectionsListCubit>(
    options: [
      FilterBarSortOption(key: 'name', label: CollectionsKeys.sortByName),
    ],
    current: (q) => [
      for (final s in q.sorts) FilterBarSort(s.field.name, s.ascending),
    ],
    tableKey: (q) => q.sortField.name,
    tableAscending: (q) => q.sortAscending,
    apply: (c, s) {
      final values = <CollectionSort>[];
      for (final item in s) {
        final field = CollectionSortField.tryParse(item.key);
        if (field != null) values.add(CollectionSort(field, item.ascending));
      }
      c.setSorts(values);
    },
    applyTable: (c, s) {
      final field = CollectionSortField.tryParse(s.key);
      if (field != null) c.setSorts([CollectionSort(field, s.ascending)]);
    },
  ),
  filterControls: (slot) => [
    SearchableDropdown<CollectionStatusFilter>(
      options: const [CollectionStatusFilter.active, CollectionStatusFilter.inactive],
      labelKey: CollectionsKeys.status,
      optionLabel: (v) => (v == CollectionStatusFilter.active
          ? CollectionsKeys.active
          : CollectionsKeys.inactive).tr(context: slot.context),
      value: slot.state.query.status == CollectionStatusFilter.all
          ? null
          : slot.state.query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: CollectionsKeys.allStatuses,
      onChanged: (v) => slot.cubit.setStatus(v ?? CollectionStatusFilter.all),
    ),
  ],
  activeFilters: (slot) => [
    if (slot.state.query.search.isNotEmpty)
      FilterBarFilter(
        id: FilterBar.searchFilterId,
        label: CollectionsKeys.searchHint,
        value: slot.state.query.search,
        onRemove: () => slot.cubit.searchChanged(''),
      ),
    if (slot.state.query.status != CollectionStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: CollectionsKeys.status,
        value: (slot.state.query.status == CollectionStatusFilter.active
            ? CollectionsKeys.active
            : CollectionsKeys.inactive).tr(context: slot.context),
        onRemove: () => slot.cubit.setStatus(CollectionStatusFilter.all),
      ),
  ],
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: CollectionsKeys.title),
    ],
  ),
  capabilities: const CrudCapabilities(duplicate: false, bulkSelection: false),
  isMutationEffect: (e) => e is CollectionsMutatedEffect,
  flows: CrudFlowsConfig<CatalogCollection, CollectionsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showCollectionEditor(context, item: item, duplicate: duplicate),
    onSaved: (c, {required isNew}) => c.onSaved(isNew: isNew),
    itemLabel: (e) => e.name,
    delete: (c, e) => c.delete(e),
    activate: (c, e) => c.activate(e.id),
    deactivate: (c, e) => c.deactivate(e.id),
    labels: collectionsCrudLabels,
    messageArgs: (e) => {'name': e.name},
    isActive: (e) => e.isActive,
  ),
  dataSection: buildCollectionsDataSection,
);
