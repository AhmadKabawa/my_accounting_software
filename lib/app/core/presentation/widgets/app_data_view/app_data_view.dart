import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/compact_content_breakpoint.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_data_grid.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_pagination_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_record_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_view/app_view_mode.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';

export 'app_data_grid.dart';
export 'app_pagination_bar.dart';
export 'app_record_card.dart';
export 'app_view_mode.dart';
export 'view_mode_switcher.dart';

/// The one wrapper for a record list. It owns what the three view modes share:
/// loading, empty, error, refreshing, pagination, selection and sort. It hands
/// the same contract (columns, rows, selection, actions, sort) to
/// [AppDataTable], [AppRecordCard] and [AppDataGrid], so search, sort and
/// selection are never re-implemented per mode and survive a mode switch.
///
/// Contract: [columns] (always), [cardBuilder] (optional card content),
/// [gridItemBuilder] (optional; the grid mode exists only when given).
///
/// [mode] is the user's choice (`null` = none yet). With no choice the device
/// default follows the available content width when supplied by the page:
/// cards below [compactContentBreakpoint], table otherwise. Without a local
/// width, the device default from `ScreenEngine` is used.
///
/// Sorting and paging are server-driven callbacks; nothing is sorted or sliced
/// locally.
class AppDataView<T> extends StatelessWidget {
  static const _loadingPlaceholderCount = 5;

  const AppDataView({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowId,
    this.mode,
    this.cardBuilder,
    this.gridItemBuilder,
    this.loading = false,
    this.refreshing = false,
    this.errorKey,
    this.emptyState,
    this.onRetry,
    this.sortKey,
    this.sortAscending = true,
    this.onSort,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActionsBuilder,
    this.onRowActivated,
    this.summaryBuilder,
    this.page = 1,
    this.pageSize = AppConfig.defaultPageSize,
    this.totalCount = 0,
    this.onPageChanged,
    this.onPageSizeChanged,
    this.hasMore = false,
    this.onLoadMore,
    this.density,
    this.zebra = DataTableStyle.defaultZebra,
  });

  final List<DataTableColumn<T>> columns;
  final List<T> rows;
  final Object Function(T row) rowId;
  final AppViewMode? mode;
  final Widget Function(BuildContext context, T row)? cardBuilder;
  final Widget Function(BuildContext context, T row)? gridItemBuilder;
  final bool loading;
  final bool refreshing;
  final AppKey? errorKey;
  final Widget? emptyState;
  final VoidCallback? onRetry;
  final String? sortKey;
  final bool sortAscending;
  final ValueChanged<DataTableSort>? onSort;
  final Set<Object> selectedIds;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final Widget Function(BuildContext context, T row)? rowActionsBuilder;
  final ValueChanged<T>? onRowActivated;
  final Widget? summaryBuilder;
  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final AppDensity? density;
  final bool zebra;

  /// The modes this contract can render, in switcher order.
  List<AppViewMode> get supportedModes => [
    AppViewMode.table,
    AppViewMode.cards,
    if (gridItemBuilder != null) AppViewMode.grid,
  ];

  /// The mode actually shown for [context] and the current width.
  /// Public so the owner can mark the matching switcher button.
  static AppViewMode defaultModeFor(
    BuildContext context, {
    double? availableWidth,
  }) {
    if (availableWidth != null) {
      return availableWidth < compactContentBreakpoint
          ? AppViewMode.cards
          : AppViewMode.table;
    }
    return ScreenEngine.isMobile(context) ? AppViewMode.cards : AppViewMode.table;
  }

