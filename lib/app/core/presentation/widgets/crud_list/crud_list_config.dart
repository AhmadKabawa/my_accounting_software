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
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_actions_config.dart';

/// Shared capabilities with conservative defaults; features opt into count.
class CrudCapabilities {
  const CrudCapabilities({
    this.showCount = false,
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
    required this.current,
    required this.tableKey,
    required this.tableAscending,
    required this.apply,
    required this.applyTable,
  });

  final List<FilterBarSortOption> options;
  final List<FilterBarSort> Function(Q query) current;
  final String? Function(Q query) tableKey;
  final bool Function(Q query) tableAscending;
  final void Function(C cubit, List<FilterBarSort> sorts) apply;
  final void Function(C cubit, DataTableSort sort) applyTable;
}

/// Values supplied to a feature's table/cards/grid builder.
class CrudDataContext<T, Q extends PagedQuery<Q>, C> {
  const CrudDataContext({
    required this.mode,
    required this.rows,
    required this.total,
    required this.query,
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
    this.actions = const CrudActionsConfig(),
  });

  final AppViewMode? mode;
  final List<T> rows;
  final int total;
  final Q query;
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
  final CrudActionsConfig<T> actions;
}

/// Complete feature configuration for the reusable CRUD list frame.
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
    required this.onAdd,
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
    this.actions = const CrudActionsConfig(),
    this.bulkActions,
  });

  final String screenId;
  final AppKey titleKey;
  final Permission manageAccess;
  final AppKey searchHintKey;
  final AppKey addLabelKey;
  final void Function(BuildContext context) onAdd;
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
  final CrudActionsConfig<T> actions;
  final List<BulkAction> Function(
    CrudSlotContext<T, Q, C> slot,
    List<T> selected,
  )?
  bulkActions;
}
