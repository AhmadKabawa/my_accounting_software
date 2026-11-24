import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_view.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/crud_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/app_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_row_actions/crud_row_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_labels.dart';

/// Feature-owned status-column policy used by [CrudDataSection].
class CrudStatusColumnConfig<T> {
  const CrudStatusColumnConfig({
    required this.labelKey,
    required this.isActive,
    required this.badgeBuilder,
    this.activateLabelKey,
    this.deactivateLabelKey,
    this.sortKey,
  });

  final AppKey labelKey;
  final String? sortKey;
  final bool Function(T row) isActive;
  final Widget Function(BuildContext context, T row) badgeBuilder;
  final AppKey? activateLabelKey;
  final AppKey? deactivateLabelKey;
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
    this.labels,
    @Deprecated('Use labels.') AppKey? editLabelKey,
    @Deprecated('Use labels.') AppKey? deleteLabelKey,
    @Deprecated('Use labels.') AppKey? duplicateLabelKey,
    this.canDelete,
    this.extraRowActions,
  }) : _editLabelKey = editLabelKey,
       _deleteLabelKey = deleteLabelKey,
       _duplicateLabelKey = duplicateLabelKey;

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
  final CrudLabels? labels;
  final AppKey? _editLabelKey;
  final AppKey? _deleteLabelKey;
  final AppKey? _duplicateLabelKey;

  AppKey get editLabelKey => labels?.edit ?? _editLabelKey!;
  AppKey get deleteLabelKey => labels?.delete ?? _deleteLabelKey!;
  AppKey get duplicateLabelKey => labels?.duplicate ?? _duplicateLabelKey!;
  AppKey get activateLabelKey =>
      labels?.activate ?? statusColumn.activateLabelKey!;
  AppKey get deactivateLabelKey =>
      labels?.deactivate ?? statusColumn.deactivateLabelKey!;
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
        onToggleStatus: (row) {
          final flows = data.flows;
          if (flows != null) flows.toggleStatus(context, row);
        },
        badgeBuilder: statusColumn.badgeBuilder,
        activateLabelKey: activateLabelKey,
        deactivateLabelKey: deactivateLabelKey,
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
      onEdit: () {
        final flows = data.flows;
        if (flows != null) flows.edit(context, item: row);
      },
      deleteLabelKey: deleteLabelKey,
      onDelete: (canDelete?.call(row) ?? true) && data.flows != null
          ? () => data.flows!.deleteItem(context, row)
          : null,
      duplicateLabelKey: data.canDuplicate && data.flows != null
          ? duplicateLabelKey
          : null,
      onDuplicate: data.canDuplicate && data.flows != null
          ? () => data.flows!.edit(context, item: row, duplicate: true)
          : null,
      isActive: statusColumn.isActive(row),
      onToggleStatus: () {
        final flows = data.flows;
        if (flows != null) flows.toggleStatus(context, row);
      },
      activateLabelKey: activateLabelKey,
      deactivateLabelKey: deactivateLabelKey,
      statusBusy: data.busyIds.contains(data.rowId(row)),
      extraOverflow: extraRowActions?.call(context, row) ?? const [],
    ),
    page: data.query.page,
    pageSize: data.query.pageSize,
    totalCount: data.total,
    hasMore: data.query.page * data.query.pageSize < data.total,
    onPageChanged: data.onPageChanged,
  );
}
