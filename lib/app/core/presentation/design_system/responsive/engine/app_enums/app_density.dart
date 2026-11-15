part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// DENSITY TOKEN
// ═══════════════════════════════════════════════════════════════════

/// Row / header / field heights of the two densities.
///
/// - [comfortable] (default): row 48, header 40, field 44.
/// - [compact]: row 36, header 32, field 36. For dense tables on desktop.
///
/// On a phone the touch target never drops below 44 (48 for icons), even in
/// compact: [rowHeight], [fieldHeight] and [headerHeight] apply that floor
/// when given the screen type.
enum AppDensity {
  comfortable(row: 48, header: 40, field: 44),
  compact(row: 36, header: 32, field: 36);

  const AppDensity({
    required this.row,
    required this.header,
    required this.field,
  });

  final double row;
  final double header;
  final double field;

  /// The minimum touch target on a phone.
  static const double phoneMinTouchTarget = 44;

  double rowHeight(ScreenType type) =>
      type == ScreenType.mobile && row < phoneMinTouchTarget
      ? phoneMinTouchTarget
      : row;

  double fieldHeight(ScreenType type) =>
      type == ScreenType.mobile && field < phoneMinTouchTarget
      ? phoneMinTouchTarget
      : field;

  double headerHeight(ScreenType type) =>
      type == ScreenType.mobile && header < phoneMinTouchTarget
      ? phoneMinTouchTarget
      : header;
}
