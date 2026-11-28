import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class CatalogAreaCard extends StatelessWidget {
  const CatalogAreaCard({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
    required this.onOpen,
  });

  final AppIconData icon;
  final AppKey titleKey;
  final AppKey descriptionKey;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: context.ui.size.width(AppComponentSize.cardWidth),
      minWidth: context.ui.size.width(AppComponentSize.cardWidth),
    ),
    child: AppCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: AppIconSize.lg),
          context.ui.spacing.gap(AppSpacing.sm),
          AppText(titleKey, type: AppTextType.titleMedium),
          context.ui.spacing.gap(AppSpacing.xs),
          AppText(
            descriptionKey,
            type: AppTextType.bodySmall,
            color: context.ui.theme.colors.onSurfaceVariant,
          ),
          context.ui.spacing.gap(AppSpacing.sm),
          AppButton(
            CatalogHubKeys.open,
            variant: AppButtonVariant.outlined,
            size: AppButtonSize.small,
            onPressed: onOpen,
          ),
        ],
      ),
    ),
  );
}
