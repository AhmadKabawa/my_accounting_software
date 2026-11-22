import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stat_card/app_stat_card.dart';
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
  Widget build(BuildContext context) => Row(
    children: [
      _card(
        BrandsKeys.totalBrands,
        stats?.total,
        BrandStatusFilter.all,
        AppIcons.brands,
        AppBadgeTone.info,
      ),
      context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
      _card(
        BrandsKeys.activeBrands,
        stats?.active,
        BrandStatusFilter.active,
        AppIcons.restore,
        AppBadgeTone.success,
      ),
      context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
      _card(
        BrandsKeys.inactiveBrands,
        stats?.inactive,
        BrandStatusFilter.inactive,
        AppIcons.block,
        AppBadgeTone.neutral,
      ),
    ],
  );

  Widget _card(
    AppKey label,
    int? value,
    BrandStatusFilter filter,
    AppIconData icon,
    AppBadgeTone tone,
  ) => Expanded(
    child: AppStatCard(
      compact: true,
      titleKey: label,
      value: value?.toString(),
      icon: icon,
      tone: tone,
      loading: loading,
      selected: selectedFilter == filter,
      onTap: () => onFilterSelected(filter),
    ),
  );
}
