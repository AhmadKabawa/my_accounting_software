import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/foundation/config/app_config.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_empty_state/app_empty_state.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_searchable_dropdown/searchable_dropdown.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_skeleton/app_skeleton.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

export 'data_table_style.dart';

enum DataTableColumnPriority { primary, secondary, hiddenOnMobile }

/// Column metadata is independent of the row model and data source.
class DataTableColumn<T> {
  const DataTableColumn({
    required this.labelKey,
    required this.cellBuilder,
    this.sortKey,
    this.priority = DataTableColumnPriority.secondary,
    this.flex = 1,
    this.numeric = false,
  });

  final AppKey labelKey;
  final Widget Function(BuildContext context, T row) cellBuilder;
  final String? sortKey;
  final DataTableColumnPriority priority;
  final int flex;
  final bool numeric;
  bool get sortable => sortKey != null;
}

/// Responsive table with server-driven sort and pagination callbacks.
///
/// The supplied [rows] are only the current server page. This widget never
/// sorts, filters, or paginates the complete collection locally.
class AppDataTable<T> extends StatelessWidget {
  static const _loadingPlaceholderCount = 5;
  static const _maxSecondaryCardFields = 3;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowId,
    this.loading = false,
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
    this.cardBuilder,
    this.summaryBuilder,
    this.page = 1,
    this.pageSize = AppConfig.defaultPageSize,
    this.totalCount = 0,
    this.onPageChanged,
    this.onPageSizeChanged,
    this.hasMore = false,
    this.onLoadMore,
    this.density,
  });

  final List<DataTableColumn<T>> columns;
  final List<T> rows;
  final Object Function(T row) rowId;
  final bool loading;
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
  final Widget Function(BuildContext context, T row)? cardBuilder;
  final Widget? summaryBuilder;
  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final AppDensity? density;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = ScreenEngine.screenTypeForWidth(constraints.maxWidth);
        final effectiveDensity = density ??
            (type == ScreenType.desktop ? AppDensity.compact : AppDensity.comfortable);
        return AppDensityScope(
          density: effectiveDensity,
          child: _buildForWidth(context, type, effectiveDensity),
        );
      },
    );
  }

  Widget _buildForWidth(
    BuildContext context,
    ScreenType type,
    AppDensity density,
  ) {
    if (errorKey != null) {
      return Column(
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
    }
    if (loading) return _loading(context);
    if (rows.isEmpty) {
      return emptyState ?? AppEmptyState(
        icon: AppIcons.info,
        titleKey: CatalogUiKeys.emptyTitle,
        descriptionKey: CatalogUiKeys.emptyDescription,
        compact: type != ScreenType.mobile,
      );
    }
    final style = DataTableStyle(context, density: density);
    if (type == ScreenType.mobile) return _cards(context, style);
    return _table(context, style, full: type == ScreenType.desktop);
  }

  Widget _loading(BuildContext context) => ListView(
    shrinkWrap: true,
    children: [
      for (var i = 0; i < _loadingPlaceholderCount; i++)
        const AppSkeleton.tableRow(),
    ],
  );

  Widget _cards(BuildContext context, DataTableStyle style) {
    final visible = columns.where((c) => c.priority != DataTableColumnPriority.hiddenOnMobile).toList();
    final declaredPrimary = visible.where((c) => c.priority == DataTableColumnPriority.primary).toList();
    final primary = declaredPrimary.isEmpty && visible.isNotEmpty
        ? [visible.first]
        : declaredPrimary;
    final secondary = visible
        .where((c) => c.priority == DataTableColumnPriority.secondary && !primary.contains(c))
        .take(_maxSecondaryCardFields)
        .toList();
    return ListView(
      children: [
        for (final row in rows)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: style.gap),
            child: AppCard(
              padding: AppSpacing.md,
              onTap: onRowActivated == null ? null : () => onRowActivated!(row),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (onSelectionChanged != null)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Checkbox(
                          value: selectedIds.contains(rowId(row)),
                          onChanged: (checked) => _toggle(row, checked ?? false),
                        ),
                      ),
                    if (cardBuilder != null)
                      cardBuilder!(context, row)
                    else ...[
                      for (final column in primary)
                        column.cellBuilder(context, row),
                      for (final column in secondary)
                        Padding(
                          padding: EdgeInsets.only(top: style.gap),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppText(
                                  column.labelKey,
                                  type: AppTextType.labelSmall,
                                  color: style.colors.onSurfaceVariant,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: column.cellBuilder(context, row),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (rowActionsBuilder != null)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: rowActionsBuilder!(context, row),
                      ),
                  ],
                ),
              ),
            ),
        if (summaryBuilder != null) summaryBuilder!,
        _pagination(context, mobile: true),
      ],
    );
  }

  Widget _table(BuildContext context, DataTableStyle style, {required bool full}) {
    final visible = columns.where((c) => full || c.priority != DataTableColumnPriority.secondary).toList();
    if (!full && visible.isEmpty && columns.isNotEmpty) visible.add(columns.first);
    Widget cells(T? row, {required bool header}) => Row(
      children: [
        if (onSelectionChanged != null)
          SizedBox(
            width: context.ui.size.width(AppComponentSize.hitArea),
            child: header
                ? Checkbox(
                    value: rows.isNotEmpty && rows.every((r) => selectedIds.contains(rowId(r))),
                    onChanged: (value) => _toggleAll(value ?? false),
                  )
                : Checkbox(
                    value: selectedIds.contains(rowId(row!)),
                    onChanged: (value) => _toggle(row as T, value ?? false),
                  ),
          ),
        for (final column in visible)
          Expanded(
            flex: column.flex,
            child: Padding(
              padding: style.cellPadding,
              child: header
                  ? Semantics(
                      button: column.sortable,
                      child: InkWell(
                        onTap: column.sortable && onSort != null
                            ? () => onSort!(DataTableSort(column.sortKey!, sortKey == column.sortKey ? !sortAscending : true))
                            : null,
                        child: Row(
                          children: [
                            Expanded(child: AppText(column.labelKey, type: AppTextType.tableHeader, weight: FontWeight.w600)),
                            if (column.sortable && sortKey == column.sortKey)
                              AppIcon(sortAscending ? AppIcons.sortAscending : AppIcons.sortDescending, size: AppIconSize.sm),
                          ],
                        ),
                      ),
                    )
                  : Align(
                      alignment: column.numeric
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: column.cellBuilder(context, row as T),
                    ),
            ),
          ),
        if (rowActionsBuilder != null)
          Expanded(flex: 1, child: header ? const SizedBox.shrink() : rowActionsBuilder!(context, row as T)),
      ],
    );

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(minHeight: style.headerHeight),
          decoration: BoxDecoration(
            color: style.colors.surfaceContainerHighest,
            border: Border(bottom: BorderSide(color: style.divider)),
          ),
          child: cells(null, header: true),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => Divider(height: AppBorderWidth.thin.of(context), color: style.divider),
            itemBuilder: (context, index) {
              final row = rows[index];
              return Focus(
                canRequestFocus: true,
                onKeyEvent: (node, event) {
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    node.nextFocus();
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    node.previousFocus();
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    onRowActivated?.call(row);
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.space) {
                    if (onSelectionChanged != null) {
                      _toggle(row, !selectedIds.contains(rowId(row)));
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Semantics(
                  container: true,
                  selected: selectedIds.contains(rowId(row)),
                  child: InkWell(
                    onTap: onRowActivated == null
                        ? null
                        : () => onRowActivated!(row),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: style.rowHeight),
                      child: cells(row, header: false),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (summaryBuilder != null) summaryBuilder!,
        _pagination(context),
      ],
    );
  }

  Widget _pagination(BuildContext context, {bool mobile = false}) {
    if (mobile) {
      if (!hasMore || onLoadMore == null) return const SizedBox.shrink();
      return Padding(
        padding: context.ui.padding.symmetric(vertical: AppSpacing.sm),
        child: AppButton(CatalogUiKeys.loadMore, onPressed: onLoadMore),
      );
    }
    if (onPageChanged == null && onPageSizeChanged == null) return const SizedBox.shrink();
    final lastPage = totalCount == 0 ? 1 : (totalCount / pageSize).ceil();
    return Padding(
      padding: context.ui.padding.symmetric(vertical: AppSpacing.sm),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: context.ui.spacing.md,
        runSpacing: context.ui.spacing.sm,
        children: [
          if (onPageSizeChanged != null)
            SizedBox(
              width: context.ui.size.width(AppComponentSize.cardWidth),
              child: SearchableDropdown<int>(
                options: AppConfig.pageSizeOptions,
                labelKey: CatalogUiKeys.rowsPerPage,
                optionLabel: (value) => value.toString(),
                value: pageSize,
                onChanged: (value) { if (value != null) onPageSizeChanged!(value); },
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                CatalogUiKeys.previousPage,
                size: AppButtonSize.small,
                variant: AppButtonVariant.outlined,
                onPressed: page > 1 && onPageChanged != null ? () => onPageChanged!(page - 1) : null,
              ),
              Padding(
                padding: context.ui.padding.symmetric(horizontal: AppSpacing.sm),
                child: AppText.raw('${CatalogUiKeys.page.tr(context: context)} $page ${CatalogUiKeys.of.tr(context: context)} $lastPage'),
              ),
              AppButton(
                CatalogUiKeys.nextPage,
                size: AppButtonSize.small,
                variant: AppButtonVariant.outlined,
                onPressed: page < lastPage && onPageChanged != null ? () => onPageChanged!(page + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggle(T row, bool selected) {
    final callback = onSelectionChanged;
    if (callback == null) return;
    final next = Set<Object>.from(selectedIds);
    selected ? next.add(rowId(row)) : next.remove(rowId(row));
    callback(next);
  }

  void _toggleAll(bool selected) {
    final callback = onSelectionChanged;
    if (callback == null) return;
    final next = Set<Object>.from(selectedIds);
    for (final row in rows) {
      selected ? next.add(rowId(row)) : next.remove(rowId(row));
    }
    callback(next);
  }
}

class DataTableSort {
  const DataTableSort(this.key, this.ascending);
  final String key;
  final bool ascending;
}
