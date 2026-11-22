import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_density_scope.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

enum AppBadgeTone { neutral, success, warning, info, error }

enum AppBadgeSize { small, medium }

class BadgeVisual {
  const BadgeVisual({
    required this.background,
    required this.foreground,
    required this.padding,
    required this.radius,
    required this.iconSize,
    required this.iconGap,
    required this.textType,
    required this.borderWidth,
    this.borderColor,
  });

  final Color background;
  final Color foreground;
  final EdgeInsets padding;
  final BorderRadius radius;
  final double iconSize;
  final double iconGap;
  final AppTextType textType;
  final Color? borderColor;
  final double borderWidth;
}

class AppBadgeStyle {
  const AppBadgeStyle(this.context);

  final BuildContext context;

  /// The quiet foreground/background pair of [tone], from the `AppSaasColors`
  /// pill tokens (Light and Dark). Single source for badges and stat cards.
  /// Neutral stays the outlined chip look (surface + outline).
  static (Color foreground, Color background) toneColors(
    BuildContext context,
    AppBadgeTone tone,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final pills = context.ui.theme.saasColors;
    return switch (tone) {
      AppBadgeTone.neutral => (scheme.onSurface, scheme.surfaceContainerLow),
      AppBadgeTone.success => (
        pills.pillSuccess.foreground,
        pills.pillSuccess.container,
      ),
      AppBadgeTone.warning => (
        pills.pillWarning.foreground,
        pills.pillWarning.container,
      ),
      AppBadgeTone.info => (
        pills.pillInfo.foreground,
        pills.pillInfo.container,
      ),
      AppBadgeTone.error => (
        pills.pillError.foreground,
        pills.pillError.container,
      ),
    };
  }

  BadgeVisual resolve(AppBadgeTone tone, AppBadgeSize size) {
    final scheme = Theme.of(context).colorScheme;
    final (foreground, background) = toneColors(context, tone);
    final compact = AppDensityScope.of(context) == AppDensity.compact;
    final small = size == AppBadgeSize.small;
    final horizontal = small ? AppSpacing.sm : AppSpacing.md;
    final vertical = small
        ? context.ui.spacing.xs / 2
        : compact
        ? context.ui.spacing.none
        : context.ui.spacing.xs;
    return BadgeVisual(
      background: background,
      foreground: foreground,
      padding: EdgeInsets.symmetric(
        horizontal: context.ui.spacing.value(horizontal),
        vertical: vertical,
      ),
      radius: AppSurfaceShape.pill.circular(context),
      iconSize: context.ui.icon.size(small ? AppIconSize.sm : AppIconSize.md),
      iconGap: context.ui.spacing.value(AppSpacing.xs),
      textType: small ? AppTextType.labelSmall : AppTextType.labelMedium,
      borderColor: tone == AppBadgeTone.neutral ? scheme.outlineVariant : null,
      borderWidth: AppBorderWidth.thin.of(context),
    );
  }
}
