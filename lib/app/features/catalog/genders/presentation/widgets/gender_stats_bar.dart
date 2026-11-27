import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_list_query.dart';
import 'package:accounting_software/app/features/catalog/genders/domain/entity/gender_stats.dart';
import 'package:accounting_software/app/features/catalog/genders/presentation/localization/genders_keys.dart';

class GenderStatsBar extends StatelessWidget {
  const GenderStatsBar(this.stats, {super.key, required this.onSelected, required this.selected, this.loading = false});
  final GenderStats? stats;
  final ValueChanged<GenderStatusFilter> onSelected;
  final GenderStatusFilter selected;
  final bool loading;
  @override
  Widget build(BuildContext context) => ListStatsBar<GenderStatusFilter>(
    items: [
      StatItem(labelKey: GendersKeys.total, value: stats?.total.toString(), icon: AppIcons.catalog, tone: AppBadgeTone.info, filter: GenderStatusFilter.all),
      StatItem(labelKey: GendersKeys.activeTotal, value: stats?.active.toString(), icon: AppIcons.success, tone: AppBadgeTone.success, filter: GenderStatusFilter.active),
      StatItem(labelKey: GendersKeys.inactiveTotal, value: stats?.inactive.toString(), icon: AppIcons.block, tone: AppBadgeTone.neutral, filter: GenderStatusFilter.inactive),
    ],
    selected: selected,
    onSelected: onSelected,
    loading: loading,
  );
}
