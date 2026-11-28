import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/routing/size_systems_routes.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_breadcrumbs.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_list_cells.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/widgets/size_status_badge.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_list_query.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_stats/size_system_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_system_stats/size_system_stats_state.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_systems_list/size_systems_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/cubit/size_systems_list/size_systems_list_effect.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/dialogs/size_system_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/presentation/widgets/size_system_stats_bar.dart';

const _labels = CrudLabels(
  edit: SizeSystemsKeys.edit,
  delete: SizeSystemsKeys.delete,
  activate: SizeSystemsKeys.activate,
  deactivate: SizeSystemsKeys.deactivate,
  deleteConfirmationTitle: SizeSystemsKeys.deleteTitle,
  deleteConfirmationMessage: SizeSystemsKeys.deleteMessage,
  deactivateConfirmationTitle: SizeSystemsKeys.deactivateTitle,
  deactivateConfirmationMessage: SizeSystemsKeys.deactivateMessage,
);

void _openGroups(BuildContext? context, SizeSystem system) {
  if (context == null) return;
  context.go(
    SizeSystemsRoutes.groups(system.id),
    extra: SizeRouteContext(systemName: system.name),
  );
}

CrudListConfig<
  SizeSystem,
  SizeSystemListQuery,
  SizeSystemsListCubit,
  SizeSystemsListEffect
>
get sizeSystemsListConfig => CrudListConfig(
  screenId: 'catalog.sizeSystems',
  titleKey: SizeSystemsKeys.systemsTitle,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: SizeSystemsKeys.searchHint,
  addLabelKey: SizeSystemsKeys.addSystem,
  createCubit: () => sl<SizeSystemsListCubit>(),
  rowId: (system) => system.id,
  itemLabel: (system) => system.name,
  sort: CrudSortConfig<SizeSystemListQuery, SizeSystemsListCubit>(
    options: SizeFilterBar.systemSortOptions,
    maxSorts: 1,
    current: (query) => [
      FilterBarSort(query.sortField.name, query.sortAscending),
    ],
    tableKey: (query) => query.sortField.name,
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) {
      if (sorts.isEmpty) return;
      final field = SizeSystemSortField.tryParse(sorts.first.key);
      if (field != null) cubit.setSort(field, sorts.first.ascending);
    },
    applyTable: (cubit, sort) {
      final field = SizeSystemSortField.tryParse(sort.key);
      if (field != null) cubit.setSort(field, sort.ascending);
    },
  ),
  filterControls: (slot) => [
    SizeFilterBar.statusControl(
      slot.context,
      slot.state.query.status,
      slot.cubit.setStatus,
    ),
  ],
  activeFilters: (slot) => SizeFilterBar.activeFilters(
    slot.context,
    search: slot.state.query.search,
    status: slot.state.query.status,
    onSearchChanged: slot.cubit.searchChanged,
    onStatusChanged: slot.cubit.setStatus,
  ),
  breadcrumb: systemsBreadcrumb,
  viewModes: const [AppViewMode.table, AppViewMode.cards],
  capabilities: const CrudCapabilities(
    showCount: true,
    duplicate: false,
    bulkSelection: false,
  ),
  providersWrapper: (child) => BlocProvider<SizeSystemStatsCubit>(
    create: (_) => sl<SizeSystemStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is SizeSystemsMutatedEffect,
  onMutated: (context) => context.read<SizeSystemStatsCubit>().refresh(),
  statsBuilder: (slot) =>
      BlocBuilder<SizeSystemStatsCubit, SizeSystemStatsState>(
        builder: (context, state) => SizeSystemStatsBar(
          state.stats,
          selected: slot.state.query.status,
          loading:
              state.status == SizeSystemStatsStatus.initial ||
              state.status == SizeSystemStatsStatus.loading,
          onSelected: slot.cubit.setStatus,
        ),
      ),
  flows: CrudFlowsConfig<SizeSystem, SizeSystemsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showSizeSystemEditor(context, system: item),
    onSaved: (cubit, {required isNew}) => cubit.onSaved(isNew: isNew),
    itemLabel: (system) => system.name,
    delete: (cubit, system) => cubit.delete(system),
    activate: (cubit, system) => cubit.activate(system.id),
    deactivate: (cubit, system) => cubit.deactivate(system.id),
    labels: _labels,
    isActive: (system) => system.isActive,
    canDelete: (system) => system.canDelete,
    hideDeleteWhenCannotDelete: true,
  ),
  dataSection: (data) =>
      CrudDataSection<SizeSystem, SizeSystemListQuery, SizeSystemsListCubit>(
        data: data,
        onRowTap: (system) => _openGroups(data.context, system),
        extraRowActions: (context, system) => [
          AppRowAction(
            icon: AppIcons.catalog,
            labelKey: SizeSystemsKeys.openGroups,
            onPressed: () => _openGroups(context, system),
          ),
        ],
        columns: [
          DataTableColumn(
            labelKey: SizeSystemsKeys.nameField,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, system) => AppText.raw(system.name),
          ),
          DataTableColumn(
            labelKey: SizeSystemsKeys.code,
            sortKey: 'code',
            priority: DataTableColumnPriority.secondary,
            flex: 2,
            cellBuilder: (_, system) => SizeCodeText(system.code),
          ),
          DataTableColumn(
            labelKey: SizeSystemsKeys.groupCount,
            numeric: true,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (_, system) => SizeCountText(system.groupCount),
          ),
          DataTableColumn(
            labelKey: SizeSystemsKeys.updatedAt,
            sortKey: 'updated',
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (_, system) =>
                AppText.raw(formatSizeDate(system.updatedAt)),
          ),
        ],
        labels: _labels,
        statusColumn: CrudStatusColumnConfig<SizeSystem>(
          labelKey: SizeSystemsKeys.status,
          isActive: (system) => system.isActive,
          badgeBuilder: (_, system) =>
              SizeStatusBadge(isActive: system.isActive),
        ),
        cardBuilder: _card,
        gridBuilder: _card,
        icon: AppIcons.catalog,
        emptyTitleKey: SizeSystemsKeys.emptySystems,
        emptyDescriptionKey: SizeSystemsKeys.addSystem,
        noResultsTitleKey: SizeSystemsKeys.noResults,
        noResultsDescriptionKey: SizeSystemsKeys.noResults,
      ),
);

Widget _card(BuildContext context, SizeSystem system) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText.raw(system.name, type: AppTextType.titleMedium),
    SizeCodeText(system.code),
    SizeCountText(system.groupCount),
    SizeStatusBadge(isActive: system.isActive),
  ],
);
