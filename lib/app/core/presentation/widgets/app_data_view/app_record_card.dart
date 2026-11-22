import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_data_table/data_table.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// One record as a card: an optional selection box, the content, and the row
/// actions. The content is [cardBuilder] when given; otherwise the primary
/// column(s) followed by up to [maxSecondaryFields] labelled secondary ones.
///
/// Extracted from the old mobile layout of `AppDataTable`; presentation only.
class AppRecordCard<T> extends StatelessWidget {
  static const maxSecondaryFields = 3;

  const AppRecordCard({
    super.key,
    required this.row,
    required this.columns,
    this.cardBuilder,
    this.selected = false,
    this.onSelectionChanged,
    this.onTap,
    this.actions,
  });

  final T row;
  final List<DataTableColumn<T>> columns;
  final Widget Function(BuildContext context, T row)? cardBuilder;
  final bool selected;

  /// Not null = a checkbox is shown.
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onTap;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final style = DataTableStyle(context, density: AppDensity.comfortable);
    final visible = columns
        .where((c) => c.priority != DataTableColumnPriority.hiddenOnMobile)
        .toList();
    final declared = visible
        .where((c) => c.priority == DataTableColumnPriority.primary)
        .toList();
    final primary = declared.isEmpty && visible.isNotEmpty
        ? [visible.first]
        : declared;
    final secondary = visible
        .where(
          (c) =>
              c.priority == DataTableColumnPriority.secondary &&
              !primary.contains(c),
        )
        .take(maxSecondaryFields)
        .toList();

    return AppCard(
      padding: AppSpacing.md,
      selected: selected,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onSelectionChanged != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Checkbox(
                value: selected,
                onChanged: (checked) => onSelectionChanged!(checked ?? false),
              ),
            ),
          if (cardBuilder != null)
            cardBuilder!(context, row)
          else ...[
            for (final column in primary) column.cellBuilder(context, row),
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
                        maxLines: 2,
                      ),
                    ),
                    Expanded(flex: 2, child: column.cellBuilder(context, row)),
                  ],
                ),
              ),
          ],
          if (actions != null)
            Align(alignment: AlignmentDirectional.centerEnd, child: actions),
        ],
      ),
    );
  }
}
