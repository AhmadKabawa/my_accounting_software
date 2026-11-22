import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';

/// Which table columns fit a container width. Pure logic, no widgets.
///
/// Rules (the container width is the only input; the screen type is not):
/// - The primary column is never hidden. If no column is declared primary the
///   first one is treated as primary.
/// - Columns drop one at a time until the rest fit: first
///   [DataTableColumnPriority.hiddenOnMobile] columns, then
///   [DataTableColumnPriority.secondary] ones; within the same priority the
///   column declared last drops first.
/// - Original column order is kept for the survivors.
abstract final class DataTableLayout {
  static List<DataTableColumn<T>> visibleColumns<T>(
    List<DataTableColumn<T>> columns, {
    required double availableWidth,
    required double minWidth,
    required double primaryMinWidth,
  }) {
    if (columns.isEmpty) return const [];
    final primaries = _primaries(columns);

    double widthOf(DataTableColumn<T> c) =>
        primaries.contains(c) ? primaryMinWidth : minWidth;

    final kept = List<DataTableColumn<T>>.of(columns);
    double total() => kept.fold(0, (sum, c) => sum + widthOf(c));

    final dropOrder = [
      ...columns.reversed.where(
        (c) =>
            !primaries.contains(c) &&
            c.priority == DataTableColumnPriority.hiddenOnMobile,
      ),
      ...columns.reversed.where(
        (c) =>
            !primaries.contains(c) &&
            c.priority != DataTableColumnPriority.hiddenOnMobile,
      ),
    ];
    for (final column in dropOrder) {
      if (total() <= availableWidth) break;
      kept.remove(column);
    }
    return kept;
  }

  static Set<DataTableColumn<T>> _primaries<T>(
    List<DataTableColumn<T>> columns,
  ) {
    final declared = columns
        .where((c) => c.priority == DataTableColumnPriority.primary)
        .toSet();
    return declared.isEmpty ? {columns.first} : declared;
  }
}
