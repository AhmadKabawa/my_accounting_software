import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_card/app_card.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/presentation/model/dashboard_card_definition.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.definition,
    required this.onTap,
  });

  final DashboardCardDefinition definition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${definition.titleKey.tr(context: context)}. ${definition.descriptionKey.tr(context: context)}';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: AppComponentSize.hitArea.constraints(
            context,
            isWidth: false,
          ),
          child: Row(
            children: [
              AppIcon(definition.icon, size: AppIconSize.lg),
              context.ui.spacing.gap(AppSpacing.md, axis: Axis.horizontal),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(definition.titleKey, type: AppTextType.titleSmall),
                    context.ui.spacing.gap(AppSpacing.xs),
                    AppText(
                      definition.descriptionKey,
                      type: AppTextType.bodySmall,
                      color: context.ui.theme.colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
