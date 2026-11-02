import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';

/// A text style described with design tokens instead of pixels, so it can be
/// declared (and a [ThemeData] built from it) without a [BuildContext].
///
/// - [baseline]: the mobile design size. Needs no context, so it is safe to use
///   while the theme is built, before MaterialApp (and its MediaQuery) exists.
/// - `resolve(context)`: the responsive size for the screen under a
///   [BuildContext]. It is an extension in `ui_extension.dart`, because the
///   theme must not depend on the responsive engine.
///
/// Letter spacing is always 0: any other value breaks Arabic letter joining,
/// and ThemeData merges M3's default spacing into null values.
class AppTextStyle {
  const AppTextStyle({
    required this.size,
    required this.weight,
    this.min = AppFontSize.xs,
    this.max = AppFontSize.display,
    this.height = 1.4,
    this.mode = ResponsiveMode.adaptiveScale,
    this.respectTextScaler = true,
    this.decoration,
  });

  final AppFontSize size;
  final FontWeight weight;

  /// Clamp range for the responsive size.
  final AppFontSize min;
  final AppFontSize max;

  /// Line height multiplier.
  final double height;

  /// How `resolve` turns the tokens into a size (callers may override it).
  final ResponsiveMode mode;

  /// Whether the device text scale is honoured (capped, applied once).
  final bool respectTextScaler;

  final TextDecoration? decoration;

  TextStyle get baseline => TextStyle(
    fontSize: size.mobile,
    fontWeight: weight,
    height: height,
    letterSpacing: 0,
    decoration: decoration,
  );
}

abstract final class AppTextStyles {
  // ══════════════════════════════════════════════════════════════
  // DISPLAY
  // ══════════════════════════════════════════════════════════════

  static const displayLarge = AppTextStyle(
    size: AppFontSize.display,
    min: AppFontSize.xxl,
    max: AppFontSize.hero,
    weight: FontWeight.bold,
  );

  static const displayMedium = AppTextStyle(
    size: AppFontSize.xxxl,
    min: AppFontSize.xxl,
    max: AppFontSize.display,
    weight: FontWeight.bold,
  );

  static const displaySmall = AppTextStyle(
    size: AppFontSize.xxl,
    min: AppFontSize.xl,
    max: AppFontSize.xxxl,
    weight: FontWeight.bold,
  );

  // ══════════════════════════════════════════════════════════════
  // HEADLINE
  // ══════════════════════════════════════════════════════════════

  static const headlineLarge = AppTextStyle(
    size: AppFontSize.xl,
    min: AppFontSize.lg,
    max: AppFontSize.xxl,
    weight: FontWeight.w600,
  );

  static const headlineMedium = AppTextStyle(
    size: AppFontSize.lg,
    min: AppFontSize.md,
    max: AppFontSize.xl,
    weight: FontWeight.w600,
  );

  static const headlineSmall = AppTextStyle(
    size: AppFontSize.md,
    min: AppFontSize.sm,
    max: AppFontSize.lg,
    weight: FontWeight.w600,
  );

  // ══════════════════════════════════════════════════════════════
  // TITLE
  // ══════════════════════════════════════════════════════════════

  static const titleLarge = AppTextStyle(
    size: AppFontSize.md,
    min: AppFontSize.sm,
    max: AppFontSize.lg,
    weight: FontWeight.w600,
  );

  static const titleMedium = AppTextStyle(
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.w500,
  );

  static const titleSmall = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  // ══════════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════════

  static const bodyLarge = AppTextStyle(
    size: AppFontSize.md, // 16/17/18
    min: AppFontSize.base,
    max: AppFontSize.lg,
    weight: FontWeight.normal,
  );

  // Default style of every Text: 14/15/16. The clamp must not go below the
  // size (it used to cap at sm = 12 on mobile).
  static const bodyMedium = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.normal,
  );

  static const bodySmall = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.normal,
  );

  // ══════════════════════════════════════════════════════════════
  // LABEL
  // ══════════════════════════════════════════════════════════════

  static const labelLarge = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  static const labelMedium = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  static const labelSmall = AppTextStyle(
    size: AppFontSize.tiny,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.w500,
  );

  // ══════════════════════════════════════════════════════════════
  // SPECIAL
  // ══════════════════════════════════════════════════════════════

  static const appBarTitle = AppTextStyle(
    size: AppFontSize.md,
    min: AppFontSize.sm,
    max: AppFontSize.lg,
    weight: FontWeight.bold,
  );

  static const buttonText = AppTextStyle(
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.w600,
  );

  static const buttonTextSmall = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w600,
  );

  // ══════════════════════════════════════════════════════════════
  // INPUT
  // ══════════════════════════════════════════════════════════════

  static const inputText = AppTextStyle(
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.normal,
  );

  static const inputLabel = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  static const inputHint = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.normal,
  );

  static const inputError = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.normal,
  );

  // ══════════════════════════════════════════════════════════════
  // CAPTION / HELPER
  // ══════════════════════════════════════════════════════════════

  static const caption = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.normal,
  );

  static const overline = AppTextStyle(
    size: AppFontSize.tiny,
    min: AppFontSize.tiny,
    max: AppFontSize.xs,
    weight: FontWeight.w500,
  );

  // ══════════════════════════════════════════════════════════════
  // LINK
  // ══════════════════════════════════════════════════════════════

  static const link = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );

  static const linkLarge = AppTextStyle(
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.md,
    weight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );
}
