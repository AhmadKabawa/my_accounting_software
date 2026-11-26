import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_action_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_flows_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_bulk_config.dart';

/// Switches shared by every CRUD list. A new capability defaults to false/null
/// so existing screens keep their behavior; [showCount] is the one documented
/// exception: the record count is on by default (set it false to hide it).
class CrudCapabilities {
  const CrudCapabilities({
    this.showCount = true,
    this.duplicate = true,
    this.bulkSelection = true,
  });

  final bool showCount;
  final bool duplicate;
  final bool bulkSelection;
}

/// Stable presentation projection for loading, failed and stale-data states.
class CrudListStateView<T, Q extends PagedQuery<Q>> {
  CrudListStateView.from(PagedListState<T, Q> state)
    : rows = state.result?.items ?? <T>[],
      total = state.result?.totalCount ?? 0,
      loading = state.isInitialLoading,
      refreshing = state.isRefreshing,
      failure = state.hasData ? null : state.failure,
      refreshFailure = state.hasData ? state.failure : null;

  final List<T> rows;
  final int total;
  final bool loading;
  final bool refreshing;
  final Failure? failure;
  final Failure? refreshFailure;
}

/// The typed, feature-owned inputs needed to render a CRUD list.
class CrudSlotContext<T, Q extends PagedQuery<Q>, C> {
  const CrudSlotContext({
    required this.context,
    required this.state,
    required this.cubit,
    required this.canManage,
  });

  final BuildContext context;
  final PagedListState<T, Q> state;
  final C cubit;
  final bool canManage;
}

/// Adapts feature query sorting to the common filter and table controls.
class CrudSortConfig<Q, C> {
  const CrudSortConfig({
    this.options = const [],
    this.optionsForQuery,
    this.maxSorts = 0,
    required this.current,
    required this.tableKey,
    required this.tableAscending,
    required this.apply,
    required this.applyTable,
  });

  final List<FilterBarSortOption> options;
  final List<FilterBarSortOption> Function(Q query)? optionsForQuery;
  final int maxSorts;

  List<FilterBarSortOption> optionsFor(Q query) =>
      optionsForQuery?.call(query) ?? options;
  final List<FilterBarSort> Function(Q query) current;
  final String? Function(Q query) tableKey;
  final bool Function(Q query) tableAscending;
  final void Function(C cubit, List<FilterBarSort> sorts) apply;
  final void Function(C cubit, DataTableSort sort) applyTable;
}

/// Values supplied to a feature's table/cards/grid builder.
class CrudDataContext<T, Q extends PagedQuery<Q>, C> {
  const CrudDataContext({
    required this.context,
    required this.mode,
    required this.rows,
    required this.total,
    required this.query,
    required this.sortKey,
    required this.sortAscending,
    required this.onSort,
    required this.permission,
    required this.loading,
    required this.refreshing,
    required this.failure,
    required this.busyIds,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onRetry,
    required this.onPageChanged,
    required this.addAction,
    required this.cubit,
    required this.rowId,
    required this.itemLabel,
    this.flows,
    this.canDuplicate = true,
  });

  final BuildContext context;
  final AppViewMode? mode;
  final List<T> rows;
  final int total;
  final Q query;
  final String? sortKey;
  final bool sortAscending;
  final ValueChanged<DataTableSort> onSort;
  final Permission permission;
  final bool loading;
  final bool refreshing;
  final Failure? failure;
  final Set<Object> busyIds;
  final Set<Object> selectedIds;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final VoidCallback onRetry;
  final ValueChanged<int> onPageChanged;
  final ListAddAction addAction;
  final C cubit;
  final Object Function(T row) rowId;
  final String Function(T row) itemLabel;
  final CrudFlowsConfig<T, C>? flows;
  final bool canDuplicate;
}

/// Complete feature configuration for the reusable CRUD list frame.
///
/// Which field serves which purpose:
/// * Required adapters: identity ([screenId], titles, [manageAccess]),
///   [sort], [filterControls]/[activeFilters] and [dataSection].
/// * [flows]: row operations (add, edit, duplicate, delete, status) and their
///   confirmations. [bulk]: the standard bulk activate/deactivate/delete.
///   Each operation is optional (an entity without `is_active` leaves status
///   out of both). [onAdd] is only for a list without [flows].
/// * [capabilities]: switches shared by every list (count, duplicate, bulk
///   selection).
/// * [providersWrapper], [statsBuilder], [onMutated]/[isMutationEffect]:
///   feature-owned providers, statistics and their refresh.
/// * [headerExtras], [extraToolbarActions], [extraFilterControls],
///   [extraBulkActions], [emptyStateBuilder]: additions for one screen only;
///   never use them to re-implement what [flows] or [bulk] already do.
class CrudListConfig<
  T,
  Q extends PagedQuery<Q>,
  C extends PagedListCubit<T, Q, E>,
  E
> {
  const CrudListConfig({
    required this.screenId,
    required this.titleKey,
    required this.manageAccess,
    required this.searchHintKey,
    required this.addLabelKey,
    this.onAdd,
    required this.createCubit,
    required this.rowId,
    required this.itemLabel,
    required this.sort,
    required this.filterControls,
    required this.activeFilters,
    required this.breadcrumb,
    required this.dataSection,
    this.viewModes = const [
      AppViewMode.table,
      AppViewMode.cards,
      AppViewMode.grid,
    ],
    this.capabilities = const CrudCapabilities(),
    this.onMutated,
    this.isMutationEffect,
    this.providersWrapper,
    this.statsBuilder,
    this.headerExtras,
    this.extraToolbarActions,
    this.extraFilterControls,
    this.extraBulkActions,
    this.emptyStateBuilder,
    this.flows,
    this.bulk,
  });

  final String screenId;
  final AppKey titleKey;
  final Permission manageAccess;
  final AppKey searchHintKey;
  final AppKey addLabelKey;
  final void Function(BuildContext context)? onAdd;
  final C Function() createCubit;
  final Object Function(T row) rowId;
  final String Function(T row) itemLabel;
  final CrudSortConfig<Q, C> sort;
  final List<Widget> Function(CrudSlotContext<T, Q, C> slot) filterControls;
  final List<FilterBarFilter> Function(CrudSlotContext<T, Q, C> slot)
  activeFilters;
  final Widget Function(BuildContext context) breadcrumb;
  final Widget Function(CrudDataContext<T, Q, C> data) dataSection;
  final List<AppViewMode> viewModes;
  final CrudCapabilities capabilities;
  final void Function(BuildContext context)? onMutated;
  final bool Function(E effect)? isMutationEffect;

  /// Wraps the engine with any feature-owned Bloc/Repository providers.
  final Widget Function(Widget child)? providersWrapper;

  final Widget Function(CrudSlotContext<T, Q, C> slot)? statsBuilder;
  final List<Widget> Function(CrudSlotContext<T, Q, C> slot)? headerExtras;
  final List<Widget> Function(CrudSlotContext<T, Q, C> slot)?
  extraToolbarActions;
  final List<Widget> Function(CrudSlotContext<T, Q, C> slot)?
  extraFilterControls;
  final List<BulkAction> Function(
    CrudSlotContext<T, Q, C> slot,
    List<T> selected,
  )?
  extraBulkActions;
  final Widget Function(BuildContext context)? emptyStateBuilder;
  final CrudFlowsConfig<T, C>? flows;
  final CrudBulkConfig<T, C>? bulk;
}
