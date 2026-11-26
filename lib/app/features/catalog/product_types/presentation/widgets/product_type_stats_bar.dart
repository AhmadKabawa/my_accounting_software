import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_list_query.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type_stats.dart';
import 'package:accounting_software/app/features/catalog/product_types/presentation/localization/product_types_keys.dart';

class ProductTypeStatsBar extends StatelessWidget {
  const ProductTypeStatsBar(
    this.stats, {
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.loading = false,
  });

  final ProductTypeStats? stats;
  final ProductTypeStatusFilter selectedFilter;
  final ValueChanged<ProductTypeStatusFilter> onFilterSelected;
  final bool loading;

  @override
  Widget build(BuildContext context) => ListStatsBar<ProductTypeStatusFilter>(
    items: [
      StatItem(
        labelKey: ProductTypesKeys.totalStats,
        value: stats?.total.toString(),
        icon: AppIcons.catalog,
        tone: AppBadgeTone.info,
        filter: ProductTypeStatusFilter.all,
      ),
      StatItem(
        labelKey: ProductTypesKeys.activeStats,
        value: stats?.active.toString(),
        icon: AppIcons.info,
        tone: AppBadgeTone.success,
        filter: ProductTypeStatusFilter.active,
      ),
      StatItem(
        labelKey: ProductTypesKeys.inactiveStats,
        value: stats?.inactive.toString(),
        icon: AppIcons.info,
        tone: AppBadgeTone.neutral,
        filter: ProductTypeStatusFilter.inactive,
      ),
    ],
    selected: selectedFilter,
    onSelected: onFilterSelected,
    loading: loading,
  );
}
