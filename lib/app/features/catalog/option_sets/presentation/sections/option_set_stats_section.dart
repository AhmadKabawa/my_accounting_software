import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_list_query.dart';
import 'package:accounting_software/app/features/catalog/option_sets/domain/entity/option_set_stats.dart';
import 'package:accounting_software/app/features/catalog/option_sets/presentation/localization/option_sets_keys.dart';

class OptionSetStatsSection extends StatelessWidget {
  const OptionSetStatsSection({
    super.key,
    required this.stats,
    required this.selectedFilter,
    required this.onStatusSelected,
    this.loading = false,
    this.failure,
    this.onRetry,
  });

  final OptionSetStats? stats;
  final OptionSetStatusFilter selectedFilter;
  final ValueChanged<OptionSetStatusFilter> onStatusSelected;
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
    return ListStatsBar<OptionSetStatusFilter>(
      items: [
        StatItem(
          labelKey: OptionSetsKeys.total,
          value: stats?.total.toString(),
          icon: AppIcons.catalog,
          tone: AppBadgeTone.info,
          filter: OptionSetStatusFilter.all,
        ),
        StatItem(
          labelKey: OptionSetsKeys.activeCount,
          value: stats?.active.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
          filter: OptionSetStatusFilter.active,
        ),
        StatItem(
          labelKey: OptionSetsKeys.inactiveCount,
          value: stats?.inactive.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
          filter: OptionSetStatusFilter.inactive,
        ),
      ],
      selected: selectedFilter,
      onSelected: onStatusSelected,
      loading: loading,
    );
  }
}
