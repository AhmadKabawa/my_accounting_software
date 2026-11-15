import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

/// Font families of the design system. The font files are bundled in the
/// project and declared in `pubspec.yaml` (see docs/architecture/DESIGN_SYSTEM.md).
abstract final class AppFontFamily {
  /// Arabic and Latin text, with tabular lining numerals.
  static const sans = 'IBM Plex Sans Arabic';

  /// Barcodes and SKUs only.
  static const mono = 'IBM Plex Mono';
}

/// Tabular + lining figures: every amount aligns in a column.
const _tabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
  FontFeature.liningFigures(),
];

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
    this.fontFamily,
    this.fontFeatures,
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

  /// null = the theme's family ([AppFontFamily.sans]).
  final String? fontFamily;

  /// OpenType features (tabular figures for amounts).
  final List<FontFeature>? fontFeatures;

  TextStyle get baseline => TextStyle(
    fontSize: size.mobile,
    fontWeight: weight,
    height: height,
    letterSpacing: 0,
    decoration: decoration,
    fontFamily: fontFamily,
    fontFeatures: fontFeatures,
  );
}

/// The text roles of the design system (phone values; tablet and desktop come
/// from the [AppFontSize] tokens). Line height: 1.5 for body text, 1.2–1.4 for
/// headings, labels and amounts.
abstract final class AppTextStyles {
  // ══════════════════════════════════════════════════════════════
  // DISPLAY
  // ══════════════════════════════════════════════════════════════

  static const displayLarge = AppTextStyle(
    size: AppFontSize.display,
    min: AppFontSize.xxl,
    max: AppFontSize.display,
    weight: FontWeight.bold,
    height: 1.2,
  );

  static const displayMedium = AppTextStyle(
    size: AppFontSize.xxxl,
    min: AppFontSize.xxl,
    max: AppFontSize.display,
    weight: FontWeight.bold,
    height: 1.25,
  );

  static const displaySmall = AppTextStyle(
    size: AppFontSize.xxl,
    min: AppFontSize.xl,
    max: AppFontSize.xxxl,
    weight: FontWeight.bold,
    height: 1.3,
  );

  // ══════════════════════════════════════════════════════════════
  // HEADLINE
  // ══════════════════════════════════════════════════════════════

  static const headlineLarge = AppTextStyle(
    size: AppFontSize.xl,
    min: AppFontSize.lg,
    max: AppFontSize.xxl,
    weight: FontWeight.w600,
    height: 1.35,
  );

  static const headlineMedium = AppTextStyle(
    size: AppFontSize.lg,
    min: AppFontSize.md,
    max: AppFontSize.xl,
    weight: FontWeight.w600,
  );

  static const headlineSmall = AppTextStyle(
    size: AppFontSize.md,
    min: AppFontSize.base,
    max: AppFontSize.lg,
    weight: FontWeight.w600,
  );

  // ══════════════════════════════════════════════════════════════
  // TITLE
  // ══════════════════════════════════════════════════════════════

  static const titleLarge = AppTextStyle(
    size: AppFontSize.md,
    min: AppFontSize.base,
    max: AppFontSize.lg,
    weight: FontWeight.w600,
  );

  static const titleMedium = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.w500,
    height: 1.45,
  );

  static const titleSmall = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
    height: 1.45,
  );

  // ══════════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════════

  static const bodyLarge = AppTextStyle(
    size: AppFontSize.md, // 16/17/18
    min: AppFontSize.base,
    max: AppFontSize.lg,
    weight: FontWeight.normal,
    height: 1.5,
  );

  // Default style of every Text: 14/15/16. The clamp must not go below the
  // size (it used to cap at sm = 12 on mobile).
  static const bodyMedium = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.normal,
    height: 1.5,
  );

  static const bodySmall = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.normal,
    height: 1.5,
  );

  // ══════════════════════════════════════════════════════════════
  // LABEL
  // ══════════════════════════════════════════════════════════════

  static const labelLarge = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.w500,
  );

  static const labelMedium = AppTextStyle(
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.base,
    weight: FontWeight.w500,
  );

  static const labelSmall = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  // ══════════════════════════════════════════════════════════════
  // SPECIAL
  // ══════════════════════════════════════════════════════════════

  static const appBarTitle = AppTextStyle(
    size: AppFontSize.md,
    min: AppFontSize.base,
    max: AppFontSize.lg,
    weight: FontWeight.w600,
  );

  static const buttonText = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.w500,
    height: 1.2,
  );

  static const buttonTextSmall = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
    height: 1.2,
  );

  // ══════════════════════════════════════════════════════════════
  // NUMBERS AND AMOUNTS — tabular + lining figures
  // ══════════════════════════════════════════════════════════════

  /// KPI card amount: 28/700.
  static const amountKpi = AppTextStyle(
    size: AppFontSize.xxxl,
    min: AppFontSize.xxl,
    max: AppFontSize.hero,
    weight: FontWeight.bold,
    height: 1.2,
    fontFeatures: _tabularFigures,
  );

  /// Large amount (totals, balances): 20/600.
  static const amountLg = AppTextStyle(
    size: AppFontSize.xl,
    min: AppFontSize.lg,
    max: AppFontSize.xxl,
    weight: FontWeight.w600,
    height: 1.3,
    fontFeatures: _tabularFigures,
  );

  /// Amount in a table cell or an amount field: 14/500.
  static const amountTable = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.w500,
    fontFeatures: _tabularFigures,
  );

  /// Document number or code (INV-0001): 13/500.
  static const docCode = AppTextStyle(
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.base,
    weight: FontWeight.w500,
    fontFeatures: _tabularFigures,
  );

  /// Table column header: 12/600.
  static const tableHeader = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w600,
  );

  /// Barcode and SKU only: 13/400, IBM Plex Mono.
  static const codeMono = AppTextStyle(
    size: AppFontSize.sm,
    min: AppFontSize.xs,
    max: AppFontSize.base,
    weight: FontWeight.normal,
    fontFamily: AppFontFamily.mono,
  );

  // ══════════════════════════════════════════════════════════════
  // INPUT
  // ══════════════════════════════════════════════════════════════

  static const inputText = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.normal,
    height: 1.5,
  );

  static const inputLabel = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.w500,
  );

  static const inputHint = AppTextStyle(
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.normal,
    height: 1.5,
  );

  static const inputError = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.normal,
    height: 1.5,
  );

  // ══════════════════════════════════════════════════════════════
  // CAPTION / HELPER
  // ══════════════════════════════════════════════════════════════

  static const caption = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
    weight: FontWeight.normal,
    height: 1.5,
  );

  static const overline = AppTextStyle(
    size: AppFontSize.xs,
    min: AppFontSize.xs,
    max: AppFontSize.sm,
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
    size: AppFontSize.base,
    min: AppFontSize.sm,
    max: AppFontSize.md,
    weight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );
}
