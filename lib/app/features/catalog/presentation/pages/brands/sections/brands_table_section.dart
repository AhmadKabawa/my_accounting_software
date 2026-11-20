import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/presentation/cubit/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_card.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_logo.dart';
import 'package:accounting_software/app/features/catalog/presentation/pages/brands/widgets/brand_status_badge.dart';

/// The brands table: columns, empty/error states, icon row actions, paging.
/// Pure presentation: every action is a callback owned by the screen.
class BrandsTableSection extends StatelessWidget {
  const BrandsTableSection({
    super.key,
    required this.cubit,
    required this.query,
    required this.rows,
    required this.total,
    required this.loading,
    required this.failure,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final BrandsListCubit cubit;
  final BrandListQuery query;
  final List<Brand> rows;
  final int total;
  final bool loading;
  final Failure? failure;
  final VoidCallback onAdd;
  final ValueChanged<Brand> onEdit;
  final ValueChanged<Brand> onDelete;
  final ValueChanged<Brand> onToggleStatus;

  @override
  Widget build(BuildContext context) => AppDataTable<Brand>(
          columns: [
            DataTableColumn(labelKey: BrandsKeys.brandName, sortKey: 'name',
              priority: DataTableColumnPriority.primary, flex: 3,
              cellBuilder: (_, b) => BrandIdentity(b)),
            DataTableColumn(labelKey: BrandsKeys.description,
              priority: DataTableColumnPriority.secondary, flex: 2,
              cellBuilder: (c, b) {
                final description = b.description?.trim() ?? '';
                return AppText.raw(
                  description,
                  color: c.ui.theme.colors.onSurfaceVariant,
                  maxLines: 2,
                );
              }),
            DataTableColumn(labelKey: BrandsKeys.productCount,
              priority: DataTableColumnPriority.secondary, numeric: true,
              cellBuilder: (_, b) => BrandProductsBadge(b)),
            DataTableColumn(labelKey: BrandsKeys.status,
              priority: DataTableColumnPriority.secondary,
              cellBuilder: (_, b) => BrandStatusBadge(b)),
          ],
          rows: rows, rowId: (b) => b.id, loading: loading,
          errorKey: failure?.messageKey, onRetry: cubit.refresh,
          emptyState: AppEmptyState(
            icon: AppIcons.brands,
            titleKey: query.search.isEmpty && query.status == BrandStatusFilter.all
                ? BrandsKeys.empty : BrandsKeys.noResults,
            descriptionKey: query.search.isEmpty && query.status == BrandStatusFilter.all
                ? BrandsKeys.emptyDescription : BrandsKeys.noResultsDescription,
            action: query.search.isEmpty && query.status == BrandStatusFilter.all
                ? PermissionGate(permission: Permissions.masterData.manage,
                    child: AppButton(BrandsKeys.add, icon: AppIcons.add,
                      onPressed: () => onAdd())) : null,
          ),
          cardBuilder: (_, b) => BrandCard(b),
          rowActionsBuilder: (c, b) => PermissionGate(
            permission: Permissions.masterData.manage,
            child: AppRowActions(
              primary: [
                AppRowAction(
                  icon: AppIcons.edit,
                  labelKey: BrandsKeys.edit,
                  onPressed: () => onEdit(b),
                ),
                if (b.productCount == 0)
                  AppRowAction(
                    icon: AppIcons.delete,
                    labelKey: BrandsKeys.delete,
                    destructive: true,
                    onPressed: () => onDelete(b),
                  ),
              ],
              overflow: [
                AppRowAction(
                  icon: b.isActive ? AppIcons.block : AppIcons.restore,
                  labelKey: b.isActive ? BrandsKeys.deactivate : BrandsKeys.activate,
                  onPressed: () => onToggleStatus(b),
                ),
              ],
            ),
          ),
          sortKey: 'name', sortAscending: query.sortAscending,
          onSort: (s) => cubit.setSort(ascending: s.ascending),
          page: query.page, pageSize: query.pageSize, totalCount: total,
          hasMore: query.page * query.pageSize < total,
          onPageChanged: cubit.setPage,
        );
}
