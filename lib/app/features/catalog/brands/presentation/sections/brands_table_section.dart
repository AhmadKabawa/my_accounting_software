import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/access/permission_gate/permission_gate.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/crud_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_switch/app_switch.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_card.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_grid_tile.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_logo.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_status_badge.dart';

/// The brands table: columns, empty/error states, icon row actions, paging.
/// Pure presentation: every action is a callback owned by the screen.
class BrandsTableSection extends StatelessWidget {
  const BrandsTableSection({
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
    required this.addAction,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    this.mode,
  });

  final VoidCallback onRetry;
  final ValueChanged<DataTableSort> onSort;
  final ValueChanged<int> onPageChanged;
  final BrandListQuery query;
  final List<Brand> rows;
  final int total;
  final bool loading;
  final bool refreshing;
  final Failure? failure;
  final ListAddAction addAction;
  final ValueChanged<Brand> onEdit;
  final ValueChanged<Brand> onDelete;
  final ValueChanged<Brand> onToggleStatus;

  /// The user's chosen view; null = the screen's responsive default.
  final AppViewMode? mode;

  @override
  Widget build(BuildContext context) {
    return AppDataView<Brand>(
      columns: [
        DataTableColumn(
          labelKey: BrandsKeys.brandName,
          sortKey: 'name',
          priority: DataTableColumnPriority.primary,
          flex: 3,
          cellBuilder: (_, b) => BrandIdentity(b),
        ),
        DataTableColumn(
          labelKey: BrandsKeys.description,
          priority: DataTableColumnPriority.secondary,
          flex: 2,
          cellBuilder: (c, b) {
            final description = b.description?.trim() ?? '';
            return AppText.raw(
              description,
              color: c.ui.theme.colors.onSurfaceVariant,
              maxLines: 2,
            );
          },
        ),
        DataTableColumn(
          labelKey: BrandsKeys.productCount,
          priority: DataTableColumnPriority.secondary,
          numeric: true,
          // The header already says "Products": the cell is just the number.
          cellBuilder: (c, b) => AppText.raw(
            b.productCount?.toString() ?? '—',
            color: c.ui.theme.colors.onSurface,
          ),
        ),
        DataTableColumn(
          labelKey: BrandsKeys.updatedAt,
          sortKey: 'updated',
          priority: DataTableColumnPriority.secondary,
          cellBuilder: (c, b) => AppText.raw(
            b.updatedAt == null
                ? '—'
                : MaterialLocalizations.of(c).formatShortDate(b.updatedAt!),
            color: c.ui.theme.colors.onSurfaceVariant,
          ),
        ),
        DataTableColumn(
          labelKey: BrandsKeys.status,
          sortKey: 'status',
          priority: DataTableColumnPriority.secondary,
          // A switch for who may manage brands; a plain badge for everyone else.
          cellBuilder: (_, b) => PermissionGate(
            permission: Permissions.masterData.manage,
            fallback: BrandStatusBadge(b),
            child: AppSwitch(
              value: b.isActive,
              semanticsKey: b.isActive
                  ? BrandsKeys.deactivate
                  : BrandsKeys.activate,
              onChanged: (_) => onToggleStatus(b),
            ),
          ),
        ),
      ],
      mode: mode,
      rows: rows,
      rowId: (b) => b.id,
      loading: loading,
      refreshing: refreshing,
      errorKey: failure?.messageKey,
      onRetry: onRetry,
      emptyState: CrudEmptyState(
        icon: AppIcons.brands,
        emptyTitleKey: BrandsKeys.empty,
        emptyDescriptionKey: BrandsKeys.emptyDescription,
        noResultsTitleKey: BrandsKeys.noResults,
        noResultsDescriptionKey: BrandsKeys.noResultsDescription,
        hasActiveFilters: query.hasActiveFilters,
        addAction: addAction,
      ),
      cardBuilder: (_, b) => BrandCard(b),
      gridItemBuilder: (_, b) => BrandGridTile(b),
      rowActionsBuilder: (c, b) => PermissionGate(
        permission: Permissions.masterData.manage,
        child: AppRowActions(
          primary: [
            AppRowAction(
              icon: AppIcons.edit,
              labelKey: BrandsKeys.edit,
              onPressed: () => onEdit(b),
            ),
          ],
          // Status is the switch in its column; delete lives in the menu and is
          // disabled (not hidden) while the brand still has products.
          overflow: [
            AppRowAction(
              icon: AppIcons.delete,
              labelKey: BrandsKeys.delete,
              destructive: true,
              onPressed: b.canDelete ? () => onDelete(b) : null,
            ),
          ],
        ),
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
}
