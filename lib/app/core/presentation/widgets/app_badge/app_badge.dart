import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

export 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge_style.dart'
    show AppBadgeTone, AppBadgeSize;

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.labelArgs,
    this.onRemove,
    this.removeLabel,
  });

  final AppKey label;
  final AppBadgeTone tone;
  final AppBadgeSize size;
  final AppIconData? icon;
  final Map<String, String>? labelArgs;
  final VoidCallback? onRemove;
  final AppKey? removeLabel;

  @override
  Widget build(BuildContext context) {
    final visual = AppBadgeStyle(context).resolve(tone, size);
    return Semantics(
      label: label.tr(context: context, namedArgs: labelArgs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: visual.background,
          borderRadius: visual.radius,
          border: visual.borderColor == null
              ? null
              : Border.all(
                  color: visual.borderColor!,
                  width: visual.borderWidth,
                ),
        ),
        child: Padding(
          padding: visual.padding,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: visual.iconGap,
            children: [
              if (icon != null)
                AppIcon.fixed(
                  icon!,
                  pixelSize: visual.iconSize,
                  color: visual.foreground,
                ),
              AppText.raw(
                label.tr(context: context, namedArgs: labelArgs),
                type: visual.textType,
                color: visual.foreground,
              ),
              if (onRemove != null)
                Semantics(
                  button: true,
                  label: removeLabel?.tr(context: context),
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: visual.radius,
                    child: Padding(
                      padding: context.ui.padding.all(AppSpacing.xs),
                      child: AppIcon(
                        AppIcons.close,
                        size: AppIconSize.sm,
                        color: visual.foreground,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
