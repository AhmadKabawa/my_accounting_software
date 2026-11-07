import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';

/// Tells the user the figures are placeholders, so they are never mistaken
/// for real accounting data.
class HomeSampleNoticeSection extends StatelessWidget {
  const HomeSampleNoticeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          AppIcon(
            AppIcons.info,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
          const Expanded(
            child: AppText(
              HomeKeys.sampleDataNotice,
              type: AppTextType.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
