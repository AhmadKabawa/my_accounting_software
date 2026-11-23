import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';

/// Records as tiles in a responsive grid. Each tile sizes to its own content;
/// selection and row actions are overlaid so they do not change the content's
/// available height when selection mode is toggled.
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
      builder: (context, constraints) {
        final gap = context.ui.spacing.md;
        final minTileWidth = context.ui.size.width(
          AppComponentSize.gridTileWidth,
        );
        final columns = math
            .max(
              1,
              ((constraints.maxWidth + gap) / (minTileWidth + gap)).floor(),
            )
            .toInt();
        final rowCount = (rows.length + columns - 1) ~/ columns;
        return ListView.separated(
          shrinkWrap: !constraints.hasBoundedHeight,
          physics: constraints.hasBoundedHeight
              ? null
              : const NeverScrollableScrollPhysics(),
          itemCount: rowCount,
          separatorBuilder: (_, _) => SizedBox(height: gap),
          itemBuilder: (context, rowIndex) {
            final start = rowIndex * columns;
            final end = math.min(start + columns, rows.length).toInt();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  for (var index = start; index < end; index++) ...[
                    if (index > start) SizedBox(width: gap),
                    Expanded(child: _tile(context, rows[index])),
                  ],
                  for (var empty = end; empty < start + columns; empty++) ...[
                    if (empty > start) SizedBox(width: gap),
                    const Expanded(child: SizedBox.shrink()),
                  ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _tile(BuildContext context, T row) {
    final id = rowId(row);
    final selected = selectedIds.contains(id);
    final hitArea = context.ui.size.height(AppComponentSize.hitArea);
    return AppCard(
      padding: AppSpacing.sm,
      selected: selected,
      onTap: onSelectionChanged != null
          ? () {
              final next = Set<Object>.from(selectedIds);
              selected ? next.remove(id) : next.add(id);
              onSelectionChanged!(next);
            }
          : onRowActivated == null
          ? null
          : () => onRowActivated!(row),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: hitArea),
            child: gridItemBuilder(context, row),
          ),
          if (onSelectionChanged != null)
            PositionedDirectional(
              top: 0,
              start: 0,
              child: Checkbox(
                value: selected,
                onChanged: (checked) {
                  final next = Set<Object>.from(selectedIds);
                  (checked ?? false) ? next.add(id) : next.remove(id);
                  onSelectionChanged!(next);
                },
              ),
            ),
          if (rowActionsBuilder != null)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: rowActionsBuilder!(context, row),
            ),
        ],
      ),
    );
  }
}
