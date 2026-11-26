import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/common_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_sets_list/option_sets_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_sets_list/option_sets_list_effect.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_stats/option_set_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/cubit/option_set_stats/option_set_stats_state.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/dialogs/option_set_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/dialogs/option_set_options_launcher.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/widgets/option_sets_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/sections/option_set_stats_section.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

const _labels = CrudLabels(
  edit: OptionSetsKeys.edit,
  delete: OptionSetsKeys.delete,
  activate: OptionSetsKeys.activate,
  deactivate: OptionSetsKeys.deactivate,
  deleteConfirmationTitle: OptionSetsKeys.delete,
  deleteConfirmationMessage: OptionSetsKeys.confirmDelete,
  deactivateConfirmationTitle: OptionSetsKeys.deactivateTitle,
  deactivateConfirmationMessage: OptionSetsKeys.deactivateMessage,
);

AppKey _selectionLabel(OptionSelectionType type) => switch (type) {
  OptionSelectionType.single => OptionSetsKeys.single,
  OptionSelectionType.multiple => OptionSetsKeys.multiple,
};

CrudListConfig<
  OptionSet,
  OptionSetListQuery,
  OptionSetsListCubit,
  OptionSetsListEffect
>
get optionSetsListConfig => CrudListConfig(
  screenId: 'catalog.option-sets',
  titleKey: OptionSetsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: OptionSetsKeys.search,
  addLabelKey: OptionSetsKeys.add,
  createCubit: () => sl<OptionSetsListCubit>(),
  rowId: (set) => set.id,
  itemLabel: (set) => set.name,
  sort: CrudSortConfig<OptionSetListQuery, OptionSetsListCubit>(
    options: OptionSetsFilterBar.sortOptions,
    current: (query) => [FilterBarSort('name', query.sortAscending)],
    tableKey: (_) => 'name',
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) {
      if (sorts.isNotEmpty) cubit.setSort(sorts.first.ascending);
    },
    applyTable: (cubit, sort) => cubit.setSort(sort.ascending),
  ),
  filterControls: (slot) => OptionSetsFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
  ),
  activeFilters: (slot) => OptionSetsFilterBar.activeFilters(
    slot.context,
    slot.state.query,
    onSearchChanged: slot.cubit.searchChanged,
    onStatusChanged: slot.cubit.setStatus,
  ),
  breadcrumb: (context) => AppBreadcrumb(
    items: [
      AppBreadcrumbItem(
        label: NavKeys.catalog,
        onTap: () => context.go(CatalogRoutes.hub.path),
      ),
      const AppBreadcrumbItem(label: OptionSetsKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards],
  capabilities: const CrudCapabilities(duplicate: false, bulkSelection: false),
  providersWrapper: (child) => BlocProvider<OptionSetStatsCubit>(
    create: (_) => sl<OptionSetStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is OptionSetsMutatedEffect,
  onMutated: (context) => context.read<OptionSetStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<OptionSetStatsCubit, OptionSetStatsState>(
    builder: (context, stats) => OptionSetStatsSection(
      stats: stats.stats,
      selectedFilter: slot.state.query.status,
      onStatusSelected: slot.cubit.setStatus,
      loading:
          stats.status == OptionSetStatsStatus.loading ||
          stats.status == OptionSetStatsStatus.initial,
      failure: stats.failure?.messageKey,
      onRetry: context.read<OptionSetStatsCubit>().refresh,
    ),
  ),
  flows: CrudFlowsConfig<OptionSet, OptionSetsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showOptionSetEditor(context, optionSet: item),
    onSaved: (cubit, {required isNew}) => cubit.onSaved(isNew: isNew),
    itemLabel: (set) => set.name,
    delete: (cubit, set) => cubit.delete(set),
    activate: (cubit, set) => cubit.activate(set.id),
    deactivate: (cubit, set) => cubit.deactivate(set.id),
    labels: _labels,
    isActive: (set) => set.isActive,
    canDelete: (set) => set.canDelete,
    hideDeleteWhenCannotDelete: true,
  ),
  dataSection: (data) =>
      CrudDataSection<OptionSet, OptionSetListQuery, OptionSetsListCubit>(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: OptionSetsKeys.optionSetName,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, set) => AppText.raw(set.name),
          ),
          DataTableColumn(
            labelKey: OptionSetsKeys.code,
            priority: DataTableColumnPriority.primary,
            cellBuilder: (_, set) => AppText.raw(set.code),
          ),
          DataTableColumn(
            labelKey: OptionSetsKeys.selectionType,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (_, set) =>
                AppText(_selectionLabel(set.selectionType)),
          ),
          DataTableColumn(
            labelKey: OptionSetsKeys.option,
            numeric: true,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, set) => AppText.raw(
              set.optionCount?.toString() ??
                  CommonKeys.noValue.tr(context: context),
            ),
          ),
          DataTableColumn(
            labelKey: OptionSetsKeys.used,
            numeric: true,
            priority: DataTableColumnPriority.secondary,
            cellBuilder: (context, set) => AppText.raw(
              set.usageCount?.toString() ??
                  CommonKeys.noValue.tr(context: context),
            ),
          ),
        ],
        labels: _labels,
        statusColumn: CrudStatusColumnConfig<OptionSet>(
          labelKey: OptionSetsKeys.status,
          isActive: (set) => set.isActive,
          badgeBuilder: (_, set) => AppText(
            set.isActive ? OptionSetsKeys.active : OptionSetsKeys.inactive,
          ),
        ),
        cardBuilder: (context, set) => _OptionSetCard(set: set),
        gridBuilder: (context, set) => _OptionSetCard(set: set),
        icon: AppIcons.catalog,
        emptyTitleKey: OptionSetsKeys.empty,
        emptyDescriptionKey: OptionSetsKeys.emptyDescription,
        noResultsTitleKey: OptionSetsKeys.noResults,
        noResultsDescriptionKey: OptionSetsKeys.noResultsDescription,
        onRowTap: (set) => showOptionSetOptions(data.context!, set),
      ),
);

class _OptionSetCard extends StatelessWidget {
  const _OptionSetCard({required this.set});
  final OptionSet set;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.raw(set.name, type: AppTextType.titleMedium),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText.raw(set.code),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(_selectionLabel(set.selectionType)),
        context.ui.spacing.gap(AppSpacing.xs),
        AppText(set.isActive ? OptionSetsKeys.active : OptionSetsKeys.inactive),
      ],
    ),
  );
}
