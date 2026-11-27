import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
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
    this.loading = false,
  });

  final BrandStats? stats;
  final ValueChanged<BrandStatusFilter> onFilterSelected;
  final BrandStatusFilter selectedFilter;

  /// Placeholders only while the first load runs; a failure shows "—".
  final bool loading;

  @override
  Widget build(BuildContext context) => ListStatsBar<BrandStatusFilter>(
    items: [
      StatItem(
        labelKey: BrandsKeys.totalBrands,
        value: stats?.total.toString(),
        icon: AppIcons.brands,
        tone: AppBadgeTone.info,
        filter: BrandStatusFilter.all,
      ),
      StatItem(
        labelKey: BrandsKeys.activeBrands,
        value: stats?.active.toString(),
        icon: AppIcons.success,
        tone: AppBadgeTone.success,
        filter: BrandStatusFilter.active,
      ),
      StatItem(
        labelKey: BrandsKeys.inactiveBrands,
        value: stats?.inactive.toString(),
        icon: AppIcons.block,
        tone: AppBadgeTone.neutral,
        filter: BrandStatusFilter.inactive,
      ),
      StatItem(
        labelKey: BrandsKeys.brandsWithProducts,
        value: stats?.withProducts.toString(),
        icon: AppIcons.success,
        tone: AppBadgeTone.success,
      ),
      StatItem(
        labelKey: BrandsKeys.brandsWithoutProducts,
        value: stats?.withoutProducts.toString(),
        icon: AppIcons.block,
        tone: AppBadgeTone.neutral,
      ),
    ],
    selected: selectedFilter,
    onSelected: onFilterSelected,
    loading: loading,
  );
}
