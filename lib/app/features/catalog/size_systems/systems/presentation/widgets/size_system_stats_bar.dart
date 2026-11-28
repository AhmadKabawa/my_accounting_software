import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/size_status_filter.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/domain/entity/size_system_stats.dart';

class SizeSystemStatsBar extends StatelessWidget {
  const SizeSystemStatsBar(
    this.stats, {
    super.key,
    required this.onSelected,
    required this.selected,
    this.loading = false,
  });

  final SizeSystemStats? stats;
  final ValueChanged<SizeStatusFilter> onSelected;
  final SizeStatusFilter selected;
  final bool loading;

  @override
  Widget build(BuildContext context) => ListStatsBar<SizeStatusFilter>(
    items: [
      StatItem(
        labelKey: SizeSystemsKeys.total,
        value: stats?.total.toString(),
        icon: AppIcons.catalog,
        tone: AppBadgeTone.info,
        filter: SizeStatusFilter.all,
      ),
      StatItem(
        labelKey: SizeSystemsKeys.activeTotal,
        value: stats?.active.toString(),
        icon: AppIcons.success,
        tone: AppBadgeTone.success,
        filter: SizeStatusFilter.active,
      ),
      StatItem(
        labelKey: SizeSystemsKeys.inactiveTotal,
        value: stats?.inactive.toString(),
        icon: AppIcons.block,
        tone: AppBadgeTone.neutral,
        filter: SizeStatusFilter.inactive,
      ),
    ],
    selected: selected,
    onSelected: onSelected,
    loading: loading,
  );
}
