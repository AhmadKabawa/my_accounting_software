import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/keys/catalog_ui_keys.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/list_stats_bar.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_stats_bar/stat_item.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_list_query.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/attribute_stats.dart';
import 'package:accounting_software/app/features/catalog/attributes/presentation/localization/attributes_keys.dart';

class AttributeStatsSection extends StatelessWidget {
  const AttributeStatsSection({
    super.key,
    required this.stats,
    required this.selectedFilter,
    required this.onStatusSelected,
    this.loading = false,
    this.failure,
    this.onRetry,
  });
  final AttributeStats? stats;
  final AttributeStatusFilter selectedFilter;
  final ValueChanged<AttributeStatusFilter> onStatusSelected;
  final bool loading;
  final AppKey? failure;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    if (failure != null)
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
    return ListStatsBar<AttributeStatusFilter>(
      items: [
        StatItem(
          labelKey: AttributesKeys.total,
          value: stats?.all.toString(),
          icon: AppIcons.catalog,
          tone: AppBadgeTone.info,
          filter: AttributeStatusFilter.all,
        ),
        StatItem(
          labelKey: AttributesKeys.activeCount,
          value: stats?.active.toString(),
          icon: AppIcons.success,
          tone: AppBadgeTone.success,
          filter: AttributeStatusFilter.active,
        ),
        StatItem(
          labelKey: AttributesKeys.inactiveCount,
          value: stats?.inactive.toString(),
          icon: AppIcons.block,
          tone: AppBadgeTone.neutral,
          filter: AttributeStatusFilter.inactive,
        ),
        StatItem(
          labelKey: AttributesKeys.filterableCount,
          value: stats?.filterable.toString(),
          icon: AppIcons.filter,
          tone: AppBadgeTone.info,
        ),
      ],
      selected: selectedFilter,
      onSelected: onStatusSelected,
      loading: loading,
    );
  }
}
