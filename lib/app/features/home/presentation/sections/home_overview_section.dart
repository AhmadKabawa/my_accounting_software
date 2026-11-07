import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/support/home_format.dart';

/// The four headline figures, laid out in as many columns as the screen allows.
class HomeOverviewSection extends StatelessWidget {
  const HomeOverviewSection({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tiles = <Widget>[
      _KpiTile(
        label: HomeKeys.cashBalance,
        value: summary.cashBalance,
        icon: AppIcons.cash,
        color: scheme.primary,
      ),
      _KpiTile(
        label: HomeKeys.monthSales,
        value: summary.monthSales,
        icon: AppIcons.trendUp,
        color: scheme.tertiary,
      ),
      _KpiTile(
        label: HomeKeys.receivables,
        value: summary.receivables,
        icon: AppIcons.receivable,
        color: scheme.secondary,
      ),
      _KpiTile(
        label: HomeKeys.payables,
        value: summary.payables,
        icon: AppIcons.payable,
        color: scheme.error,
      ),
    ];

    final columns = context.ui.grid.crossAxisCount();
    final gap = context.ui.spacing.gap(AppSpacing.md, axis: Axis.horizontal);
    final rows = <Widget>[];
    for (var start = 0; start < tiles.length; start += columns) {
      final slice = tiles.skip(start).take(columns).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < columns; i++) ...[
              if (i > 0) gap,
              Expanded(child: i < slice.length ? slice[i] : const SizedBox()),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            context.ui.spacing.gap(AppSpacing.md, axis: Axis.vertical),
          rows[i],
        ],
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final AppKey label;
  final num value;
  final AppIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(icon, color: color),
              context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
              Expanded(
                child: AppText(
                  label,
                  type: AppTextType.labelMedium,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          context.ui.spacing.gap(AppSpacing.sm, axis: Axis.vertical),
          AppText.raw(
            formatAmount(value),
            type: AppTextType.titleLarge,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
