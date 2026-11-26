import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_list_query.dart';
import 'package:accounting_software/app/features/catalog/categories/domain/entity/category_tree.dart';
import 'package:accounting_software/app/features/catalog/categories/presentation/localization/categories_keys.dart';

enum CategoryStatsFilter {
  all,
  active,
  inactive,
  roots,
  leaves,
  withoutProducts,
}

/// Locally derived tree counters; tapping a card applies its matching filter.
class CategoryStatsBar extends StatelessWidget {
  const CategoryStatsBar({
    super.key,
    required this.tree,
    required this.query,
    required this.onSelected,
  });

  final CategoryTree? tree;
  final CategoryListQuery query;
  final ValueChanged<CategoryStatsFilter> onSelected;

  CategoryStatsFilter? get _selected {
    if (query.search.isNotEmpty) return null;
    if (query.status == CategoryStatusFilter.active &&
        query.level == CategoryLevelFilter.all &&
        query.usage == CategoryUsageFilter.all) {
      return CategoryStatsFilter.active;
    }
    if (query.status == CategoryStatusFilter.inactive &&
        query.level == CategoryLevelFilter.all &&
        query.usage == CategoryUsageFilter.all) {
      return CategoryStatsFilter.inactive;
    }
    if (query.status == CategoryStatusFilter.all &&
        query.level == CategoryLevelFilter.roots &&
        query.usage == CategoryUsageFilter.all) {
      return CategoryStatsFilter.roots;
    }
    if (query.status == CategoryStatusFilter.all &&
        query.level == CategoryLevelFilter.leaves &&
        query.usage == CategoryUsageFilter.all) {
      return CategoryStatsFilter.leaves;
    }
    if (query.status == CategoryStatusFilter.all &&
        query.level == CategoryLevelFilter.all &&
        query.usage == CategoryUsageFilter.withoutProducts) {
      return CategoryStatsFilter.withoutProducts;
    }
    return query.hasActiveFilters ? null : CategoryStatsFilter.all;
  }

  @override
  Widget build(BuildContext context) {
    final value = tree;
    return ListStatsBar<CategoryStatsFilter>(
      items: [
        StatItem(
          labelKey: CategoriesKeys.totalCategories,
          value: value?.length.toString(),
          icon: AppIcons.catalog,
          tone: AppBadgeTone.info,
          filter: CategoryStatsFilter.all,
        ),
        StatItem(
          labelKey: CategoriesKeys.activeCategories,
          value: value?.activeCount.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
          filter: CategoryStatsFilter.active,
        ),
        StatItem(
          labelKey: CategoriesKeys.inactiveCategories,
          value: value?.inactiveCount.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
          filter: CategoryStatsFilter.inactive,
        ),
        StatItem(
          labelKey: CategoriesKeys.rootStats,
          value: value?.rootCount.toString(),
          icon: AppIcons.expand,
          tone: AppBadgeTone.info,
          filter: CategoryStatsFilter.roots,
        ),
        StatItem(
          labelKey: CategoriesKeys.leafStats,
          value: value?.leafCount.toString(),
          icon: AppIcons.checklist,
          tone: AppBadgeTone.neutral,
          filter: CategoryStatsFilter.leaves,
        ),
        StatItem(
          labelKey: CategoriesKeys.noProductStats,
          value: value?.withoutProductsCount?.toString(),
          icon: AppIcons.info,
          tone: AppBadgeTone.neutral,
          filter: CategoryStatsFilter.withoutProducts,
        ),
      ],
      selected: _selected,
      onSelected: onSelected,
    );
  }
}
