import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/crud_bulk_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/crud_selection_scope.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_toolbar_config.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/catalog_color.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/color_stats/color_stats_state.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/cubit/colors_list/colors_list_effect.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/dialogs/color_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/color_stats_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/sections/colors_table_section.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/colors_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  static const screenId = 'catalog.colors';
  static const _modes = [
    AppViewMode.table,
    AppViewMode.cards,
    AppViewMode.grid,
  ];

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<ColorsListCubit>()..load()),
      BlocProvider(create: (_) => sl<ColorStatsCubit>()..load()),
      BlocProvider(
        create: (_) => ViewModeCubit(
          settings: sl<AppSettingsManager>(),
          screenId: screenId,
        )..restore(),
      ),
    ],
    child: BlocEffectListener<ColorsListEffect, ColorsListCubit>(
      onEffect: (context, effect) {
        if (effect is ColorsMutatedEffect) {
          context.read<ColorStatsCubit>().refresh();
        }
      },
      child: BlocBuilder<ViewModeCubit, AppViewMode?>(
        builder: (context, mode) =>
            BlocBuilder<ColorStatsCubit, ColorStatsState>(
              builder: (context, statsState) =>
                  BlocBuilder<
                    ColorsListCubit,
                    PagedListState<CatalogColor, ColorListQuery>
                  >(
                    builder: (context, state) {
                      final cubit = context.read<ColorsListCubit>();
                      final canBulk = context.watch<AccessCubit>().can(
                        Permissions.masterData.manage,
                      );
                      final rows =
                          state.result?.items ?? const <CatalogColor>[];
                      final total = state.result?.totalCount ?? 0;
                      final loading = state.isInitialLoading;
                      final failure = state.hasData ? null : state.failure;
                      final refreshFailure = state.hasData
                          ? state.failure
                          : null;
                      final addAction = ListAddAction(
                        labelKey: ColorsKeys.add,
                        permission: Permissions.masterData.manage,
                        onPressed: () => _edit(context),
                      );
                      return ListPageTemplate(
                        titleKey: ColorsKeys.title,
                        breadcrumb: AppBreadcrumb(
                          items: [
                            AppBreadcrumbItem(
                              label: NavKeys.catalog,
                              onTap: () => context.go(CatalogRoutes.hub.path),
                            ),
                            const AppBreadcrumbItem(label: ColorsKeys.title),
                          ],
                        ),
                        count: total,
                        stats: ColorStatsSection(
                          stats: statsState.stats,
                          selectedFilter: state.query.status,
                          onStatusSelected: cubit.setStatus,
                          loading:
                              statsState.status == ColorStatsStatus.loading ||
                              statsState.status == ColorStatsStatus.initial,
                          failure: statsState.failure?.messageKey,
                          onRetry: context.read<ColorStatsCubit>().refresh,
                        ),
                        toolbar: ListToolbarConfig(
                          searchHintKey: ColorsKeys.searchHint,
                          onSearchChanged: cubit.searchChanged,
                          onClearAll: cubit.clearFilters,
                          activeFilters: ColorsFilterBar.activeFilters(
                            context,
                            state.query,
                            onSearchChanged: cubit.searchChanged,
                            onStatusChanged: cubit.setStatus,
                          ),
                          filterControls: ColorsFilterBar.controls(
                            context,
                            state.query,
                            onStatusChanged: cubit.setStatus,
                          ),
                          sortOptions: ColorsFilterBar.sortOptions,
                          sorts: [
                            for (final sort in state.query.sorts)
                              FilterBarSort(sort.field.name, sort.ascending),
                          ],
                          onSortsChanged: (sorts) => cubit.setSorts(
                            mapFilterBarSorts<ColorSortField, ColorSort>(
                              sorts,
                              parse: ColorSortField.tryParse,
                              build: (field, ascending) =>
                                  ColorSort(field, ascending),
                            ),
                          ),
                          viewModes: _modes,
                          viewMode: mode,
                          onViewModeChanged: (nextMode) {
                            cubit.selection.clear();
                            context.read<ViewModeCubit>().select(nextMode);
                          },
                          onRefresh: cubit.refresh,
                          refreshing: state.isRefreshing,
                          selectionModeActive: state.selectionMode,
                          onSelectionModeToggle: canBulk
                              ? cubit.toggleSelectionMode
                              : null,
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
                        dataTable: CrudSelectionScope<CatalogColor>(
                          rows: rows,
                          rowId: (color) => color.id,
                          selection: cubit.selection,
                          permission: Permissions.masterData.manage,
                          selectionModeActive: state.selectionMode,
                          onSelectionModeExit: () => cubit.setSelectionMode(false),
                          actionsBuilder: (selected) =>
                              CrudBulkActions.statusAndDelete<CatalogColor>(
                                context: context,
                                permission: Permissions.masterData.manage,
                                selected: selected,
                                itemLabel: (color) => color.name,
                                activateLabelKey: ColorsKeys.bulkActivate,
                                deactivateLabelKey: ColorsKeys.bulkDeactivate,
                                deleteLabelKey: ColorsKeys.bulkDelete,
                                deactivateTitleKey:
                                    ColorsKeys.bulkDeactivateTitle,
                                deactivateMessageKey:
                                    ColorsKeys.bulkDeactivateMessage,
                                deleteTitleKey: ColorsKeys.bulkDeleteTitle,
                                deleteMessageKey: ColorsKeys.bulkDeleteMessage,
                                onActivate: cubit.bulkActivate,
                                onDeactivate: cubit.bulkDeactivate,
                                onDelete: cubit.bulkDelete,
                              ),
                          builder: (context, selectedIds, onSelectionChanged) =>
                              ColorsTableSection(
                                mode: mode,
                                onSort: (sort) {
                                  final field = ColorSortField.tryParse(
                                    sort.key,
                                  );
                                  if (field != null) {
                                    cubit.setSorts([
                                      ColorSort(field, sort.ascending),
                                    ]);
                                  }
                                },
                                onPageChanged: cubit.setPage,
                                query: state.query,
                                rows: rows,
                                total: total,
                                loading: loading,
                                refreshing: state.isRefreshing,
                                failure: failure,
                                onRetry: cubit.refresh,
                                addAction: addAction,
                                onEdit: (color) => _edit(context, color),
                                onDuplicate: (color) =>
                                    _duplicate(context, color),
                                onToggleStatus: (color) =>
                                    _status(context, color),
                                onDelete: (color) => _delete(context, color),
                                selectedIds: selectedIds,
                                onSelectionChanged: onSelectionChanged,
                              ),
                        ),
                      );
                    },
                  ),
            ),
      ),
    ),
  );

  Future<void> _edit(BuildContext context, [CatalogColor? color]) async {
    final saved = await showColorEditor(context, color: color);
    if (saved == true && context.mounted) {
      await context.read<ColorsListCubit>().onColorSaved(isNew: color == null);
    }
  }

  Future<void> _duplicate(BuildContext context, CatalogColor color) async {
    final saved = await showColorEditor(context, color: color, duplicate: true);
    if (saved == true && context.mounted) {
      await context.read<ColorsListCubit>().onColorSaved(isNew: true);
    }
  }

  Future<void> _delete(BuildContext context, CatalogColor color) async {
    final cubit = context.read<ColorsListCubit>();
    await CrudConfirmations.delete(
      context,
      titleKey: ColorsKeys.deleteTitle,
      messageKey: ColorsKeys.deleteMessage,
      messageArgs: {'name': color.name},
      targetName: color.name,
      onDelete: () => cubit.delete(color),
    );
  }

  Future<void> _status(BuildContext context, CatalogColor color) async {
    final cubit = context.read<ColorsListCubit>();
    await CrudConfirmations.status(
      context,
      isActive: color.isActive,
      targetName: color.name,
      titleKey: ColorsKeys.deactivateTitle,
      messageKey: ColorsKeys.deactivateMessage,
      onActivate: () => cubit.activate(color.id),
      onDeactivate: () => cubit.deactivate(color.id),
    );
  }
}
