part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// SPACING TOKEN
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Intent-based spacing tokens
///
/// Each value represents an intent (none/xs/sm/md/lg/etc.) not a fixed pixel.
/// The actual value changes responsively:
/// - Mobile: baseline (primary value)
/// - Tablet: medium value (scaled up from mobile)
/// - Desktop: larger value (further scaled)
///
/// Example:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md.of(context)),
/// )
/// SizedBox(height: AppSpacing.lg.of(context))
/// ```
class AppSpacing extends ResponsiveToken {
  const AppSpacing(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// No spacing — zero padding/margin (0px)
  /// Mobile: 0px | Tablet: 0px | Desktop: 0px
  static const none = AppSpacing(0, 0, 0);

  /// Extra small spacing — tight elements or small gaps
  /// Mobile: 4px | Tablet: 6px | Desktop: 8px
  static const xs = AppSpacing(4, 6, 8);

  /// Small spacing — between related items or icon spacing
  /// Mobile: 8px | Tablet: 12px | Desktop: 16px
  static const sm = AppSpacing(8, 12, 16);

  /// Small-medium spacing — between form fields or list items
  /// Mobile: 12px | Tablet: 16px | Desktop: 20px
  static const smMd = AppSpacing(12, 16, 20);

  /// Medium spacing (default) — standard padding for cards/sections
  /// Mobile: 16px | Tablet: 20px | Desktop: 24px
  static const md = AppSpacing(16, 20, 24);

  /// Medium-large spacing — between major sections
  /// Mobile: 20px | Tablet: 24px | Desktop: 28px
  static const mdLg = AppSpacing(20, 24, 28);

  /// Large spacing — between unrelated components
  /// Mobile: 24px | Tablet: 32px | Desktop: 40px
  static const lg = AppSpacing(24, 32, 40);

  /// Extra large spacing — screen padding or major separations
  /// Mobile: 32px | Tablet: 40px | Desktop: 48px
  static const xl = AppSpacing(32, 40, 48);

  /// Double extra large spacing — large margins or group separation
  /// Mobile: 40px | Tablet: 48px | Desktop: 56px
  static const xxl = AppSpacing(40, 48, 56);

  /// Triple extra large spacing — hero sections or big separators
  /// Mobile: 48px | Tablet: 56px | Desktop: 64px
  static const xxxl = AppSpacing(48, 56, 64);

  /// Huge spacing — major layout sections
  /// Mobile: 64px | Tablet: 72px | Desktop: 80px
  static const huge = AppSpacing(64, 72, 80);

  /// Giant spacing — extreme separations (sections, modals)
  /// Mobile: 80px | Tablet: 96px | Desktop: 112px
  static const giant = AppSpacing(80, 96, 112);

  /// Returns a human-readable label for the spacing token
  ///
  /// Useful for debugging or accessibility descriptions
  String get label => switch (this) {
    AppSpacing() when this == AppSpacing.none => 'no spacing',
    AppSpacing() when this == AppSpacing.xs => 'extra small',
    AppSpacing() when this == AppSpacing.sm => 'small',
    AppSpacing() when this == AppSpacing.smMd => 'small-medium',
    AppSpacing() when this == AppSpacing.md => 'medium (default)',
    AppSpacing() when this == AppSpacing.mdLg => 'medium-large',
    AppSpacing() when this == AppSpacing.lg => 'large',
    AppSpacing() when this == AppSpacing.xl => 'extra large',
    AppSpacing() when this == AppSpacing.xxl => 'double extra large',
    AppSpacing() when this == AppSpacing.xxxl => 'triple extra large',
    AppSpacing() when this == AppSpacing.huge => 'huge',
    AppSpacing() when this == AppSpacing.giant => 'giant',
    _ => 'custom spacing',
  };

  @override
  AppSpacing overrideWith({double? mobile, double? tablet, double? desktop}) {
    return AppSpacing(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }
}
