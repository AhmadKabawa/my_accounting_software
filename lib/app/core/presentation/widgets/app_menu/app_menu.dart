import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class AppMenuEntry {
  const AppMenuEntry({
    required this.label,
    required this.onSelected,
    this.icon,
    this.enabled = true,
  });

  final AppKey label;
  final AppIconData? icon;
  final VoidCallback onSelected;
  final bool enabled;
}

/// General anchored menu for page, account and row actions.
class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    required this.entries,
    required this.tooltipKey,
    this.icon,
    this.labelKey,
    this.enabled = true,
  });

  final List<AppMenuEntry> entries;
  final AppKey tooltipKey;
  final AppIconData? icon;
  final AppKey? labelKey;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: tooltipKey.tr(context: context),
      enabled: enabled && entries.isNotEmpty,
      onSelected: (index) => entries[index].onSelected(),
      itemBuilder: (context) => [
        for (var i = 0; i < entries.length; i++)
          PopupMenuItem<int>(
            value: i,
            enabled: entries[i].enabled,
            child: Row(
              children: [
                if (entries[i].icon != null) ...[
                  AppIcon(entries[i].icon!, size: AppIconSize.md),
                  context.ui.spacing.gap(
                    AppSpacing.sm,
                    axis: Axis.horizontal,
                  ),
                ],
                AppText(entries[i].label, type: AppTextType.bodyMedium),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.ui.spacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) AppIcon(icon!, size: AppIconSize.md),
            if (labelKey != null) ...[
              if (icon != null)
                context.ui.spacing.gap(
                  AppSpacing.xs,
                  axis: Axis.horizontal,
                ),
              AppText(labelKey!, type: AppTextType.labelLarge),
            ],
          ],
        ),
      ),
    );
  }
}
