import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_stats/sport_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sport_stats/sport_stats_state.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sports_list/sports_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/cubit/sports_list/sports_list_effect.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/dialogs/sport_editor_launcher.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/sections/sport_stats_section.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_card.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_grid_tile.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_identity.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_status_badge.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sports_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';

const _crudLabels = CrudLabels(
  edit: SportsKeys.edit,
  delete: SportsKeys.delete,
  duplicate: SportsKeys.duplicate,
  activate: SportsKeys.activate,
  deactivate: SportsKeys.deactivate,
  deleteConfirmationTitle: SportsKeys.deleteTitle,
  deleteConfirmationMessage: SportsKeys.deleteMessage,
  deactivateConfirmationTitle: SportsKeys.deactivateTitle,
  deactivateConfirmationMessage: SportsKeys.deactivateMessage,
);

CrudListConfig<Sport, SportListQuery, SportsListCubit, SportsListEffect>
get sportsListConfig => CrudListConfig(
  screenId: 'catalog.sports',
  titleKey: SportsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: SportsKeys.searchHint,
  addLabelKey: SportsKeys.add,
  createCubit: () => sl<SportsListCubit>(),
  rowId: (sport) => sport.id,
  itemLabel: (sport) => sport.name,
  sort: CrudSortConfig<SportListQuery, SportsListCubit>(
    options: SportsFilterBar.sortOptions,
    current: (query) => [
      for (final item in query.sorts)
        FilterBarSort(item.field.name, item.ascending),
    ],
    tableKey: (query) => query.sortField.name,
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) => cubit.setSorts(
      mapFilterBarSorts<SportSortField, SportSort>(
        sorts,
        parse: SportSortField.tryParse,
        build: (field, ascending) => SportSort(field, ascending),
      ),
    ),
    applyTable: (cubit, sort) {
      final field = SportSortField.tryParse(sort.key);
      if (field != null) {
        cubit.setSorts([SportSort(field, sort.ascending)]);
      }
    },
  ),
  filterControls: (slot) => SportsFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
  ),
  activeFilters: (slot) => SportsFilterBar.activeFilters(
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
      const AppBreadcrumbItem(label: SportsKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards, AppViewMode.grid],
  capabilities: const CrudCapabilities(
    showCount: true,
    duplicate: true,
    bulkSelection: true,
  ),
  providersWrapper: (child) => BlocProvider<SportStatsCubit>(
    create: (_) => sl<SportStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is SportsMutatedEffect,
  onMutated: (context) => context.read<SportStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<SportStatsCubit, SportStatsState>(
    builder: (context, statsState) => SportStatsSection(
      stats: statsState.stats,
      selectedFilter: slot.state.query.status,
      onStatusSelected: slot.cubit.setStatus,
      loading:
          statsState.status == SportStatsStatus.loading ||
          statsState.status == SportStatsStatus.initial,
      failure: statsState.failure?.messageKey,
      onRetry: context.read<SportStatsCubit>().refresh,
    ),
  ),
  flows: CrudFlowsConfig<Sport, SportsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showSportEditor(context, sport: item, duplicate: duplicate),
    onSaved: (cubit, {required isNew}) => cubit.onSportSaved(isNew: isNew),
    itemLabel: (sport) => sport.name,
    delete: (cubit, sport) => cubit.delete(sport),
    activate: (cubit, sport) => cubit.activate(sport.id),
    deactivate: (cubit, sport) => cubit.deactivate(sport.id),
    labels: _crudLabels,
    messageArgs: (sport) => {'name': sport.name},

    isActive: (sport) => sport.isActive,
  ),
  bulk: CrudBulkConfig<Sport, SportsListCubit>(
    activateLabelKey: SportsKeys.bulkActivate,
    deactivateLabelKey: SportsKeys.bulkDeactivate,
    deleteLabelKey: SportsKeys.bulkDelete,
    deactivateTitleKey: SportsKeys.bulkDeactivateTitle,
    deactivateMessageKey: SportsKeys.bulkDeactivateMessage,
    deleteTitleKey: SportsKeys.bulkDeleteTitle,
    deleteMessageKey: SportsKeys.bulkDeleteMessage,
    activate: (cubit, items) => cubit.bulkActivate(items),
    deactivate: (cubit, items) => cubit.bulkDeactivate(items),
    delete: (cubit, items) => cubit.bulkDelete(items),
  ),
  dataSection: (data) =>
      CrudDataSection<Sport, SportListQuery, SportsListCubit>(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: SportsKeys.sportName,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, sport) => SportIdentity(sport),
          ),
          DataTableColumn(
            labelKey: SportsKeys.code,
            sortKey: 'code',
            priority: DataTableColumnPriority.secondary,
            flex: 2,
            cellBuilder: (_, sport) => Directionality(
              textDirection: TextDirection.ltr,
              child: AppText.raw(sport.code),
            ),
          ),
          DataTableColumn(
            labelKey: SportsKeys.description,
            priority: DataTableColumnPriority.secondary,
            flex: 3,
            cellBuilder: (_, sport) => AppText.raw(
              sport.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        labels: _crudLabels,
        statusColumn: CrudStatusColumnConfig<Sport>(
          labelKey: SportsKeys.status,
          isActive: (sport) => sport.isActive,
          badgeBuilder: (_, sport) => SportStatusBadge(sport),
        ),
        cardBuilder: (_, sport) => SportCard(sport),
        gridBuilder: (_, sport) => SportGridTile(sport),
        icon: AppIcons.sports,
        emptyTitleKey: SportsKeys.empty,
        emptyDescriptionKey: SportsKeys.emptyDescription,
        noResultsTitleKey: SportsKeys.noResults,
        noResultsDescriptionKey: SportsKeys.noResultsDescription,
      ),
);
