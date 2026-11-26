import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_list_query.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/entity/tag_stats.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';

class TagStatsSection extends StatelessWidget {
  const TagStatsSection({
    super.key,
    required this.stats,
    required this.selectedFilter,
    required this.onStatusSelected,
    this.loading = false,
    this.failure,
    this.onRetry,
  });

  final TagStats? stats;
  final TagStatusFilter selectedFilter;
  final ValueChanged<TagStatusFilter> onStatusSelected;
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
    return ListStatsBar<TagStatusFilter>(
      items: [
        StatItem(
          labelKey: TagsKeys.totalTags,
          value: stats?.total.toString(),
          icon: AppIcons.tags,
          tone: AppBadgeTone.info,
          filter: TagStatusFilter.all,
        ),
        StatItem(
          labelKey: TagsKeys.activeTags,
          value: stats?.active.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
          filter: TagStatusFilter.active,
        ),
        StatItem(
          labelKey: TagsKeys.inactiveTags,
          value: stats?.inactive.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
          filter: TagStatusFilter.inactive,
        ),
      ],
      selected: selectedFilter,
      onSelected: onStatusSelected,
      loading: loading,
    );
  }
}
