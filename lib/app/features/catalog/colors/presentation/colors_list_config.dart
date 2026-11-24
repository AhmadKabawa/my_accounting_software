import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
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
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_state.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_stats_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_card.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_grid_tile.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_hex_cell.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_identity.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_status_badge.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/colors_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

const _colorsScreenId = 'catalog.colors';

CrudListConfig<CatalogColor, ColorListQuery, ColorsListCubit, ColorsListEffect>
get colorsListConfig => CrudListConfig(
  screenId: _colorsScreenId,
  titleKey: ColorsKeys.title,
  manageAccess: Permissions.masterData.manage,
  searchHintKey: ColorsKeys.searchHint,
  addLabelKey: ColorsKeys.add,
  createCubit: () => sl<ColorsListCubit>(),
  rowId: (color) => color.id,
  itemLabel: (color) => color.name,
  sort: CrudSortConfig<ColorListQuery, ColorsListCubit>(
    options: ColorsFilterBar.sortOptions,
    current: (query) => [
      for (final item in query.sorts)
        FilterBarSort(item.field.name, item.ascending),
    ],
    tableKey: (query) => query.sortField.name,
    tableAscending: (query) => query.sortAscending,
    apply: (cubit, sorts) => cubit.setSorts(
      mapFilterBarSorts<ColorSortField, ColorSort>(
        sorts,
        parse: ColorSortField.tryParse,
        build: (field, ascending) => ColorSort(field, ascending),
      ),
    ),
    applyTable: (cubit, sort) {
      final field = ColorSortField.tryParse(sort.key);
      if (field != null) {
        cubit.setSorts([ColorSort(field, sort.ascending)]);
      }
    },
  ),
  filterControls: (slot) => ColorsFilterBar.controls(
    slot.context,
    slot.state.query,
    onStatusChanged: slot.cubit.setStatus,
  ),
  activeFilters: (slot) => ColorsFilterBar.activeFilters(
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
      const AppBreadcrumbItem(label: ColorsKeys.title),
    ],
  ),
  viewModes: const [AppViewMode.table, AppViewMode.cards, AppViewMode.grid],
  capabilities: const CrudCapabilities(
    showCount: true,
    duplicate: true,
    bulkSelection: true,
  ),
  providersWrapper: (child) => BlocProvider<ColorStatsCubit>(
    create: (_) => sl<ColorStatsCubit>()..load(),
    child: child,
  ),
  isMutationEffect: (effect) => effect is ColorsMutatedEffect,
  onMutated: (context) => context.read<ColorStatsCubit>().refresh(),
  statsBuilder: (slot) => BlocBuilder<ColorStatsCubit, ColorStatsState>(
    builder: (context, statsState) => ColorStatsSection(
      stats: statsState.stats,
      selectedFilter: slot.state.query.status,
      onStatusSelected: slot.cubit.setStatus,
      loading:
          statsState.status == ColorStatsStatus.loading ||
          statsState.status == ColorStatsStatus.initial,
      failure: statsState.failure?.messageKey,
      onRetry: context.read<ColorStatsCubit>().refresh,
    ),
  ),
  flows: CrudFlowsConfig<CatalogColor, ColorsListCubit>(
    showEditor: (context, {item, duplicate = false}) =>
        showColorEditor(context, color: item, duplicate: duplicate),
    onSaved: (cubit, {required isNew}) => cubit.onColorSaved(isNew: isNew),
    itemLabel: (color) => color.name,
    delete: (cubit, color) => cubit.delete(color),
    activate: (cubit, color) => cubit.activate(color.id),
    deactivate: (cubit, color) => cubit.deactivate(color.id),
    deleteTitleKey: ColorsKeys.deleteTitle,
    deleteMessageKey: ColorsKeys.deleteMessage,
    messageArgs: (color) => {'name': color.name},
    deactivateTitleKey: ColorsKeys.deactivateTitle,
    deactivateMessageKey: ColorsKeys.deactivateMessage,
    editLabelKey: ColorsKeys.edit,
    deleteLabelKey: ColorsKeys.delete,
    duplicateLabelKey: ColorsKeys.duplicate,
    activateLabelKey: ColorsKeys.activate,
    deactivateLabelKey: ColorsKeys.deactivate,
    isActive: (color) => color.isActive,
  ),
  bulk: CrudBulkConfig<CatalogColor, ColorsListCubit>(
    activateLabelKey: ColorsKeys.bulkActivate,
    deactivateLabelKey: ColorsKeys.bulkDeactivate,
    deleteLabelKey: ColorsKeys.bulkDelete,
    deactivateTitleKey: ColorsKeys.bulkDeactivateTitle,
    deactivateMessageKey: ColorsKeys.bulkDeactivateMessage,
    deleteTitleKey: ColorsKeys.bulkDeleteTitle,
    deleteMessageKey: ColorsKeys.bulkDeleteMessage,
    activate: (cubit, items) => cubit.bulkActivate(items),
    deactivate: (cubit, items) => cubit.bulkDeactivate(items),
    delete: (cubit, items) => cubit.bulkDelete(items),
  ),
  dataSection: (data) =>
      CrudDataSection<CatalogColor, ColorListQuery, ColorsListCubit>(
        data: data,
        columns: [
          DataTableColumn(
            labelKey: ColorsKeys.colorName,
            sortKey: 'name',
            priority: DataTableColumnPriority.primary,
            flex: 3,
            cellBuilder: (_, color) => ColorIdentity(color),
          ),
          DataTableColumn(
            labelKey: ColorsKeys.code,
            sortKey: 'code',
            priority: DataTableColumnPriority.secondary,
            flex: 2,
            cellBuilder: (_, color) => Directionality(
              textDirection: TextDirection.ltr,
              child: AppText.raw(color.code),
            ),
          ),
          DataTableColumn(
            labelKey: ColorsKeys.hexCode,
            priority: DataTableColumnPriority.secondary,
            flex: 2,
            cellBuilder: (_, color) => ColorHexCell(color),
          ),
        ],
        statusColumn: CrudStatusColumnConfig<CatalogColor>(
          labelKey: ColorsKeys.status,
          isActive: (color) => color.isActive,
          badgeBuilder: (_, color) => ColorStatusBadge(color),
          activateLabelKey: ColorsKeys.activate,
          deactivateLabelKey: ColorsKeys.deactivate,
        ),
        cardBuilder: (_, color) => ColorCard(color),
        gridBuilder: (_, color) => ColorGridTile(color),
        icon: AppIcons.colors,
        emptyTitleKey: ColorsKeys.empty,
        emptyDescriptionKey: ColorsKeys.emptyDescription,
        noResultsTitleKey: ColorsKeys.noResults,
        noResultsDescriptionKey: ColorsKeys.noResultsDescription,
        editLabelKey: ColorsKeys.edit,
        deleteLabelKey: ColorsKeys.delete,
        duplicateLabelKey: ColorsKeys.duplicate,
      ),
);
