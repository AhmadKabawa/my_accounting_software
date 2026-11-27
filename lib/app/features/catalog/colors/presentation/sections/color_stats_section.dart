import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_list_query.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/entity/color_stats.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';

class ColorStatsSection extends StatelessWidget {
  const ColorStatsSection({
    super.key,
    required this.stats,
    required this.selectedFilter,
    required this.onStatusSelected,
    this.loading = false,
    this.failure,
    this.onRetry,
  });

  final ColorStats? stats;
  final ColorStatusFilter selectedFilter;
  final ValueChanged<ColorStatusFilter> onStatusSelected;
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
    return ListStatsBar<ColorStatusFilter>(
      items: [
        StatItem(
          labelKey: ColorsKeys.totalColors,
          value: stats?.total.toString(),
          icon: AppIcons.colors,
          tone: AppBadgeTone.info,
          filter: ColorStatusFilter.all,
        ),
        StatItem(
          labelKey: ColorsKeys.activeColors,
          value: stats?.active.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
          filter: ColorStatusFilter.active,
        ),
        StatItem(
          labelKey: ColorsKeys.inactiveColors,
          value: stats?.inactive.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
          filter: ColorStatusFilter.inactive,
        ),
        StatItem(
          labelKey: ColorsKeys.usedColors,
          value: stats?.used.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
        ),
        StatItem(
          labelKey: ColorsKeys.unusedColors,
          value: stats?.unused.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
        ),
      ],
      selected: selectedFilter,
      onSelected: onStatusSelected,
      loading: loading,
    );
  }
}
