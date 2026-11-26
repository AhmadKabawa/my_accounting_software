import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_list_query.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/entity/sport_stats.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';

class SportStatsSection extends StatelessWidget {
  const SportStatsSection({
    super.key,
    required this.stats,
    required this.selectedFilter,
    required this.onStatusSelected,
    this.loading = false,
    this.failure,
    this.onRetry,
  });

  final SportStats? stats;
  final SportStatusFilter selectedFilter;
  final ValueChanged<SportStatusFilter> onStatusSelected;
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
    return ListStatsBar<SportStatusFilter>(
      items: [
        StatItem(
          labelKey: SportsKeys.totalSports,
          value: stats?.total.toString(),
          icon: AppIcons.sports,
          tone: AppBadgeTone.info,
          filter: SportStatusFilter.all,
        ),
        StatItem(
          labelKey: SportsKeys.activeSports,
          value: stats?.active.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
          filter: SportStatusFilter.active,
        ),
        StatItem(
          labelKey: SportsKeys.inactiveSports,
          value: stats?.inactive.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
          filter: SportStatusFilter.inactive,
        ),
      ],
      selected: selectedFilter,
      onSelected: onStatusSelected,
      loading: loading,
    );
  }
}
