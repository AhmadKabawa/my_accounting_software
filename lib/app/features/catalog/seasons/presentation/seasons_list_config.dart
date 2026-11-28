import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season.dart';
import 'package:accounting_software/app/features/catalog/seasons/domain/entity/season_list_query.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/cubit/seasons_list_effect.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/widgets/seasons_data_section.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/dialogs/seasons_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/seasons/presentation/localization/seasons_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

CrudListConfig<
  CatalogSeason,
  SeasonListQuery,
  SeasonsListCubit,
  SeasonsListEffect
>
get seasonsListConfig => CrudListConfig(
  screenId: 'catalog.seasons',
  titleKey: SeasonsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: SeasonsKeys.searchHint,
  addLabelKey: SeasonsKeys.add,
  createCubit: () => sl<SeasonsListCubit>(),
  rowId: (e) => e.id,
  itemLabel: (e) => e.name,
  sort: CrudSortConfig<SeasonListQuery, SeasonsListCubit>(
    options: [
      FilterBarSortOption(key: 'startDate', label: SeasonsKeys.sortByStartDate),
    ],
    current: (q) => [
      for (final s in q.sorts) FilterBarSort(s.field.name, s.ascending),
    ],
    tableKey: (q) => q.sortField.name,
    tableAscending: (q) => q.sortAscending,
    apply: (c, s) {
      final values = <SeasonSort>[];
      for (final item in s) {
        final field = SeasonSortField.tryParse(item.key);
        if (field != null) values.add(SeasonSort(field, item.ascending));
      }
      c.setSorts(values);
    },
    applyTable: (c, s) {
      final field = SeasonSortField.tryParse(s.key);
      if (field != null) c.setSorts([SeasonSort(field, s.ascending)]);
    },
  ),
  filterControls: (slot) => [
    SearchableDropdown<SeasonStatusFilter>(
      options: const [SeasonStatusFilter.active, SeasonStatusFilter.inactive],
      labelKey: SeasonsKeys.status,
      optionLabel: (v) =>
          (v == SeasonStatusFilter.active
                  ? SeasonsKeys.active
                  : SeasonsKeys.inactive)
              .tr(context: slot.context),
      value: slot.state.query.status == SeasonStatusFilter.all
          ? null
          : slot.state.query.status,
      clearable: false,
      mode: SearchableDropdownMode.panel,
      allOptionLabel: SeasonsKeys.allStatuses,
      onChanged: (v) => slot.cubit.setStatus(v ?? SeasonStatusFilter.all),
    ),
    SearchableDropdown<String>(
      options: const ['summer', 'winter', 'spring', 'autumn'],
      labelKey: SeasonsKeys.type,
      optionLabel: (v) => switch (v) {
        'summer' => SeasonsKeys.summer.tr(context: slot.context),
        'winter' => SeasonsKeys.winter.tr(context: slot.context),
        'spring' => SeasonsKeys.spring.tr(context: slot.context),
        _ => SeasonsKeys.autumn.tr(context: slot.context),
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
        label: SeasonsKeys.searchHint,
        value: slot.state.query.search,
        onRemove: () => slot.cubit.searchChanged(''),
      ),
    if (slot.state.query.type != null)
      FilterBarFilter(
        id: 'type',
        label: SeasonsKeys.type,
        value: switch (slot.state.query.type) {
          'summer' => SeasonsKeys.summer.tr(context: slot.context),
          'winter' => SeasonsKeys.winter.tr(context: slot.context),
          'spring' => SeasonsKeys.spring.tr(context: slot.context),
          _ => SeasonsKeys.autumn.tr(context: slot.context),
        },
        onRemove: () => slot.cubit.setType(null),
      ),
    if (slot.state.query.status != SeasonStatusFilter.all)
      FilterBarFilter(
        id: 'status',
        label: SeasonsKeys.status,
        value:
            (slot.state.query.status == SeasonStatusFilter.active
                    ? SeasonsKeys.active
                    : SeasonsKeys.inactive)
                .tr(context: slot.context),
        onRemove: () => slot.cubit.setStatus(SeasonStatusFilter.all),
      ),
  ],
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: SeasonsKeys.title),
    ],
  ),
  capabilities: const CrudCapabilities(duplicate: false, bulkSelection: false),
  isMutationEffect: (e) => e is SeasonsMutatedEffect,
  flows: CrudFlowsConfig<CatalogSeason, SeasonsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showSeasonEditor(context, item: item, duplicate: duplicate),
    onSaved: (c, {required isNew}) => c.onSaved(isNew: isNew),
    itemLabel: (e) => e.name,
    delete: (c, e) => c.delete(e),
    activate: (c, e) => c.activate(e.id),
    deactivate: (c, e) => c.deactivate(e.id),
    labels: seasonsCrudLabels,
    messageArgs: (e) => {'name': e.name},
    isActive: (e) => e.isActive,
  ),
  dataSection: buildSeasonsDataSection,
);
