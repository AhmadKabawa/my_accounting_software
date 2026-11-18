// ─────────────────────────────────────────────────────────────────
// inline_banner.dart  (C38)
//
// A message inside the screen (a form, a dialog, a page): success, error,
// warning or information. It never fades by itself and never clips its text.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/message_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_button/app_icon_button.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner_style.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

export 'package:accounting_software/app/core/presentation/widgets/app_inline_banner/inline_banner_style.dart'
    show InlineBannerVariant;

/// A bordered, tinted message with an icon, an optional title and a text.
///
/// - **Text is an [AppKey] only** (no `String`): a banner can never show raw
///   server text. A rejection from the database arrives as a `Failure` whose
///   key is already translated per its `ERPnn` code; see
///   `MessageViewWidgets.failureBanner`.
/// - **Colors** come from the theme (`xContainer` fill, `x` text/icon/border),
///   so light and dark work without branching.
/// - **Direction:** the icon sits at the start and the close button at the end
///   in both RTL and LTR.
/// - **Closing** is the parent's decision: pass [onDismiss] and remove the
///   banner (or clear the error in the state) when it is called. Without it
///   there is no close button.
/// - **Accessibility:** the content is a live region named by its kind
///   ("Error", "Warning"...), so a screen reader announces it when it appears.
/// - **Density:** inside an `AppDensityScope(compact)` on a screen larger than
///   a phone the padding and the close button get tighter; on a phone it never
///   changes.
/// - Needs a bounded width (a form, a column); it grows in height with its text.
///
/// One banner per form is the rule (C38): the screen decides which one shows.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.messageKey,
    this.variant = InlineBannerVariant.info,
    this.titleKey,
    this.showIcon = true,
    this.onDismiss,
    this.selectable = true,
  });

  final AppKey messageKey;
  final InlineBannerVariant variant;

  /// A short heading above the message, when the message alone is not enough.
  final AppKey? titleKey;

  /// The icon repeats the kind in a second way besides color.
  final bool showIcon;

  /// Not null = closable: shows a close button that calls it.
  final VoidCallback? onDismiss;

  /// Lets the text be selected and copied (mouse and keyboard users).
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final style = InlineBannerStyle(context);
    final visual = style.resolve(variant);
    final title = titleKey;
    final dismiss = onDismiss;

    Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          AppText(
            title,
            type: AppTextType.titleSmall,
            color: visual.foreground,
          ),
          context.ui.spacing.gap(AppSpacing.xs),
        ],
        AppText(
          messageKey,
          type: AppTextType.bodyMedium,
          color: visual.foreground,
        ),
      ],
    );
    if (selectable) text = SelectionArea(child: text);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: visual.background,
        borderRadius: style.radius,
        border: Border.all(color: visual.foreground, width: style.borderWidth),
      ),
      child: Padding(
        padding: style.padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Semantics(
                container: true,
                liveRegion: true,
                label: visual.labelKey.tr(context: context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showIcon) ...[
                      AppIcon(
                        visual.icon,
                        size: AppIconSize.md,
                        color: visual.foreground,
                      ),
                      context.ui.spacing.gap(AppSpacing.sm),
                    ],
                    Expanded(child: text),
                  ],
                ),
              ),
            ),
            if (dismiss != null) ...[
              context.ui.spacing.gap(AppSpacing.sm),
              AppIconButton(
                AppIcons.close,
                tooltipKey: MessageKeys.close,
                onPressed: dismiss,
                color: visual.foreground,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
