import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/keys/message_keys.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon.dart';

/// The four kinds of inline message.
enum InlineBannerVariant { success, error, warning, info }

/// Colors, icon and screen-reader label of one [InlineBannerVariant].
class InlineBannerVisual {
  const InlineBannerVisual({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.labelKey,
  });

  /// The light fill (`xContainer`).
  final Color background;

  /// Text, icon and border (`x`): its contrast over [background] is verified
  /// by `app_colors_test` for both themes.
  final Color foreground;

  /// From `AppIcons`, the single place icons are defined.
  final AppIconData icon;

  /// Names the kind for screen readers, so color and icon are never alone.
  final AppKey labelKey;
}

/// Resolves every value of an `InlineBanner` from the theme and tokens.
///
/// No new colors: success / warning / info come from `semanticColors`, and the
/// error from `ColorScheme` (there is no separate semantic error color).
class InlineBannerStyle {
  const InlineBannerStyle(this.context);

  final BuildContext context;

  InlineBannerVisual resolve(InlineBannerVariant variant) {
    final colors = context.ui.theme.colors;
    final semantic = context.ui.theme.semanticColors;

    return switch (variant) {
      InlineBannerVariant.success => InlineBannerVisual(
        background: semantic.successContainer,
        foreground: semantic.success,
        icon: AppIcons.success,
        labelKey: MessageKeys.successLabel,
      ),
      InlineBannerVariant.error => InlineBannerVisual(
        background: colors.errorContainer,
        foreground: colors.error,
        icon: AppIcons.error,
        labelKey: MessageKeys.errorLabel,
      ),
      InlineBannerVariant.warning => InlineBannerVisual(
        background: semantic.warningContainer,
        foreground: semantic.warning,
        icon: AppIcons.warning,
        labelKey: MessageKeys.warningLabel,
      ),
      InlineBannerVariant.info => InlineBannerVisual(
        background: semantic.infoContainer,
        foreground: semantic.info,
        icon: AppIcons.info,
        labelKey: MessageKeys.infoLabel,
      ),
    };
  }

  BorderRadius get radius => context.ui.radius.md;

  double get borderWidth => AppBorderWidth.thin.of(context);

  /// Compact density (on a screen larger than a phone) tightens the vertical
  /// padding; the close button follows density through `AppIconButton`. The
  /// banner has no fixed height, so nothing else depends on it.
  EdgeInsets get padding {
    final compact =
        AppDensityScope.compactHeight(context, AppDensityScope.of(context)) !=
        null;
    return context.ui.padding.symmetric(
      horizontal: AppSpacing.md,
      vertical: compact ? AppSpacing.sm : AppSpacing.md,
    );
  }
}
