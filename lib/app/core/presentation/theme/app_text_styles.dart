import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';

abstract final class AppTextStyles {
  // ══════════════════════════════════════════════════════════════
  // PRIVATE HELPER
  // ══════════════════════════════════════════════════════════════

  /// Creates a responsive text style with proper constraints
  ///
  /// Parameters:
  /// - [context]: BuildContext for responsive calculations
  /// - [size]: Base font size token (required)
  /// - [min]: Minimum font size token (optional, defaults to xs)
  /// - [max]: Maximum font size token (optional, defaults to display)
  /// - [weight]: Font weight (optional)
  /// - [color]: Text color (optional)
  /// - [height]: Line height multiplier (optional, defaults to 1.4)
  /// - [letterSpacing]: Letter spacing (optional)
  /// - [respectTextScaler]: Whether to respect system text scale (default: true)
  /// - [mode]: Responsive calculation mode (default: adaptiveScale)
  static TextStyle _createStyle(
    BuildContext context, {
    required AppFontSize size,
    AppFontSize? min,
    AppFontSize? max,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    return Rh.textStyle(
      context,
      size,
      min: min ?? AppFontSize.xs,
      max: max ?? AppFontSize.display,
      weight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      respectTextScaler: respectTextScaler,
      mode: mode,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DISPLAY
  // ══════════════════════════════════════════════════════════════

  static TextStyle displayLarge(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.display,
    min: AppFontSize.xxl,
    max: AppFontSize.hero,
    weight: FontWeight.bold,
  );

  static TextStyle displayMedium(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xxxl,
    min: AppFontSize.xxl,
    max: AppFontSize.display,
    weight: FontWeight.bold,
  );

  static TextStyle displaySmall(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xxl,
    min: AppFontSize.xl,
    max: AppFontSize.xxxl,
    weight: FontWeight.bold,
  );

  // ══════════════════════════════════════════════════════════════
  // HEADLINE
  // ══════════════════════════════════════════════════════════════

  static TextStyle headlineLarge(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xl,
    min: AppFontSize.lg,
    max: AppFontSize.xxl,
    weight: FontWeight.w600,
  );

  static TextStyle headlineMedium(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.lg,
    min: AppFontSize.md,
    max: AppFontSize.xl,
    weight: FontWeight.w600,
  );

  static TextStyle headlineSmall(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.md,
    min: AppFontSize.sm,
    max: AppFontSize.lg,
    weight: FontWeight.w600,
  );

  // ══════════════════════════════════════════════════════════════
  // TITLE
  // ══════════════════════════════════════════════════════════════

  static TextStyle titleLarge(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.md,
    min: AppFontSize.sm,
    max: AppFontSize.lg,
    weight: FontWeight.w600,
  );

  static TextStyle titleMedium(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.w500,
  );

  static TextStyle titleSmall(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  // ══════════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════════

  static TextStyle bodyLarge(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.normal,
  );

  static TextStyle bodyMedium(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.base, // Using base (14/15/16) instead of xs (10/12/14)
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.normal,
  );

  static TextStyle bodySmall(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.normal,
  );

  // ══════════════════════════════════════════════════════════════
  // LABEL
  // ══════════════════════════════════════════════════════════════

  static TextStyle labelLarge(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  static TextStyle labelMedium(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  static TextStyle labelSmall(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.tiny,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.w500,
  );

  // ══════════════════════════════════════════════════════════════
  // SPECIAL
  // ══════════════════════════════════════════════════════════════

  static TextStyle appBarTitle(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.md,
    min: AppFontSize.sm,
    max: AppFontSize.lg,
    weight: FontWeight.bold,
  );

  static TextStyle buttonText(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.w600,
  );

  static TextStyle buttonTextSmall(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w600,
  );

  // ══════════════════════════════════════════════════════════════
  // INPUT
  // ══════════════════════════════════════════════════════════════

  static TextStyle inputText(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.normal,
  );

  static TextStyle inputLabel(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  static TextStyle inputHint(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.normal,
  );

  static TextStyle inputError(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.normal,
  );

  // ══════════════════════════════════════════════════════════════
  // CAPTION / HELPER
  // ══════════════════════════════════════════════════════════════

  static TextStyle caption(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.normal,
  );

  static TextStyle overline(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.tiny,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // ══════════════════════════════════════════════════════════════
  // LINK
  // ══════════════════════════════════════════════════════════════

  static TextStyle link(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  ).copyWith(decoration: TextDecoration.underline);

  static TextStyle linkLarge(BuildContext context) => _createStyle(
    context,
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.w500,
  ).copyWith(decoration: TextDecoration.underline);
}
