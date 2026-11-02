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

  /// Headline 1
  TextStyle h1({
    FontWeight weight = FontWeight.bold,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.display,
    weight: weight,
    color: color,
    height: height ?? 1.2,
  );

  /// Headline 2
  TextStyle h2({
    FontWeight weight = FontWeight.bold,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.xxxl,
    weight: weight,
    color: color,
    height: height ?? 1.2,
  );

  /// Headline 3
  TextStyle h3({
    FontWeight weight = FontWeight.bold,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.xxl,
    weight: weight,
    color: color,
    height: height ?? 1.3,
  );

  /// Subtitle 1
  TextStyle subtitle1({
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.lg,
    weight: weight,
    color: color,
    height: height ?? 1.4,
  );

  /// Subtitle 2
  TextStyle subtitle2({
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.md,
    weight: weight,
    color: color,
    height: height ?? 1.4,
  );

  /// Body text
  TextStyle body({
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.base,
    weight: weight,
    color: color,
    height: height ?? 1.5,
  );

  /// Body small
  TextStyle bodySmall({
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.sm,
    weight: weight,
    color: color,
    height: height ?? 1.5,
  );

  /// Caption
  TextStyle caption({
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.xs,
    weight: weight,
    color: color,
    height: height ?? 1.4,
  );

  /// Button text
  TextStyle button({
    FontWeight weight = FontWeight.w600,
    Color? color,
    double? letterSpacing,
  }) => style(
    AppFontSize.md,
    weight: weight,
    color: color,
    letterSpacing: letterSpacing ?? 0,
    height: 1.2,
  );
}
