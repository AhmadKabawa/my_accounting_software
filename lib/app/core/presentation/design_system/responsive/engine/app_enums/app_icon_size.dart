part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// ICON SIZE TOKENS
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Icon size tokens for responsive iconography
///
/// Ensures icons scale appropriately across different screen sizes
/// while maintaining proportional visual weight.
///
/// Example:
/// ```dart
/// Icon(
///   Icons.star,
///   size: AppIconSize.md.of(context),
/// )
/// ```
class AppIconSize extends ResponsiveToken {
  const AppIconSize(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// Small icon — inline icons, badges, indicator icons
  /// Mobile: 16px | Tablet: 18px | Desktop: 20px
  static const sm = AppIconSize(16, 18, 20);

  /// Medium icon — standard icons (buttons, list tiles)
  /// Mobile: 20px | Tablet: 22px | Desktop: 24px
  static const md = AppIconSize(20, 22, 24);

  /// Large icon — prominent actions, section icons
  /// Mobile: 24px | Tablet: 28px | Desktop: 32px
  static const lg = AppIconSize(24, 28, 32);

  /// Extra large icon — feature highlights, empty states
  /// Mobile: 32px | Tablet: 36px | Desktop: 40px
  static const xl = AppIconSize(32, 36, 40);

  /// Double extra large icon — hero sections, illustrations
  /// Mobile: 40px | Tablet: 44px | Desktop: 48px
  static const xxl = AppIconSize(40, 44, 48);

  /// Huge icon — very prominent visuals, onboarding
  /// Mobile: 48px | Tablet: 52px | Desktop: 56px
  static const huge = AppIconSize(48, 52, 56);

  @override
  AppIconSize overrideWith({double? mobile, double? tablet, double? desktop}) {
    return AppIconSize(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }
}
