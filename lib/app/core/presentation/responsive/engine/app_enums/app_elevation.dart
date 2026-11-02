part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// ELEVATION TOKENS
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Elevation shadow tokens for depth and hierarchy
///
/// Provides Material Design elevation shadows that respond to screen size,
/// helping establish visual hierarchy through consistent depth cues.
///
/// Example:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: AppElevation.md.shadows(context),
///   ),
/// )
/// ```
class AppElevation extends ResponsiveToken {
  const AppElevation(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// No elevation — flat surfaces
  /// Mobile: 0px | Tablet: 0px | Desktop: 0px
  static const none = AppElevation(0, 0, 0);

  /// Extra small elevation — very subtle depth (dividers)
  /// Mobile: 1px | Tablet: 2px | Desktop: 2px
  static const xs = AppElevation(1, 2, 2);

  /// Small elevation — subtle hover states, cards
  /// Mobile: 2px | Tablet: 3px | Desktop: 4px
  static const sm = AppElevation(2, 3, 4);

  /// Medium elevation — standard cards, buttons (default)
  /// Mobile: 4px | Tablet: 6px | Desktop: 8px
  static const md = AppElevation(4, 6, 8);

  /// Large elevation — elevated cards, dialogs
  /// Mobile: 8px | Tablet: 12px | Desktop: 16px
  static const lg = AppElevation(8, 12, 16);

  /// Extra large elevation — modals, floating panels
  /// Mobile: 12px | Tablet: 16px | Desktop: 20px
  static const xl = AppElevation(12, 16, 20);

  /// Double extra large elevation — prominent overlays
  /// Mobile: 16px | Tablet: 20px | Desktop: 24px
  static const xxl = AppElevation(16, 20, 24);

  @override
  AppElevation overrideWith({double? mobile, double? tablet, double? desktop}) {
    return AppElevation(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a list of [BoxShadow] for Material Design elevation
  ///
  /// Generates realistic shadows based on elevation value
  ///
  /// Example:
  /// ```dart
  /// Card(
  ///   elevation: AppElevation.md.of(context),
  ///   // or use custom shadows:
  ///   // shadowColor: Colors.black.withOpacity(0.1),
  /// )
  /// ```
  List<BoxShadow> shadows(BuildContext context) {
    final value = of(context);
    return [
      BoxShadow(
        offset: Offset(0, value / 2),
        blurRadius: value,
        spreadRadius: value / 4,
        color: Colors.black.withOpacity(0.1),
      ),
    ];
  }
}
