import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_card.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_identity.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_status_badge.dart';

/// Table sort keys (also the column `sortKey`s).
abstract final class ColorSortKeys {
  static const name = 'name';
  static const code = 'code';

  static String? of(ColorSortField field) => switch (field) {
    ColorSortField.order => null,
    ColorSortField.name => name,
    ColorSortField.code => code,
  };

  static ColorSortField field(String key) => switch (key) {
    name => ColorSortField.name,
    code => ColorSortField.code,
    _ => ColorSortField.order,
  };
}

/// The colors table: columns, empty/error states, icon row actions, paging.
/// Pure presentation: every action is a callback owned by the screen.
class ColorsTableSection extends StatelessWidget {
  const ColorsTableSection({
    super.key,
    required this.onRetry,
    required this.onSort,
    required this.onPageChanged,
    required this.query,
    required this.rows,
    required this.total,
    required this.loading,
    this.refreshing = false,
    required this.failure,
    required this.onAdd,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final VoidCallback onRetry;
  final ValueChanged<DataTableSort> onSort;
  final ValueChanged<int> onPageChanged;
  final ColorListQuery query;
  final List<CatalogColor> rows;
  final int total;
  final bool loading;
  final bool refreshing;
  final Failure? failure;
  final VoidCallback onAdd;
  final ValueChanged<CatalogColor> onEdit;
  final ValueChanged<CatalogColor> onToggleStatus;
  final ValueChanged<CatalogColor> onDelete;

  @override
  Widget build(BuildContext context) {
    final unfiltered = !query.isFiltered;
    return AppDataTable<CatalogColor>(
      columns: [
        DataTableColumn(
          labelKey: ColorsKeys.colorName,
          sortKey: ColorSortKeys.name,
          priority: DataTableColumnPriority.primary,
          flex: 3,
          cellBuilder: (_, c) => ColorIdentity(c),
        ),
        DataTableColumn(
          labelKey: ColorsKeys.code,
          sortKey: ColorSortKeys.code,
          priority: DataTableColumnPriority.secondary,
          flex: 2,
          cellBuilder: (_, c) => Directionality(
            textDirection: TextDirection.ltr,
            child: AppText.raw(c.code),
          ),
        ),
        DataTableColumn(
          labelKey: ColorsKeys.hexCode,
          priority: DataTableColumnPriority.secondary,
          flex: 2,
          cellBuilder: (ctx, c) => c.hexCode == null
              ? AppText(
                  ColorsKeys.noSampleLabel,
                  type: AppTextType.bodySmall,
                  color: ctx.ui.theme.colors.onSurfaceVariant,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: AppText.raw(c.hexCode!),
                      ),
                    ),
                    AppIconButton(
                      AppIcons.copy,
                      tooltipKey: ColorsKeys.copyHex,
                      size: AppButtonSize.small,
                      onPressed: () => Clipboard.setData(
                        ClipboardData(text: c.hexCode!),
                      ),
                    ),
                  ],
                ),
        ),
        DataTableColumn(
          labelKey: ColorsKeys.status,
          priority: DataTableColumnPriority.secondary,
          cellBuilder: (_, c) => ColorStatusBadge(c),
        ),
      ],
      rows: rows,
      rowId: (c) => c.id,
      loading: loading,
      refreshing: refreshing,
      errorKey: failure?.messageKey,
      onRetry: onRetry,
      emptyState: AppEmptyState(
        icon: AppIcons.colors,
        titleKey: unfiltered ? ColorsKeys.empty : ColorsKeys.noResults,
        descriptionKey: unfiltered
            ? ColorsKeys.emptyDescription
            : ColorsKeys.noResultsDescription,
        action: unfiltered
            ? PermissionGate(
                permission: Permissions.masterData.manage,
                child: AppButton(
                  ColorsKeys.add,
                  icon: AppIcons.add,
                  onPressed: onAdd,
                ),
              )
            : null,
      ),
      cardBuilder: (_, c) => ColorCard(c),
      rowActionsBuilder: (_, c) => PermissionGate(
        permission: Permissions.masterData.manage,
        child: AppRowActions(
          primary: [
            AppRowAction(
              icon: AppIcons.edit,
              labelKey: ColorsKeys.edit,
              onPressed: () => onEdit(c),
            ),
            AppRowAction(
              icon: c.isActive ? AppIcons.block : AppIcons.restore,
              labelKey: c.isActive
                  ? ColorsKeys.deactivate
                  : ColorsKeys.activate,
              destructive: c.isActive,
              onPressed: () => onToggleStatus(c),
            ),
          ],
          overflow: [
            AppRowAction(
              icon: AppIcons.delete,
              labelKey: ColorsKeys.delete,
              destructive: true,
              onPressed: () => onDelete(c),
            ),
          ],
        ),
      ),
      sortKey: ColorSortKeys.of(query.sortField),
      sortAscending: query.sortAscending,
      onSort: onSort,
      page: query.page,
      pageSize: query.pageSize,
      totalCount: total,
      hasMore: query.page * query.pageSize < total,
      onPageChanged: onPageChanged,
    );
  }
}
