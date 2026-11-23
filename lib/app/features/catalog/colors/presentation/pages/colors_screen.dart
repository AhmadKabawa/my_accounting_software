import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:accounting_software/app/core/access/cubit/access_cubit.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/di/service_locator.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/keys/nav_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/state_management/bloc_effect_listener.dart';
import 'package:accounting_software/app/core/presentation/state_management/list_selection_cubit.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/bulk_result.dart';
import 'package:accounting_software/app/core/presentation/state_management/paged_list/paged_list_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_breadcrumb/app_breadcrumb.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_bulk_action_bar/bulk_action_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_confirm_dialog/confirm_dialog.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/app_page_templates.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_add_action.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_page_template/list_toolbar_config.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
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
  static const _modes = [AppViewMode.table, AppViewMode.cards, AppViewMode.grid];

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
        builder: (context, mode) => BlocBuilder<ColorStatsCubit, ColorStatsState>(
          builder: (context, statsState) =>
              BlocBuilder<ColorsListCubit, PagedListState<CatalogColor, ColorListQuery>>(
            builder: (context, state) {
              final cubit = context.read<ColorsListCubit>();
              final rows = state.result?.items ?? const <CatalogColor>[];
              final total = state.result?.totalCount ?? 0;
              final loading = state.isInitialLoading;
              final failure = state.hasData ? null : state.failure;
              final refreshFailure = state.hasData ? state.failure : null;
              final addAction = ListAddAction(
                labelKey: ColorsKeys.add,
                permission: Permissions.masterData.manage,
                onPressed: () => _edit(context),
              );
              return ListPageTemplate(
                titleKey: ColorsKeys.title,
                breadcrumb: AppBreadcrumb(items: [
                  AppBreadcrumbItem(
                    label: NavKeys.catalog,
                    onTap: () => context.go(CatalogRoutes.hub.path),
                  ),
                  const AppBreadcrumbItem(label: ColorsKeys.title),
                ]),
                count: total,
                stats: ColorStatsSection(
                  stats: statsState.stats,
                  selectedFilter: state.query.status,
                  onStatusSelected: cubit.setStatus,
                  loading: statsState.status == ColorStatsStatus.loading ||
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
                  onSortsChanged: (sorts) => cubit.setSorts([
                    for (final sort in sorts)
                      if (ColorSortField.tryParse(sort.key) != null)
                        ColorSort(ColorSortField.tryParse(sort.key)!, sort.ascending),
                  ]),
                  viewModes: _modes,
                  viewMode: mode,
                  onViewModeChanged: context.read<ViewModeCubit>().select,
                  onRefresh: cubit.refresh,
                  refreshing: state.isRefreshing,
                ),
                addAction: addAction,
                loadingViewMode: mode ?? AppViewMode.table,
                state: loading
                    ? AppPageState.loading
                    : failure != null
                        ? AppPageState.error
                        : AppPageState.content,
                errorKey: failure?.messageKey,
                refreshErrorKey: refreshFailure?.messageKey,
                onRetry: cubit.refresh,
                dataTable: BlocBuilder<ListSelectionCubit<Object>, Set<Object>>(
                  bloc: cubit.selection,
                  builder: (context, selectedIds) {
                    final access = context.watch<AccessCubit>().state;
                    final canBulk = access.isReady &&
                        access.snapshot!.permissions.any(
                          (granted) => granted.covers(Permissions.masterData.manage),
                        );
                    final selectedColors = rows
                        .where((color) => selectedIds.contains(color.id))
                        .toList(growable: false);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (canBulk && selectedColors.isNotEmpty)
                          BulkActionBar(
                            selectedCount: selectedColors.length,
                            onClear: cubit.selection.clear,
                            actions: [
                              BulkAction(
                                labelKey: ColorsKeys.bulkActivate,
                                icon: AppIcons.refresh,
                                permission: Permissions.masterData.manage,
                                onRun: () async {
                                  final result = await cubit.bulkActivate(selectedColors);
                                  await _showBulkResult(context, result);
                                },
                              ),
                              BulkAction(
                                labelKey: ColorsKeys.bulkDeactivate,
                                icon: AppIcons.refresh,
                                permission: Permissions.masterData.manage,
                                confirm: (ctx, count) => showConfirmDialog(
                                  ctx,
                                  titleKey: ColorsKeys.bulkDeactivateTitle,
                                  messageKey: ColorsKeys.bulkDeactivateMessage,
                                  messageArgs: {'count': count.toString()},
                                  severity: ConfirmDialogSeverity.warning,
                                ),
                                onRun: () async {
                                  final result = await cubit.bulkDeactivate(selectedColors);
                                  await _showBulkResult(context, result);
                                },
                              ),
                              BulkAction(
                                labelKey: ColorsKeys.bulkDelete,
                                icon: AppIcons.delete,
                                permission: Permissions.masterData.manage,
                                destructive: true,
                                confirm: (ctx, count) => showConfirmDialog(
                                  ctx,
                                  titleKey: ColorsKeys.bulkDeleteTitle,
                                  messageKey: ColorsKeys.bulkDeleteMessage,
                                  messageArgs: {'count': count.toString()},
                                  severity: ConfirmDialogSeverity.critical,
                                ),
                                onRun: () async {
                                  final result = await cubit.bulkDelete(selectedColors);
                                  await _showBulkResult(context, result);
                                },
                              ),
                            ],
                          ),
                        if (canBulk && selectedColors.isNotEmpty)
                          context.ui.spacing.gap(AppSpacing.sm),
                        ColorsTableSection(
                          mode: mode,
                          onRetry: cubit.refresh,
                          onSort: (sort) {
                            final field = ColorSortField.tryParse(sort.key);
                            if (field != null) {
                              cubit.setSorts([ColorSort(field, sort.ascending)]);
                            }
                          },
                          onPageChanged: cubit.setPage,
                          query: state.query,
                          rows: rows,
                          total: total,
                          loading: loading,
                          refreshing: state.isRefreshing,
                          failure: failure,
                          addAction: addAction,
                          onEdit: (color) => _edit(context, color),
                          onDuplicate: (color) => _duplicate(context, color),
                          onToggleStatus: (color) => _status(context, color),
                          onDelete: (color) => _delete(context, color),
                          selectedIds: canBulk ? selectedIds : const {},
                          onSelectionChanged: canBulk ? cubit.selection.replace : null,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Future<void> _showBulkResult(
    BuildContext context,
    BulkResult<CatalogColor> result,
  ) async {
    if (result.failureCount == 0 || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppText(CatalogUiKeys.bulkResultTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.raw(CatalogUiKeys.bulkResultSummary.tr(
                context: dialogContext,
                namedArgs: {
                  'success': result.successCount.toString(),
                  'failure': result.failureCount.toString(),
                },
              )),
              for (final failure in result.failures)
                Padding(
                  padding: EdgeInsets.only(top: dialogContext.ui.spacing.xs),
                  child: AppText.raw(CatalogUiKeys.bulkFailureLine.tr(
                    context: dialogContext,
                    namedArgs: {
                      'name': failure.item.name,
                      'reason': failure.reason.messageKey.tr(context: dialogContext),
                    },
                  )),
                ),
            ],
          ),
        ),
        actions: [
          AppButton(CatalogUiKeys.done, onPressed: () => Navigator.of(dialogContext).pop()),
        ],
      ),
    );
  }

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
    await showConfirmDialog(
      context,
      titleKey: ColorsKeys.deleteTitle,
      messageKey: ColorsKeys.deleteMessage,
      messageArgs: {'name': color.name},
      severity: ConfirmDialogSeverity.critical,
      targetName: color.name,
      onConfirm: () async {
        final result = await cubit.delete(color);
        return result.fold((failure) => failure.messageKey, (_) => null);
      },
    );
  }

  Future<void> _status(BuildContext context, CatalogColor color) async {
    final cubit = context.read<ColorsListCubit>();
    if (!color.isActive) {
      final result = await cubit.activate(color.id);
      return;
    }
    await showConfirmDialog(
      context,
      titleKey: ColorsKeys.deactivateTitle,
      messageKey: ColorsKeys.deactivateMessage,
      severity: ConfirmDialogSeverity.warning,
      targetName: color.name,
      onConfirm: () async {
        final result = await cubit.deactivate(color.id);
        return result.fold((failure) => failure.messageKey, (_) => null);
      },
    );
  }
}
