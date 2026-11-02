import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

enum AppButtonVariant { primary, secondary, outlined, danger }

enum AppButtonSize { small, medium, large }

enum AppButtonState { enabled, disabled, pressed }

/// Every visual value of one button (variant + size + state), resolved for the
/// current context.
class ButtonVisual {
  final Color background;
  final Color foreground;

  /// null = no border.
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsets padding;
  final BorderRadius radius;
  final double height;
  final double iconSize;

  /// Space between the icon (or spinner) and the label.
  final double iconGap;

  const ButtonVisual({
    required this.background,
    required this.foreground,
    required this.borderWidth,
    required this.padding,
    required this.radius,
    required this.height,
    required this.iconSize,
    required this.iconGap,
    this.borderColor,
  });
}

class AppButtonStyle {
  final BuildContext context;

  const AppButtonStyle(this.context);

  // ═══════════════════════════════════════════
  // 🔹 CONSTANTS
  // ═══════════════════════════════════════════

  static const _outlinedBorderWidth = 1.0;

  /// Disabled colors: the same opacities the Material button themes use.
  static const _disabledBackgroundOpacity = 0.12;
  static const _disabledForegroundOpacity = 0.4;

  /// The foreground color painted over the background while pressed.
  static const _pressedOverlayOpacity = 0.12;

  static const _loadingStrokeWidth = 2.0;

  /// Stroke of the spinner shown while a button is loading.
  double get loadingStrokeWidth => _loadingStrokeWidth;

  // ═══════════════════════════════════════════
  // 🔹 SIZES
  // Control sizes step per screen type (adaptiveOnly): on mobile they are the
  // token's mobile value, on tablet/desktop the next steps up.
  // ═══════════════════════════════════════════

  static const _adaptive = ResponsiveMode.adaptiveOnly;

  double _height(AppButtonSize size) => Rh.height(
    context,
    switch (size) {
      AppButtonSize.small => AppComponentSize.tiny,
      AppButtonSize.medium => AppComponentSize.medium,
      AppButtonSize.large => AppComponentSize.large,
    },
    mode: _adaptive,
  );

  EdgeInsets _padding(AppButtonSize size) => Rh.symmetricPadding(
    context,
    horizontal: switch (size) {
      AppButtonSize.small => AppSpacing.md,
      AppButtonSize.medium => AppSpacing.mdLg,
      AppButtonSize.large => AppSpacing.lg,
    },
    mode: _adaptive,
  );

  double _iconSize(AppButtonSize size) => Rh.iconSize(
    context,
    switch (size) {
      AppButtonSize.small => AppIconSize.sm,
      AppButtonSize.medium => AppIconSize.md,
      AppButtonSize.large => AppIconSize.lg,
    },
    mode: _adaptive,
  );

  double _iconGap(AppButtonSize size) => Rh.spacing(
    context,
    size == AppButtonSize.small ? AppSpacing.xs : AppSpacing.sm,
    mode: _adaptive,
  );

  BorderRadius get radius =>
      Rh.circularRadius(context, AppRadius.md, mode: _adaptive);

  // ═══════════════════════════════════════════
  // 🔹 COLORS
  // ═══════════════════════════════════════════

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  /// Background and foreground of [variant] when it is enabled.
  (Color, Color) _colors(AppButtonVariant variant) => switch (variant) {
    AppButtonVariant.primary => (_scheme.primary, _scheme.onPrimary),
    AppButtonVariant.secondary => (
      _scheme.secondaryContainer,
      _scheme.onSecondaryContainer,
    ),
    AppButtonVariant.outlined => (Colors.transparent, _scheme.onSurface),
    AppButtonVariant.danger => (_scheme.error, _scheme.onError),
  };

  // ═══════════════════════════════════════════
  // 🔹 VARIANTS
  // ═══════════════════════════════════════════

  /// The visual values of a button.
  ButtonVisual resolve(
    AppButtonVariant variant,
    AppButtonSize size, {
    AppButtonState state = AppButtonState.enabled,
  }) {
    final (enabledBackground, enabledForeground) = _colors(variant);
    final isOutlined = variant == AppButtonVariant.outlined;

    final Color background;
    final Color foreground;
    final Color? borderColor;

    switch (state) {
      case AppButtonState.enabled:
        background = enabledBackground;
        foreground = enabledForeground;
        borderColor = isOutlined ? _scheme.outline : null;
      case AppButtonState.pressed:
        foreground = enabledForeground;
        background = Color.alphaBlend(
          foreground.withOpacity(_pressedOverlayOpacity),
          enabledBackground,
        );
        borderColor = isOutlined ? _scheme.outline : null;
      case AppButtonState.disabled:
        foreground = _scheme.onSurface.withOpacity(_disabledForegroundOpacity);
        background = isOutlined
            ? Colors.transparent
            : _scheme.onSurface.withOpacity(_disabledBackgroundOpacity);
        borderColor = isOutlined
            ? _scheme.onSurface.withOpacity(_disabledBackgroundOpacity)
            : null;
    }

    return ButtonVisual(
      background: background,
      foreground: foreground,
      borderColor: borderColor,
      borderWidth: isOutlined ? _outlinedBorderWidth : 0,
      padding: _padding(size),
      radius: radius,
      height: _height(size),
      iconSize: _iconSize(size),
      iconGap: _iconGap(size),
    );
  }
}
