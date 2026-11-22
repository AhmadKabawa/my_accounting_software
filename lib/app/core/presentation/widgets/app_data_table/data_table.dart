import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table_layout.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

export 'data_table_layout.dart';
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

class DataTableSort {
  const DataTableSort(this.key, this.ascending);
  final String key;
  final bool ascending;
}

/// The table view of a record list: a soft header band and rows.
///
/// Table only. Loading, empty, error, refreshing, pagination and the other
/// view modes belong to `AppDataView`, which wraps this widget.
///
/// Columns are hidden progressively by priority and by the width of the
/// container ([DataTableLayout]); the primary column never hides. The screen
/// type plays no part here, so the table can never disagree with the shell.
/// The supplied [rows] are only the current server page: nothing is sorted,
/// filtered or paginated locally.
class AppDataTable<T> extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowId,
    this.sortKey,
    this.sortAscending = true,
    this.onSort,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActionsBuilder,
    this.onRowActivated,
    this.density,
    this.zebra = DataTableStyle.defaultZebra,
  });

  /// The columns that fit [width] once the selection and action tracks are
  /// reserved. `AppDataView` uses it to decide when a table is too narrow.
  static List<DataTableColumn<T>> visibleFor<T>(
    BuildContext context,
    List<DataTableColumn<T>> columns, {
    required double width,
    required bool hasSelection,
    required bool hasActions,
  }) {
    final hit = context.ui.size.width(AppComponentSize.hitArea);
    final reserved =
        (hasSelection ? hit : 0) + (hasActions ? hit * _actionTrackHits : 0);
    return DataTableLayout.visibleColumns(
      columns,
      availableWidth: width - reserved,
      minWidth: context.ui.size.width(AppComponentSize.tableColumnMin),
      primaryMinWidth: context.ui.size.width(
        AppComponentSize.tableColumnPrimaryMin,
      ),
    );
  }

  /// Two inline actions plus the overflow menu, with room to spare.
  static const _actionTrackHits = 4;

  final List<DataTableColumn<T>> columns;
  final List<T> rows;
  final Object Function(T row) rowId;
  final String? sortKey;
  final bool sortAscending;
  final ValueChanged<DataTableSort>? onSort;
  final Set<Object> selectedIds;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final Widget Function(BuildContext context, T row)? rowActionsBuilder;
  final ValueChanged<T>? onRowActivated;
  final AppDensity? density;
  final bool zebra;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Inside a page scroll the height is unbounded: natural height.
        final bounded = constraints.hasBoundedHeight;
        final effectiveDensity = density ?? AppDensity.comfortable;
        final visible = visibleFor(
          context,
          columns,
          width: constraints.maxWidth,
          hasSelection: onSelectionChanged != null,
          hasActions: rowActionsBuilder != null,
        );
        return AppDensityScope(
          density: effectiveDensity,
          child: _table(
            context,
            DataTableStyle(context, density: effectiveDensity, zebra: zebra),
            visible,
            bounded,
          ),
        );
      },
    );
  }

  Widget _table(
    BuildContext context,
    DataTableStyle style,
    List<DataTableColumn<T>> visible,
    bool bounded,
  ) {
    final hit = context.ui.size.width(AppComponentSize.hitArea);

    Widget cells(T? row, {required bool header}) => Row(
      children: [
        if (onSelectionChanged != null)
          SizedBox(
            width: hit,
            child: header
                ? Checkbox(
                    value:
                        rows.isNotEmpty &&
                        rows.every((r) => selectedIds.contains(rowId(r))),
                    onChanged: (value) => _toggleAll(value ?? false),
                  )
                : Checkbox(
                    value: selectedIds.contains(rowId(row as T)),
                    onChanged: (value) => _toggle(row, value ?? false),
                  ),
          ),
        for (final column in visible)
          Expanded(
            flex: column.flex,
            child: Padding(
              padding: style.cellPadding,
              child: header
                  ? _header(column, style)
                  : Align(
                      alignment: column.numeric
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: column.cellBuilder(context, row as T),
                    ),
            ),
          ),
        if (rowActionsBuilder != null)
          SizedBox(
            width: hit * _actionTrackHits,
            child: header
                ? const SizedBox.shrink()
                : Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: rowActionsBuilder!(context, row as T),
                  ),
          ),
      ],
    );

    final headerBand = Container(
      constraints: BoxConstraints(minHeight: style.headerHeight),
      decoration: BoxDecoration(
        color: style.headerBackground,
        borderRadius: style.bandRadius,
      ),
      child: cells(null, header: true),
    );

    final list = ListView.builder(
      shrinkWrap: !bounded,
      physics: bounded ? null : const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, index) =>
          _row(context, style, rows[index], index, cells),
    );

    return Column(
      mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        headerBand,
        context.ui.spacing.gap(AppSpacing.xs),
        if (bounded) Expanded(child: list) else list,
      ],
    );
  }

  Widget _header(DataTableColumn<T> column, DataTableStyle style) {
    final sorted = column.sortable && sortKey == column.sortKey;
    return Semantics(
      button: column.sortable,
      child: InkWell(
        onTap: column.sortable && onSort != null
            ? () => onSort!(
                DataTableSort(
                  column.sortKey!,
                  sortKey == column.sortKey ? !sortAscending : true,
                ),
              )
            : null,
        child: Row(
          children: [
            Flexible(
              child: AppText(
                column.labelKey,
                type: AppTextType.tableHeader,
                color: style.headerForeground,
                maxLines: 2,
              ),
            ),
            if (sorted)
              AppIcon(
                sortAscending
                    ? AppIcons.sortAscending
                    : AppIcons.sortDescending,
                size: AppIconSize.sm,
                color: style.headerForeground,
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    DataTableStyle style,
    T row,
    int index,
    Widget Function(T? row, {required bool header}) cells,
  ) {
    final selected = selectedIds.contains(rowId(row));
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
          if (onSelectionChanged != null) _toggle(row, !selected);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        container: true,
        selected: selected,
        child: Material(
          color: style.rowColor(index, selected: selected),
          borderRadius: style.bandRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            hoverColor: style.rowHover,
            onTap: onRowActivated == null ? null : () => onRowActivated!(row),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: style.rowHeight),
              child: cells(row, header: false),
            ),
          ),
        ),
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
