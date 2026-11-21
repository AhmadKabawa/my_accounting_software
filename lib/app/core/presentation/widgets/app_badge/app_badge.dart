import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_badge/app_badge_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
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
  }) : assert(onRemove == null || removeLabel != null);

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
    // Touch-first layout: the remove control must reach the hit-area token.
    // On tablet/desktop the pointer is precise, so the compact size is kept.
    final removeTarget = ScreenEngine.isMobile(context)
        ? AppComponentSize.hitArea.mobile
        : 0.0;
    return Semantics(
      container: true,
      explicitChildNodes: true,
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
              // The container label above already names the badge; the
              // visible text and icon must not be announced a second time.
              if (icon != null)
                ExcludeSemantics(
                  child: AppIcon.fixed(
                    icon!,
                    pixelSize: visual.iconSize,
                    color: visual.foreground,
                  ),
                ),
              ExcludeSemantics(
                child: AppText.raw(
                  label.tr(context: context, namedArgs: labelArgs),
                  type: visual.textType,
                  color: visual.foreground,
                ),
              ),
              if (onRemove != null)
                Semantics(
                  button: true,
                  label: removeLabel?.tr(context: context),
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: visual.radius,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: removeTarget,
                        minHeight: removeTarget,
                      ),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
