import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/crud_bulk_actions.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/crud_selection_scope.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/crud_confirmations.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/storage/shared_preferences/app_settings_manager.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_filter_bar/filter_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_toolbar_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brand_stats/brand_stats_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_cubit.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_effect.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/cubit/brands_list/brands_list_state.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/sections/brands_table_section.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/dialogs/brand_editor_dialog.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_stats_bar.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brands_filter_bar.dart';
import 'package:accounting_software/app/features/catalog/presentation/routing/catalog_routes.dart';

class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  /// Id under which the chosen view mode is remembered.
  static const screenId = 'catalog.brands';

  static const _modes = [
    AppViewMode.table,
    AppViewMode.cards,
    AppViewMode.grid,
  ];

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<BrandsListCubit>()..load()),
      BlocProvider(create: (_) => sl<BrandStatsCubit>()..load()),
      BlocProvider(
        create: (_) => ViewModeCubit(
          settings: sl<AppSettingsManager>(),
          screenId: screenId,
        )..restore(),
      ),
    ],
    child: BlocEffectListener<BrandsListEffect, BrandsListCubit>(
      onEffect: (context, effect) {
        if (effect is BrandsMutatedEffect) {
          context.read<BrandStatsCubit>().refresh();
        }
      },
      child: BlocBuilder<ViewModeCubit, AppViewMode?>(
        builder: (context, mode) =>
            BlocBuilder<BrandStatsCubit, BrandStatsState>(
              builder: (context, statsState) =>
                  BlocBuilder<BrandsListCubit, BrandsListState>(
                    builder: (context, state) {
                      final cubit = context.read<BrandsListCubit>();
                      final page = state.result;
                      final query = state.query;
                      final rows = page?.items ?? const <Brand>[];
                      final total = page?.totalCount ?? 0;
                      final failure = state.hasData ? null : state.failure;
                      final refreshFailure = state.hasData
                          ? state.failure
                          : null;
                      final loading = state.isInitialLoading;
                      final refreshing = state.isRefreshing;
                      final addAction = ListAddAction(
                        labelKey: BrandsKeys.add,
                        permission: Permissions.masterData.manage,
                        onPressed: () => _edit(context),
                      );

                      return ListPageTemplate(
                        titleKey: BrandsKeys.title,
                        breadcrumb: AppBreadcrumb(
                          items: [
                            AppBreadcrumbItem(
                              label: NavKeys.catalog,
                              onTap: () => context.go(CatalogRoutes.hub.path),
                            ),
                            const AppBreadcrumbItem(label: BrandsKeys.title),
                          ],
                        ),
                        stats: BrandStatsBar(
                          statsState.stats,
                          onFilterSelected: cubit.setStatus,
                          selectedFilter: query.status,
                          loading:
                              statsState is BrandStatsInitial ||
                              statsState is BrandStatsLoading,
                        ),
                        toolbar: ListToolbarConfig(
                          searchHintKey: BrandsKeys.searchHint,
                          onSearchChanged: cubit.searchChanged,
                          onClearAll: cubit.clearFilters,
                          activeFilters: BrandsFilterBar.activeFilters(
                            context,
                            query,
                            onSearchChanged: cubit.searchChanged,
                            onStatusChanged: cubit.setStatus,
                          ),
                          filterControls: BrandsFilterBar.controls(
                            context,
                            query,
                            onStatusChanged: cubit.setStatus,
                          ),
                          // Sort and filters are answered by the database.
                          sortOptions: BrandsFilterBar.sortOptions,
                          sorts: [
                            for (final sort in query.sorts)
                              FilterBarSort(sort.field.name, sort.ascending),
                          ],
                          onSortsChanged: (sorts) => cubit.setSorts(
                            mapFilterBarSorts<BrandSortField, BrandSort>(
                              sorts,
                              parse: BrandSortField.tryParse,
                              build: (field, ascending) => BrandSort(field, ascending),
                            ),
                          ),
                          viewModes: _modes,
                          viewMode: mode,
                          onViewModeChanged: context
                              .read<ViewModeCubit>()
                              .select,
                          onRefresh: cubit.refresh,
                          refreshing: state.isRefreshing,
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
                        dataTable: CrudSelectionScope<Brand>(
                          rows: rows,
                          rowId: (brand) => brand.id,
                          selection: cubit.selection,
                          permission: Permissions.masterData.manage,
                          actionsBuilder: (selected) =>
                              CrudBulkActions.statusAndDelete<Brand>(
                                context: context,
                                permission: Permissions.masterData.manage,
                                selected: selected,
                                itemLabel: (brand) => brand.name,
                                activateLabelKey: BrandsKeys.bulkActivate,
                                deactivateLabelKey: BrandsKeys.bulkDeactivate,
                                deleteLabelKey: BrandsKeys.bulkDelete,
                                deactivateTitleKey: BrandsKeys.bulkDeactivateTitle,
                                deactivateMessageKey: BrandsKeys.bulkDeactivateMessage,
                                deleteTitleKey: BrandsKeys.bulkDeleteTitle,
                                deleteMessageKey: BrandsKeys.bulkDeleteMessage,
                                onActivate: cubit.bulkActivate,
                                onDeactivate: cubit.bulkDeactivate,
                                onDelete: cubit.bulkDelete,
                              ),
                          builder: (context, selectedIds, onSelectionChanged) =>
                              BrandsTableSection(
                                mode: mode,
                                query: query,
                                onRetry: cubit.refresh,
                                onSort: (sort) => cubit.setSort(
                                  field: BrandSortField.tryParse(sort.key),
                                  ascending: sort.ascending,
                                ),
                                onPageChanged: cubit.setPage,
                                rows: rows,
                                total: total,
                                loading: loading,
                                refreshing: refreshing,
                                failure: failure,
                                addAction: addAction,
                                onDuplicate: (brand) => _duplicate(context, brand),
                                selectedIds: selectedIds,
                                onSelectionChanged: onSelectionChanged,
                                onEdit: (brand) => _edit(context, brand),
                                onDelete: (brand) => _delete(context, brand),
                                onToggleStatus: (brand) => _status(context, brand),
                              ),
                        ),
                      );
                    },
                  ),
            ),
      ),
    ),
  );

  Future<void> _edit(BuildContext context, [Brand? brand]) async {
    final saved = await showBrandEditor(context, brand: brand);
    if (saved == true && context.mounted) {
      await context.read<BrandsListCubit>().onBrandSaved(isNew: brand == null);
    }
  }

  Future<void> _duplicate(BuildContext context, Brand brand) async {
    final saved = await showBrandEditor(context, brand: brand, duplicate: true);
    if (saved == true && context.mounted) {
      await context.read<BrandsListCubit>().onBrandSaved(isNew: true);
    }
  }

  Future<void> _delete(BuildContext context, Brand brand) async {
    final cubit = context.read<BrandsListCubit>();
    await CrudConfirmations.delete(
      context,
      titleKey: BrandsKeys.delete,
      messageKey: BrandsKeys.confirmDelete,
      targetName: brand.name,
      onDelete: () => cubit.delete(brand),
    );
  }

  Future<void> _status(BuildContext context, Brand brand) async {
    final cubit = context.read<BrandsListCubit>();
    await CrudConfirmations.status(
      context,
      isActive: brand.isActive,
      targetName: brand.name,
      titleKey: BrandsKeys.deactivateTitle,
      messageKey: BrandsKeys.deactivateMessage,
      onActivate: () => cubit.activate(brand.id),
      onDeactivate: () => cubit.deactivate(brand.id),
    );
  }
}
