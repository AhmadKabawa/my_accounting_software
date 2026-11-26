import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_list_query.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/unit_stats.dart';
import 'package:accounting_software/app/features/catalog/units/presentation/localization/units_keys.dart';

class UnitStatsSection extends StatelessWidget {
  const UnitStatsSection({
    super.key,
    required this.stats,
    required this.selectedFilter,
    required this.onStatusSelected,
    this.loading = false,
    this.failure,
    this.onRetry,
  });

  final UnitStats? stats;
  final UnitStatusFilter selectedFilter;
  final ValueChanged<UnitStatusFilter> onStatusSelected;
  final bool loading;
  final AppKey? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (failure != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineBanner(
            messageKey: failure!,
            variant: InlineBannerVariant.error,
          ),
          if (onRetry != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton(
                CatalogUiKeys.retry,
                variant: AppButtonVariant.text,
                onPressed: onRetry,
              ),
            ),
        ],
      );
    }
    return ListStatsBar<UnitStatusFilter>(
      items: [
        StatItem(
          labelKey: UnitsKeys.total,
          value: stats?.total.toString(),
          icon: AppIcons.catalog,
          tone: AppBadgeTone.info,
          filter: UnitStatusFilter.all,
        ),
        StatItem(
          labelKey: UnitsKeys.activeCount,
          value: stats?.active.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
          filter: UnitStatusFilter.active,
        ),
        StatItem(
          labelKey: UnitsKeys.inactiveCount,
          value: stats?.inactive.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
          filter: UnitStatusFilter.inactive,
        ),
      ],
      selected: selectedFilter,
      onSelected: onStatusSelected,
      loading: loading,
    );
  }
}
