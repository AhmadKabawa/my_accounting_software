import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/foundation/types/paged_query.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/crud_selection_scope.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_toolbar_config.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/presentation/widgets/crud_list/crud_list_config.dart';

/// Core-owned CRUD list composition. Feature widgets remain responsible for
/// rendering their rows and for all feature-specific business operations.
class CrudListScreen<T, Q extends PagedQuery<Q>, C extends PagedListCubit<T, Q, E>, E> extends StatelessWidget {
  const CrudListScreen({super.key, required this.config});

  final CrudListConfig<T, Q, C, E> config;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<C>(create: (_) => config.createCubit()..load()),
      ...?config.extraProviders?.call(),
      BlocProvider(
        create: (_) => ViewModeCubit(
          settings: sl<AppSettingsManager>(),
          screenId: config.screenId,
        )..restore(),
      ),
    ],
    child: BlocEffectListener<E, C>(
      onEffect: (context, effect) {
        if (config.isMutationEffect?.call(effect) ?? true) {
          config.onMutated?.call(context);
        }
      },
      child: _CrudListBody<T, Q, C, E>(config: config),
    ),
  );
}

class _CrudListBody<T, Q extends PagedQuery<Q>, C extends PagedListCubit<T, Q, E>, E> extends StatelessWidget {
  const _CrudListBody({required this.config});

  final CrudListConfig<T, Q, C, E> config;

  @override
  Widget build(BuildContext context) => BlocBuilder<ViewModeCubit, AppViewMode?>(
    builder: (context, mode) => BlocBuilder<C, PagedListState<T, Q>>(
      builder: (context, state) {
        final cubit = context.read<C>();
        final canManage = context.watch<AccessCubit>().can(config.manageAccess);
        final slot = CrudSlotContext<T, Q, C>(
          context: context,
          state: state,
          cubit: cubit,
          canManage: canManage,
        );
        final rows = state.result?.items ?? <T>[];
        final failure = state.hasData ? null : state.failure;
        final refreshFailure = state.hasData ? state.failure : null;
        final loading = state.isInitialLoading;
        final addAction = ListAddAction(
          labelKey: config.addLabelKey,
          permission: config.manageAccess,
          onPressed: config.onAdd,
        );
        final filters = [
          ...config.filterControls(slot),
          ...?config.extraFilterControls?.call(slot),
        ];

        return ListPageTemplate(
          titleKey: config.titleKey,
          breadcrumb: config.breadcrumb(context),
          stats: _headerWidgets(slot),
          count: config.capabilities.showCount ? state.result?.totalCount : null,
          toolbar: ListToolbarConfig(
            searchHintKey: config.searchHintKey,
            onSearchChanged: cubit.searchChanged,
            onClearAll: cubit.clearFilters,
            activeFilters: config.activeFilters(slot),
            filterControls: filters,
            sortOptions: config.sort.options,
            sorts: config.sort.current(state.query),
            onSortsChanged: (sorts) => config.sort.apply(cubit, sorts),
            sortKey: config.sort.tableKey(state.query),
            sortAscending: config.sort.tableAscending(state.query),
            onSort: (key, ascending) => config.sort.applyTable(
              cubit,
              DataTableSort(key, ascending),
            ),
            viewModes: config.viewModes,
            viewMode: mode,
            onViewModeChanged: (next) {
              cubit.selection.clear();
              context.read<ViewModeCubit>().select(next);
            },
            onRefresh: cubit.refresh,
            refreshing: state.isRefreshing,
            selectionModeActive: state.selectionMode,
            onSelectionModeToggle: config.capabilities.bulkSelection && canManage
                ? cubit.toggleSelectionMode
                : null,
            extraActions: config.extraToolbarActions?.call(slot) ?? const [],
          ),
          addAction: addAction,
          loadingViewMode: mode,
          state: loading
              ? AppPageState.loading
              : failure != null
                  ? AppPageState.error
                  : AppPageState.content,
          errorKey: failure?.messageKey,
          refreshErrorKey: refreshFailure?.messageKey,
          onRetry: cubit.refresh,
          emptyState: config.emptyStateBuilder?.call(context),
          dataTable: CrudSelectionScope<T>(
            rows: rows,
            rowId: config.rowId,
            selection: cubit.selection,
            permission: config.manageAccess,
            selectionModeActive: state.selectionMode && config.capabilities.bulkSelection,
            onSelectionModeExit: () => cubit.setSelectionMode(false),
            actionsBuilder: (selected) => [
              ...?config.bulkActions?.call(slot, selected),
              ...?config.extraBulkActions?.call(slot, selected),
            ],
            builder: (context, selectedIds, onSelectionChanged) =>
                config.dataSection(CrudDataContext<T, Q, C>(
                  mode: mode,
                  rows: rows,
                  total: state.result?.totalCount ?? 0,
                  query: state.query,
                  loading: loading,
                  refreshing: state.isRefreshing,
                  failure: failure,
                  busyIds: state.busyIds,
                  selectedIds: selectedIds,
                  onSelectionChanged: onSelectionChanged,
                  onRetry: cubit.refresh,
                  onPageChanged: cubit.setPage,
                  addAction: addAction,
                  cubit: cubit,
                  rowId: config.rowId,
                  itemLabel: config.itemLabel,
                  onEdit: config.onEdit,
                  onDuplicate: config.capabilities.duplicate ? config.onDuplicate : null,
                  onDelete: config.onDelete,
                  onToggleStatus: config.onToggleStatus,
                )),
          ),
        );
      },
    ),
  );

  Widget? _headerWidgets(CrudSlotContext<T, Q, C> slot) {
    final stats = config.statsBuilder?.call(slot);
    final extras = config.headerExtras?.call(slot) ?? const <Widget>[];
    if (stats == null && extras.isEmpty) return null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stats != null) stats,
        ...extras,
      ],
    );
  }
}