  @override
  Widget build(BuildContext context) {
    if (errorKey != null) return _error();
    if (loading) {
      return LayoutBuilder(
        builder: (context, constraints) => _loading(
          context,
          availableWidth: constraints.hasBoundedWidth ? constraints.maxWidth : null,
        ),
      );
    }
    if (rows.isEmpty) return emptyState ?? _defaultEmpty(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        final effective = _effectiveMode(context, constraints.maxWidth);
        final content = switch (effective) {
          AppViewMode.table => AppDataTable<T>(
            columns: columns,
            rows: rows,
            rowId: rowId,
            sortKey: sortKey,
            sortAscending: sortAscending,
            onSort: onSort,
            selectedIds: selectedIds,
            onSelectionChanged: onSelectionChanged,
            rowActionsBuilder: rowActionsBuilder,
            onRowActivated: onRowActivated,
            density: density,
            zebra: zebra,
          ),
          AppViewMode.cards => _cards(context, bounded),
          AppViewMode.grid => AppDataGrid<T>(
            rows: rows,
            rowId: rowId,
            gridItemBuilder: gridItemBuilder!,
            selectedIds: selectedIds,
            onSelectionChanged: onSelectionChanged,
            rowActionsBuilder: rowActionsBuilder,
            onRowActivated: onRowActivated,
          ),
        };
        return Column(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (refreshing) const LinearProgressIndicator(),
            if (bounded) Expanded(child: content) else content,
            ?summaryBuilder,
            context.ui.spacing.gap(AppSpacing.sm),
            _pagination(
              context,
              constraints.hasBoundedWidth ? constraints.maxWidth : null,
            ),
          ],
        );
      },
    );
  }

  AppViewMode _effectiveMode(BuildContext context, double width) {
    final supported = supportedModes;
    final chosen = mode;
    if (chosen != null && supported.contains(chosen)) return chosen;
    final fallback = defaultModeFor(context, availableWidth: width);
    if (fallback == AppViewMode.table && columns.length > 1) {
      final fit = AppDataTable.visibleFor<T>(
        context,
        columns,
        width: width,
        hasSelection: onSelectionChanged != null,
        hasActions: rowActionsBuilder != null,
      );
      if (fit.length < 2) return AppViewMode.cards;
    }
    return fallback;
  }

  Widget _cards(BuildContext context, bool bounded) {
    final gap = context.ui.spacing.md;
    return ListView.separated(
      shrinkWrap: !bounded,
      physics: bounded ? null : const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, _) => SizedBox(height: gap),
      itemBuilder: (context, index) {
        final row = rows[index];
        final id = rowId(row);
        return AppRecordCard<T>(
          row: row,
          columns: columns,
          cardBuilder: cardBuilder,
          selected: selectedIds.contains(id),
          onSelectionChanged: onSelectionChanged == null
              ? null
              : (checked) {
                  final next = Set<Object>.from(selectedIds);
                  checked ? next.add(id) : next.remove(id);
                  onSelectionChanged!(next);
                },
          onTap: onRowActivated == null ? null : () => onRowActivated!(row),
          actions: rowActionsBuilder?.call(context, row),
        );
      },
    );
  }

  Widget _pagination(BuildContext context, double? availableWidth) {
    final hasPaging =
        onPageChanged != null ||
        onPageSizeChanged != null ||
        onLoadMore != null;
    if (!hasPaging) return const SizedBox.shrink();
    return AppPaginationBar(
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      shownCount: rows.length,
      onPageChanged: onPageChanged,
      onPageSizeChanged: onPageSizeChanged,
      hasMore: hasMore,
      onLoadMore: onLoadMore,
      // Phones page by "load more" only when the owner supports it; otherwise
      // they keep the numbered pages rather than lose paging.
      mobile: onLoadMore != null &&
          (availableWidth != null
              ? availableWidth < compactContentBreakpoint
              : ScreenEngine.isMobile(context)),
      availableWidth: onLoadMore != null ? availableWidth : null,
    );
  }

  Widget _error() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      InlineBanner(messageKey: errorKey!, variant: InlineBannerVariant.error),
      if (onRetry != null)
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: AppButton(CatalogUiKeys.retry, onPressed: onRetry),
        ),
    ],
  );

  /// Loading respects the view mode: rows for the table, tiles otherwise.
  Widget _loading(BuildContext context, {double? availableWidth}) {
    final selected = mode;
    final effective = selected != null && supportedModes.contains(selected)
        ? selected
        : defaultModeFor(context, availableWidth: availableWidth);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _loadingPlaceholderCount; i++)
          effective == AppViewMode.table
              ? const AppSkeleton.tableRow()
              : Padding(
                  padding: EdgeInsets.only(bottom: context.ui.spacing.md),
                  child: const AppSkeleton.card(),
                ),
      ],
    );
  }

  Widget _defaultEmpty(BuildContext context) => AppEmptyState(
    icon: AppIcons.info,
    titleKey: CatalogUiKeys.emptyTitle,
    descriptionKey: CatalogUiKeys.emptyDescription,
    compact: !ScreenEngine.isMobile(context),
  );
}
