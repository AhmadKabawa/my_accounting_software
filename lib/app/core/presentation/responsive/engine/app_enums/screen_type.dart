part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// SCREEN TYPE & ORIENTATION
// ═══════════════════════════════════════════════════════════════════

/// Screen type based on device width
///
/// Breakpoints:
/// - [mobile]: width < 600px (phones)
/// - [tablet]: width >= 600px and < 1200px (tablets, foldables)
/// - [desktop]: width >= 1200px (desktops, laptops, large tablets)
enum ScreenType {
  /// Mobile devices (phones) - width < 600px
  mobile,

  /// Tablet devices - width >= 600px and < 1200px
  tablet,

  /// Desktop devices - width >= 1200px
  desktop,
}
