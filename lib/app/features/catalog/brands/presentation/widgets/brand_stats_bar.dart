import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_list_query.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand_stats.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';

/// Clickable server-derived counters; selecting one applies its list filter.
class BrandStatsBar extends StatelessWidget {
  const BrandStatsBar(
    this.stats, {
    super.key,
    required this.onFilterSelected,
    this.selectedFilter = BrandStatusFilter.all,
  });

  final BrandStats stats;
  final ValueChanged<BrandStatusFilter> onFilterSelected;
  final BrandStatusFilter selectedFilter;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: context.ui.spacing.sm,
    runSpacing: context.ui.spacing.sm,
    children: [
      _card(
        context,
        BrandsKeys.totalBrands,
        stats.total,
        BrandStatusFilter.all,
        selectedFilter == BrandStatusFilter.all,
      ),
      _card(
        context,
        BrandsKeys.activeBrands,
        stats.active,
        BrandStatusFilter.active,
        selectedFilter == BrandStatusFilter.active,
      ),
      _card(
        context,
        BrandsKeys.inactiveBrands,
        stats.inactive,
        BrandStatusFilter.inactive,
        selectedFilter == BrandStatusFilter.inactive,
      ),
    ],
  );

  Widget _card(
    BuildContext context,
    AppKey label,
    int value,
    BrandStatusFilter filter,
    bool selected,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        width: selected ? AppBorderWidth.thick.of(context) : 0,
      ),
      borderRadius: AppRadius.lg.circular(context),
    ),
    child: Padding(
      padding: EdgeInsets.all(
        selected ? AppBorderWidth.thick.of(context) : 0,
      ),
      child: AppCard(
        onTap: () => onFilterSelected(filter),
        padding: AppSpacing.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(label),
            context.ui.spacing.gap(AppSpacing.xs),
            AppText.raw(value.toString(), type: AppTextType.amountKpi),
          ],
        ),
      ),
    ),
  );
}
