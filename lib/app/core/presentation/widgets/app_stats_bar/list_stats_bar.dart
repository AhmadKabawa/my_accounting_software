import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stat_card/app_stat_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';

const double _minCardWidth = 180;
const AppSpacing _cardGap = AppSpacing.sm;

/// Responsive, wrapping statistics for CRUD list pages.
class ListStatsBar<F> extends StatelessWidget {
  const ListStatsBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.loading = false,
  });

  final List<StatItem<F>> items;
  final F? selected;
  final ValueChanged<F>? onSelected;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : context.ui.screen.width();
        final gap = _cardGap.of(context);
        final fit = ((availableWidth + gap) / (_minCardWidth + gap)).floor();
        final columns = math.max(2, math.min(items.length, fit)).toInt();
        final cardWidth = (availableWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          alignment: WrapAlignment.start,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: AppStatCard(
                  compact: true,
                  titleKey: item.labelKey,
                  value: loading ? null : item.value,
                  icon: item.icon,
                  tone: item.tone,
                  loading: loading,
                  selected:
                      !loading &&
                      item.filter != null &&
                      item.filter == selected,
                  onTap: !loading && item.filter != null && onSelected != null
                      ? () => onSelected!(item.filter as F)
                      : null,
                ),
              ),
          ],
        );
      },
    );
  }
}
