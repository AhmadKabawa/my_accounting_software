import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_divider/app_divider.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/domain/entity/home_summary.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';
import 'package:accounting_software/app/features/home/presentation/support/home_format.dart';

class HomeRecentActivitySection extends StatelessWidget {
  const HomeRecentActivitySection({super.key, required this.items});

  final List<ActivityItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppCard(child: AppText(HomeKeys.noActivity));
    }
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const AppDivider(),
            Padding(
              padding: context.ui.padding.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.raw(
                          items[i].counterparty,
                          type: AppTextType.titleSmall,
                          maxLines: 1,
                        ),
                        AppText(
                          activityLabel(items[i].kind),
                          type: AppTextType.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  AppText.raw(
                    formatAmount(items[i].amount),
                    type: AppTextType.titleSmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
