import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_button_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

/// Reusable inline details surface for CRUD lists; it never expands vertically.
class AppDetailsPanel extends StatelessWidget {
  const AppDetailsPanel({
    super.key,
    required this.titleKey,
    required this.closeLabelKey,
    required this.onClose,
    required this.child,
    this.width = 360,
  });

  final AppKey titleKey;
  final AppKey closeLabelKey;
  final VoidCallback onClose;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {const SingleActivator(LogicalKeyboardKey.escape): onClose},
    child: Focus(
      autofocus: true,
      child: Container(
        width: width,
        padding: context.ui.padding.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.ui.theme.colors.surface,
          border: BorderDirectional(
            start: BorderSide(color: context.ui.theme.colors.outline),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText(titleKey, type: AppTextType.titleMedium),
                ),
                AppIconButton(
                  AppIcons.close,
                  tooltipKey: closeLabelKey,
                  onPressed: onClose,
                  size: AppButtonSize.small,
                ),
              ],
            ),
            context.ui.spacing.gap(AppSpacing.sm),
            Divider(color: context.ui.theme.colors.outline),
            child,
          ],
        ),
      ),
    ),
  );
}
