import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/crud_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/crud_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_actions_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';

/// Feature-owned status-column policy used by [CrudDataSection].
class CrudStatusColumnConfig<T> {
  const CrudStatusColumnConfig({
    required this.labelKey,
    required this.isActive,
    required this.badgeBuilder,
    required this.activateLabelKey,
    required this.deactivateLabelKey,
    this.sortKey,
  });

  final AppKey labelKey;
  final String? sortKey;
  final bool Function(T row) isActive;
  final Widget Function(BuildContext context, T row) badgeBuilder;
  final AppKey activateLabelKey;
  final AppKey deactivateLabelKey;
}

/// Shared table/cards/grid projection for CRUD list data.
class CrudDataSection<T, Q extends PagedQuery<Q>, C> extends StatelessWidget {
  const CrudDataSection({
    super.key,
    required this.data,
    required this.columns,
    required this.statusColumn,
    required this.cardBuilder,
    required this.gridBuilder,
    required this.icon,
    required this.emptyTitleKey,
    required this.emptyDescriptionKey,
    required this.noResultsTitleKey,
    required this.noResultsDescriptionKey,
    required this.editLabelKey,
    required this.deleteLabelKey,
    required this.duplicateLabelKey,
    this.canDelete,
    this.extraRowActions,
  });

  final CrudDataContext<T, Q, C> data;
  final List<DataTableColumn<T>> columns;
  final CrudStatusColumnConfig<T> statusColumn;
  final Widget Function(BuildContext context, T row) cardBuilder;
  final Widget Function(BuildContext context, T row) gridBuilder;
  final AppIconData icon;
  final AppKey emptyTitleKey;
  final AppKey emptyDescriptionKey;
  final AppKey noResultsTitleKey;
  final AppKey noResultsDescriptionKey;
  final AppKey editLabelKey;
  final AppKey deleteLabelKey;
  final AppKey duplicateLabelKey;
  final bool Function(T row)? canDelete;
  final List<AppRowAction> Function(BuildContext context, T row)?
  extraRowActions;

  @override
  Widget build(BuildContext context) => AppDataView<T>(
    columns: [
      ...columns,
      crudStatusColumn<T>(
        labelKey: statusColumn.labelKey,
        sortKey: statusColumn.sortKey,
        permission: data.permission,
        isActive: statusColumn.isActive,
        onToggleStatus: (row) =>
            CrudListActions.toggleStatus(context, data.actions, row),
        badgeBuilder: statusColumn.badgeBuilder,
        activateLabelKey: statusColumn.activateLabelKey,
        deactivateLabelKey: statusColumn.deactivateLabelKey,
        isBusy: (row) => data.busyIds.contains(data.rowId(row)),
      ),
    ],
    rows: data.rows,
    rowId: data.rowId,
    mode: data.mode,
    cardBuilder: cardBuilder,
    gridItemBuilder: gridBuilder,
    loading: data.loading,
    refreshing: data.refreshing,
    errorKey: data.failure?.messageKey,
    onRetry: data.onRetry,
    emptyState: CrudEmptyState(
      icon: icon,
      emptyTitleKey: emptyTitleKey,
      emptyDescriptionKey: emptyDescriptionKey,
      noResultsTitleKey: noResultsTitleKey,
      noResultsDescriptionKey: noResultsDescriptionKey,
      hasActiveFilters: data.query.hasActiveFilters,
      addAction: data.addAction,
    ),
    sortKey: data.sortKey,
    sortAscending: data.sortAscending,
    onSort: data.onSort,
    selectedIds: data.selectedIds,
    onSelectionChanged: data.onSelectionChanged,
    rowActionsBuilder: (context, row) => CrudRowActions(
      permission: data.permission,
      editLabelKey: editLabelKey,
      onEdit: () => CrudListActions.edit(context, data.actions, row),
      deleteLabelKey: deleteLabelKey,
      onDelete: (canDelete?.call(row) ?? true)
          ? () => CrudListActions.delete(context, data.actions, row)
          : null,
      duplicateLabelKey: data.actions.onDuplicate == null
          ? null
          : duplicateLabelKey,
      onDuplicate: data.actions.onDuplicate == null
          ? null
          : () => CrudListActions.duplicate(context, data.actions, row),
      isActive: statusColumn.isActive(row),
      onToggleStatus: () =>
          CrudListActions.toggleStatus(context, data.actions, row),
      activateLabelKey: statusColumn.activateLabelKey,
      deactivateLabelKey: statusColumn.deactivateLabelKey,
      statusBusy: data.busyIds.contains(data.rowId(row)),
      extraOverflow:
          extraRowActions?.call(context, row) ??
          data.actions.extraRowActions?.call(context, row) ??
          const [],
    ),
    page: data.query.page,
    pageSize: data.query.pageSize,
    totalCount: data.total,
    hasMore: data.query.page * data.query.pageSize < data.total,
    onPageChanged: data.onPageChanged,
  );
}
