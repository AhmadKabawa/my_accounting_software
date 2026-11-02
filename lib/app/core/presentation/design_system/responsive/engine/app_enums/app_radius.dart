part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// RADIUS TOKEN
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Intent-based corner radius tokens
///
/// Each value represents a corner radius intent, not a fixed pixel value.
/// Automatically adapts to screen size while maintaining visual harmony.
///
/// Example:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.md.of(context),
///   ),
/// )
/// ```
class AppRadius extends ResponsiveToken {
  const AppRadius(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// No rounded corners — sharp edges (0px)
  /// Mobile: 0px | Tablet: 0px | Desktop: 0px
  static const none = AppRadius(0, 0, 0);

  /// Extra small radius — subtle rounding (buttons, chips)
  /// Mobile: 4px | Tablet: 6px | Desktop: 8px
  static const xs = AppRadius(4, 6, 8);

  /// Small radius — standard for small elements (inputs, cards)
  /// Mobile: 8px | Tablet: 10px | Desktop: 12px
  static const sm = AppRadius(8, 10, 12);

  /// Medium radius — default for most containers
  /// Mobile: 12px | Tablet: 14px | Desktop: 16px
  static const md = AppRadius(12, 14, 16);

  /// Large radius — prominent cards, modals, dialogs
  /// Mobile: 16px | Tablet: 20px | Desktop: 24px
  static const lg = AppRadius(16, 20, 24);

  /// Extra large radius — floating panels, bottom sheets
  /// Mobile: 24px | Tablet: 28px | Desktop: 32px
  static const xl = AppRadius(24, 28, 32);

  /// Double extra large radius — hero sections, feature cards
  /// Mobile: 32px | Tablet: 40px | Desktop: 48px
  static const xxl = AppRadius(32, 40, 48);

  /// Full circular radius — perfect circles (avatars, badges)
  /// Mobile: 999px | Tablet: 999px | Desktop: 999px
  static const full = AppRadius(999, 999, 999);

  @override
  AppRadius overrideWith({double? mobile, double? tablet, double? desktop}) {
    return AppRadius(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a [BorderRadius] with the same radius for all corners
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: AppRadius.md.circular(context),
  ///   ),
  /// )
  /// ```
  BorderRadius circular(BuildContext context) =>
      BorderRadius.circular(of(context));

  /// Creates a [BorderRadius] with rounded corners only on the top
  ///
  /// Useful for bottom sheets and modals that attach to the screen bottom
  ///
  /// Example:
  /// ```dart
  /// showModalBottomSheet(
  ///   shape: RoundedRectangleBorder(
  ///     borderRadius: AppRadius.lg.top(context),
  ///   ),
  /// )
  /// ```
  BorderRadius top(BuildContext context) =>
      corners(context, topLeft: true, topRight: true);

  /// Creates a [BorderRadius] with rounded corners only on the bottom
  ///
  /// Useful for top-anchored elements like dropdown menus
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: AppRadius.md.bottom(context),
  ///   ),
  /// )
  /// ```
  BorderRadius bottom(BuildContext context) =>
      corners(context, bottomLeft: true, bottomRight: true);

  /// Creates a [BorderRadius] with custom corner selection
  ///
  /// Allows fine-grained control over which corners are rounded
  ///
  /// Parameters:
  /// - [topLeft]: Round top-left corner
  /// - [topRight]: Round top-right corner
  /// - [bottomLeft]: Round bottom-left corner
  /// - [bottomRight]: Round bottom-right corner
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: AppRadius.md.corners(
  ///       context,
  ///       topLeft: true,
  ///       bottomRight: true,
  ///     ),
  ///   ),
  /// )
  /// ```
  BorderRadius corners(
    BuildContext context, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final r = Radius.circular(of(context));
    return BorderRadius.only(
      topLeft: topLeft ? r : Radius.zero,
      topRight: topRight ? r : Radius.zero,
      bottomLeft: bottomLeft ? r : Radius.zero,
      bottomRight: bottomRight ? r : Radius.zero,
    );
  }
}
