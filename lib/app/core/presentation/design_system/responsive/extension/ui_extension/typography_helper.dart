part of '../ui_extension.dart';

// ═══════════════════════════════════════════════════════════════════
// TYPOGRAPHY HELPER
// ═══════════════════════════════════════════════════════════════════

class TypographyHelper {
  final BuildContext context;

  const TypographyHelper(this.context);

  /// Font size فقط
  double size(
    AppFontSize fontSize, {
    AppFontSize? min,
    AppFontSize? max,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.font(
    context,
    fontSize,
    min: min,
    max: max,
    respectTextScaler: respectTextScaler,
    mode: mode,
  );

  /// Text style كامل
  TextStyle style(
    AppFontSize fontSize, {
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
    AppFontSize? min,
    AppFontSize? max,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.textStyle(
    context,
    fontSize,
    weight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    min: min,
    max: max,
    respectTextScaler: respectTextScaler,
    mode: mode,
  );

  /// Responsive style of a text role ([AppTextType]) — the entry for UI text.
  /// Color comes from the theme for that role; [mode] overrides the default.
  TextStyle of(AppTextType type, {ResponsiveMode? mode}) =>
      type.resolve(context, mode: mode);
}
