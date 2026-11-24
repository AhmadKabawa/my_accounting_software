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
    this.sortKey,
  });

  final AppKey labelKey;
  final String? sortKey;
  final bool Function(T row) isActive;
  final Widget Function(BuildContext context, T row) badgeBuilder;
}

/// Shared table/cards/grid projection for CRUD list data.
///
/// [statusColumn] is optional: null means the entity has no `is_active`, so
/// there is no status column and no activate/deactivate row action. Delete and
/// duplicate are optional through [labels] and the flows (see [CrudLabels]).
class CrudDataSection<T, Q extends PagedQuery<Q>, C> extends StatelessWidget {
  const CrudDataSection({
    super.key,
    required this.data,
    required this.columns,
    required this.labels,
    required this.cardBuilder,
    required this.gridBuilder,
    required this.icon,
    required this.emptyTitleKey,
    required this.emptyDescriptionKey,
    required this.noResultsTitleKey,
    required this.noResultsDescriptionKey,
    this.statusColumn,
    this.extraRowActions,
  });

  final CrudDataContext<T, Q, C> data;
  final List<DataTableColumn<T>> columns;
  final CrudLabels labels;
  final CrudStatusColumnConfig<T>? statusColumn;
  final Widget Function(BuildContext context, T row) cardBuilder;
  final Widget Function(BuildContext context, T row) gridBuilder;
  final AppIconData icon;
  final AppKey emptyTitleKey;
  final AppKey emptyDescriptionKey;
  final AppKey noResultsTitleKey;
  final AppKey noResultsDescriptionKey;
  final List<AppRowAction> Function(BuildContext context, T row)?
  extraRowActions;

  @override
  Widget build(BuildContext context) {
    final status = statusColumn;
    final activate = labels.activate;
    final deactivate = labels.deactivate;
    assert(
      status == null || labels.supportsStatus,
      'A statusColumn needs the activate/deactivate labels and deactivation '
      'confirmation copy in CrudLabels.',
    );
    return AppDataView<T>(
      columns: [
        ...columns,
        if (status != null && activate != null && deactivate != null)
          crudStatusColumn<T>(
            labelKey: status.labelKey,
            sortKey: status.sortKey,
            permission: data.permission,
            isActive: status.isActive,
            onToggleStatus: (row) {
              final flows = data.flows;
              if (flows != null) flows.toggleStatus(context, row);
            },
            badgeBuilder: status.badgeBuilder,
            activateLabelKey: activate,
            deactivateLabelKey: deactivate,
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
      rowActionsBuilder: _rowActions,
      page: data.query.page,
      pageSize: data.query.pageSize,
      totalCount: data.total,
      hasMore: data.query.page * data.query.pageSize < data.total,
      onPageChanged: data.onPageChanged,
    );
  }

  Widget _rowActions(BuildContext context, T row) {
    final flows = data.flows;
    final status = statusColumn;
    final showDelete = flows == null
        ? labels.delete != null
        : flows.hasDelete;
    final duplicateKey = data.canDuplicate ? labels.duplicate : null;
    bool? isActive;
    VoidCallback? onToggleStatus;
    if (status != null && flows != null && flows.hasStatus) {
      isActive = status.isActive(row);
      onToggleStatus = () => flows.toggleStatus(context, row);
    }
    return CrudRowActions(
      permission: data.permission,
      editLabelKey: labels.edit,
      onEdit: flows == null ? null : () => flows.edit(context, item: row),
      deleteLabelKey: showDelete ? labels.delete : null,
      onDelete:
          flows != null && flows.hasDelete && (flows.canDelete?.call(row) ?? true)
          ? () => flows.deleteItem(context, row)
          : null,
      duplicateLabelKey: flows == null ? null : duplicateKey,
      onDuplicate: flows != null && duplicateKey != null
          ? () => flows.edit(context, item: row, duplicate: true)
          : null,
      isActive: isActive,
      onToggleStatus: onToggleStatus,
      activateLabelKey: labels.activate,
      deactivateLabelKey: labels.deactivate,
      statusBusy: data.busyIds.contains(data.rowId(row)),
      extraOverflow: extraRowActions?.call(context, row) ?? const [],
    );
  }
}
