part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// COMPONENT SIZE TOKENS
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Component dimension tokens for consistent sizing
///
/// Provides standard sizes for common UI components, ensuring
/// consistent touch targets and visual proportions across screen sizes.
///
/// Example:
/// ```dart
/// SizedBox(
///   height: AppComponentSize.medium.of(context),
///   child: ElevatedButton(...),
/// )
/// ```
class AppComponentSize extends ResponsiveToken {
  const AppComponentSize(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// No size — zero dimension
  /// Mobile: 0px | Tablet: 0px | Desktop: 0px
  static const none = AppComponentSize(0, 0, 0);

  /// Tiny component — small badges, indicators
  /// Mobile: 32px | Tablet: 36px | Desktop: 40px
  static const tiny = AppComponentSize(32, 36, 40);

  /// Small component — compact buttons, chips
  /// Mobile: 36px | Tablet: 40px | Desktop: 44px
  static const small = AppComponentSize(36, 40, 44);

  /// Medium component — standard buttons, inputs
  /// Mobile: 40px | Tablet: 44px | Desktop: 48px
  static const medium = AppComponentSize(40, 44, 48);

  /// Large component — prominent buttons, tall inputs
  /// Mobile: 48px | Tablet: 52px | Desktop: 56px
  static const large = AppComponentSize(48, 52, 56);

  /// Extra large component — hero buttons, featured elements
  /// Mobile: 56px | Tablet: 60px | Desktop: 64px
  static const xLarge = AppComponentSize(56, 60, 64);

  /// Card width — standard card container width
  /// Mobile: 280px | Tablet: 320px | Desktop: 360px
  static const cardWidth = AppComponentSize(280, 320, 360);

  /// Card height — standard card container height
  /// Mobile: 200px | Tablet: 240px | Desktop: 280px
  static const cardHeight = AppComponentSize(200, 240, 280);

  /// Avatar — standard profile picture size
  /// Mobile: 40px | Tablet: 48px | Desktop: 56px
  static const avatar = AppComponentSize(40, 48, 56);

  /// Small avatar — compact avatar (list items)
  /// Mobile: 32px | Tablet: 36px | Desktop: 40px
  static const avatarSmall = AppComponentSize(32, 36, 40);

  /// Large avatar — prominent profile picture (profile screen)
  /// Mobile: 64px | Tablet: 72px | Desktop: 80px
  static const avatarLarge = AppComponentSize(64, 72, 80);

  /// Hit area — minimum touch target size (accessibility)
  /// Mobile: 44px | Tablet: 48px | Desktop: 52px
  static const hitArea = AppComponentSize(44, 48, 52);

  /// Full size — takes all available space
  /// Use with caution in [SizedBox] as it will try to expand infinitely
  static const full = AppComponentSize(
    double.infinity,
    double.infinity,
    double.infinity,
  );

  @override
  AppComponentSize overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppComponentSize(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a [SizedBox] with this size
  ///
  /// Convenient for creating empty spaces or fixed-size containers
  ///
  /// Parameters:
  /// - [isWidth]: If true, creates width SizedBox, otherwise height
  ///
  /// Example:
  /// ```dart
  /// // Vertical spacing
  /// AppComponentSize.medium.sizedBox(context)
  ///
  /// // Horizontal spacing
  /// AppComponentSize.medium.sizedBox(context, isWidth: true)
  /// ```
  SizedBox sizedBox(BuildContext context, {bool isWidth = false}) {
    final value = of(context);
    return isWidth ? SizedBox(width: value) : SizedBox(height: value);
  }

  /// Creates [BoxConstraints] with this size as minimum
  ///
  /// Useful for constraining widgets to a minimum size
  ///
  /// Parameters:
  /// - [isWidth]: If true, sets minWidth, otherwise minHeight
  ///
  /// Example:
  /// ```dart
  /// ConstrainedBox(
  ///   constraints: AppComponentSize.hitArea.constraints(context),
  ///   child: IconButton(...),
  /// )
  /// ```
  BoxConstraints constraints(BuildContext context, {bool isWidth = true}) {
    final value = of(context);
    return isWidth
        ? BoxConstraints(minWidth: value)
        : BoxConstraints(minHeight: value);
  }
}
