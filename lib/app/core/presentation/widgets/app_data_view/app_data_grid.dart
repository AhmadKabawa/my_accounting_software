import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';

/// Records as tiles in a responsive grid. Each tile's content comes from the
/// screen's `gridItemBuilder`; selection and actions are added here, so the
/// builder never repeats them. Natural height inside a page scroll, own
/// scroll when the height is bounded.
class AppDataGrid<T> extends StatelessWidget {
  const AppDataGrid({
    super.key,
    required this.rows,
    required this.rowId,
    required this.gridItemBuilder,
    this.selectedIds = const {},
    this.onSelectionChanged,
    this.rowActionsBuilder,
    this.onRowActivated,
  });

  final List<T> rows;
  final Object Function(T row) rowId;
  final Widget Function(BuildContext context, T row) gridItemBuilder;
  final Set<Object> selectedIds;
  final ValueChanged<Set<Object>>? onSelectionChanged;
  final Widget Function(BuildContext context, T row)? rowActionsBuilder;
  final ValueChanged<T>? onRowActivated;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        shrinkWrap: !constraints.hasBoundedHeight,
        physics: constraints.hasBoundedHeight
            ? null
            : const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: context.ui.size.width(
            AppComponentSize.gridTileWidth,
          ),
          mainAxisExtent: context.ui.size.height(
            AppComponentSize.gridTileHeight,
          ),
          crossAxisSpacing: context.ui.spacing.md,
          mainAxisSpacing: context.ui.spacing.md,
        ),
        itemCount: rows.length,
        itemBuilder: (context, index) => _tile(context, rows[index]),
      ),
    );
  }

  Widget _tile(BuildContext context, T row) {
    final id = rowId(row);
    final selected = selectedIds.contains(id);
    return AppCard(
      padding: AppSpacing.sm,
      selected: selected,
      onTap: onRowActivated == null ? null : () => onRowActivated!(row),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onSelectionChanged != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Checkbox(
                value: selected,
                onChanged: (checked) {
                  final next = Set<Object>.from(selectedIds);
                  (checked ?? false) ? next.add(id) : next.remove(id);
                  onSelectionChanged!(next);
                },
              ),
            ),
          Expanded(child: gridItemBuilder(context, row)),
          if (rowActionsBuilder != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: rowActionsBuilder!(context, row),
            ),
        ],
      ),
    );
  }
}
