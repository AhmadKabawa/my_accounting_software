import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/crud_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/crud_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_identity.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_status_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

class ColorsTableSection extends StatelessWidget {
  const ColorsTableSection({
    super.key,
    required this.mode,
    required this.onRetry,
    required this.onSort,
    required this.onPageChanged,
    required this.query,
    required this.rows,
    required this.total,
    required this.loading,
    required this.refreshing,
    required this.failure,
    required this.addAction,
    required this.onEdit,
    required this.onDuplicate,
    required this.onToggleStatus,
    required this.onDelete,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final AppViewMode? mode;
  final VoidCallback onRetry;
  final ValueChanged<DataTableSort> onSort;
  final ValueChanged<int> onPageChanged;
  final ColorListQuery query;
  final List<CatalogColor> rows;
  final int total;
  final bool loading;
  final bool refreshing;
  final Failure? failure;
  final ListAddAction addAction;
  final ValueChanged<CatalogColor> onEdit;
  final ValueChanged<CatalogColor> onDuplicate;
  final ValueChanged<CatalogColor> onToggleStatus;
  final ValueChanged<CatalogColor> onDelete;
  final Set<Object> selectedIds;
  final ValueChanged<Set<Object>>? onSelectionChanged;

  Widget _card(BuildContext context, CatalogColor color, AppIconSize size) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ColorIdentity(color, size: size),
      context.ui.spacing.gap(AppSpacing.xs),
      AppText.raw(color.code, type: AppTextType.bodySmall),
      if (color.hexCode != null) ...[
        context.ui.spacing.gap(AppSpacing.xs),
        Directionality(
          textDirection: TextDirection.ltr,
          child: AppText.raw(color.hexCode!, type: AppTextType.bodySmall),
        ),
      ],
      context.ui.spacing.gap(AppSpacing.sm),
      ColorStatusBadge(color),
    ],
  );

  @override
  Widget build(BuildContext context) => AppDataView<CatalogColor>(
    mode: mode,
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
                      child: AppText.raw(color.hexCode!),
                    ),
                  ),
                  AppIconButton(
                    AppIcons.copy,
                    tooltipKey: ColorsKeys.copyHex,
                    size: AppButtonSize.small,
                    onPressed: () => Clipboard.setData(ClipboardData(text: color.hexCode!)),
                  ),
                ],
              ),
      ),
      crudStatusColumn<CatalogColor>(
        labelKey: ColorsKeys.status,
        permission: Permissions.masterData.manage,
        isActive: (color) => color.isActive,
        onToggleStatus: onToggleStatus,
        activateLabelKey: ColorsKeys.activate,
        deactivateLabelKey: ColorsKeys.deactivate,
        badgeBuilder: (_, color) => ColorStatusBadge(color),
      ),
    ],
    rows: rows,
    rowId: (color) => color.id,
    loading: loading,
    refreshing: refreshing,
    errorKey: failure?.messageKey,
    onRetry: onRetry,
    emptyState: CrudEmptyState(
      icon: AppIcons.colors,
      emptyTitleKey: ColorsKeys.empty,
      emptyDescriptionKey: ColorsKeys.emptyDescription,
      noResultsTitleKey: ColorsKeys.noResults,
      noResultsDescriptionKey: ColorsKeys.noResultsDescription,
      hasActiveFilters: query.hasActiveFilters,
      addAction: addAction,
    ),
    cardBuilder: (context, color) => _card(context, color, AppIconSize.lg),
    gridItemBuilder: (context, color) => _card(context, color, AppIconSize.xl),
    selectedIds: selectedIds,
    onSelectionChanged: onSelectionChanged,
    rowActionsBuilder: (_, color) => CrudRowActions(
      permission: Permissions.masterData.manage,
      editLabelKey: ColorsKeys.edit,
      onEdit: () => onEdit(color),
      deleteLabelKey: ColorsKeys.delete,
      onDelete: () => onDelete(color),
      duplicateLabelKey: ColorsKeys.duplicate,
      onDuplicate: () => onDuplicate(color),
      isActive: color.isActive,
      onToggleStatus: () => onToggleStatus(color),
      activateLabelKey: ColorsKeys.activate,
      deactivateLabelKey: ColorsKeys.deactivate,
    ),
    sortKey: query.sortField.name,
    sortAscending: query.sortAscending,
    onSort: onSort,
    page: query.page,
    pageSize: query.pageSize,
    totalCount: total,
    hasMore: query.page * query.pageSize < total,
    onPageChanged: onPageChanged,
  );
}
