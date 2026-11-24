import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_actions_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_data_section.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_state.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_stats_section.dart';
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
  onAdd: (context) => ColorsListActions.edit(context),
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
  actions: CrudActionsConfig<CatalogColor>(
    onEdit: (context, color) => ColorsListActions.edit(context, color),
    onDuplicate: (context, color) =>
        ColorsListActions.duplicate(context, color),
    onDelete: (context, color) => ColorsListActions.delete(context, color),
    onToggleStatus: (context, color) =>
        ColorsListActions.toggleStatus(context, color),
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
            cellBuilder: (_, color) => color.hexCode == null
                ? AppText(ColorsKeys.noSampleLabel, type: AppTextType.bodySmall)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: AppText.raw(color.hexCode ?? ''),
                        ),
                      ),
                      AppIconButton(
                        AppIcons.copy,
                        tooltipKey: ColorsKeys.copyHex,
                        size: AppButtonSize.small,
                        onPressed: () => Clipboard.setData(
                          ClipboardData(text: color.hexCode ?? ''),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
        statusColumn: CrudStatusColumnConfig<CatalogColor>(
          labelKey: ColorsKeys.status,
          isActive: (color) => color.isActive,
          badgeBuilder: (_, color) => ColorStatusBadge(color),
          activateLabelKey: ColorsKeys.activate,
          deactivateLabelKey: ColorsKeys.deactivate,
        ),
        cardBuilder: (context, color) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColorIdentity(color, size: AppIconSize.lg),
            context.ui.spacing.gap(AppSpacing.xs),
            AppText.raw(color.code, type: AppTextType.bodySmall),
            if (color.hexCode != null) ...[
              context.ui.spacing.gap(AppSpacing.xs),
              Directionality(
                textDirection: TextDirection.ltr,
                child: AppText.raw(
                  color.hexCode ?? '',
                  type: AppTextType.bodySmall,
                ),
              ),
            ],
            context.ui.spacing.gap(AppSpacing.sm),
            ColorStatusBadge(color),
          ],
        ),
        gridBuilder: (context, color) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColorIdentity(color, size: AppIconSize.xl, maxNameLines: 2),
            context.ui.spacing.gap(AppSpacing.xs),
            AppText.raw(
              color.code,
              type: AppTextType.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (color.hexCode != null) ...[
              context.ui.spacing.gap(AppSpacing.xs),
              Directionality(
                textDirection: TextDirection.ltr,
                child: AppText.raw(
                  color.hexCode ?? '',
                  type: AppTextType.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            context.ui.spacing.gap(AppSpacing.sm),
            ColorStatusBadge(color),
          ],
        ),
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

abstract final class ColorsListActions {
  static Future<void> edit(BuildContext context, [CatalogColor? color]) async {
    final saved = await showColorEditor(context, color: color);
    if (saved == true && context.mounted) {
      await context.read<ColorsListCubit>().onColorSaved(isNew: color == null);
    }
  }

  static Future<void> duplicate(
    BuildContext context,
    CatalogColor color,
  ) async {
    final saved = await showColorEditor(context, color: color, duplicate: true);
    if (saved == true && context.mounted) {
      await context.read<ColorsListCubit>().onColorSaved(isNew: true);
    }
  }

  static Future<void> delete(BuildContext context, CatalogColor color) {
    final cubit = context.read<ColorsListCubit>();
    return CrudConfirmations.delete(
      context,
      titleKey: ColorsKeys.deleteTitle,
      messageKey: ColorsKeys.deleteMessage,
      messageArgs: {'name': color.name},
      targetName: color.name,
      onDelete: () => cubit.delete(color),
    );
  }

  static Future<void> toggleStatus(BuildContext context, CatalogColor color) {
    final cubit = context.read<ColorsListCubit>();
    return CrudConfirmations.status(
      context,
      isActive: color.isActive,
      targetName: color.name,
      titleKey: ColorsKeys.deactivateTitle,
      messageKey: ColorsKeys.deactivateMessage,
      onActivate: () => cubit.activate(color.id),
      onDeactivate: () => cubit.deactivate(color.id),
    );
  }
}
