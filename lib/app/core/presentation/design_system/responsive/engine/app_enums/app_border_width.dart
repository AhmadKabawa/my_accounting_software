part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// BORDER WIDTH TOKEN
// ═══════════════════════════════════════════════════════════════════

/// Intent-based border / divider thickness. Hairlines do not grow with the
/// screen, so every size is the same on all device types; the token exists so
/// no screen or widget writes a raw number.
///
/// ```dart
/// BorderSide(width: AppBorderWidth.thin.of(context))
/// ```
class AppBorderWidth extends ResponsiveToken {
  const AppBorderWidth(super.mobile, super.tablet, super.desktop);

  /// Default outline of inputs, cards and dividers (1px).
  static const thin = AppBorderWidth(1, 1, 1);

  /// Emphasis: focused field, selected item (2px).
  static const thick = AppBorderWidth(2, 2, 2);

  @override
  AppBorderWidth overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppBorderWidth(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }
}
