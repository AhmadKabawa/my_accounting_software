part of '../ui_extension.dart';

// ═══════════════════════════════════════════════════════════════════
// AppTextStyle → responsive TextStyle
// ═══════════════════════════════════════════════════════════════════

/// Resolves an [AppTextStyle] for the screen under [context].
///
/// Lives here rather than in `theme/` because the theme must not depend on the
/// responsive engine; the theme only ever uses [AppTextStyle.baseline].
extension AppTextStyleResolver on AppTextStyle {
  /// [mode] and [respectTextScaler] override the descriptor's own values.
  TextStyle resolve(
    BuildContext context, {
    ResponsiveMode? mode,
    bool? respectTextScaler,
  }) => Rh.textStyle(
    context,
    size,
    min: min,
    max: max,
    weight: weight,
    height: height,
    letterSpacing: 0,
    respectTextScaler: respectTextScaler ?? this.respectTextScaler,
    mode: mode ?? this.mode,
  ).copyWith(decoration: decoration);
}
