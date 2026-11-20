import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/features/catalog/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';

/// Compact summary: three small badges in one wrapping row (not big cards).
class BrandStatsBar extends StatelessWidget {
  const BrandStatsBar(this.stats, {super.key});
  final BrandStats stats;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: context.ui.spacing.sm,
    runSpacing: context.ui.spacing.sm,
    children: [
      _badge(
        context,
        BrandsKeys.totalBrands,
        stats.total,
        AppBadgeTone.neutral,
      ),
      _badge(
        context,
        BrandsKeys.activeBrands,
        stats.active,
        AppBadgeTone.success,
      ),
      _badge(
        context,
        BrandsKeys.inactiveBrands,
        stats.inactive,
        AppBadgeTone.neutral,
      ),
    ],
  );

  Widget _badge(
    BuildContext context,
    BrandsKeys label,
    int value,
    AppBadgeTone tone,
  ) => AppBadge(
    label: BrandsKeys.statLabel,
    labelArgs: {
      'label': label.tr(context: context),
      'value': value.toString(),
    },
    tone: tone,
  );
}
