part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// BASE RESPONSIVE TOKEN CLASS
// ═══════════════════════════════════════════════════════════════════

/// Abstract base class for all responsive design tokens
///
/// Provides core functionality for responsive values:
/// - Different values per screen type (mobile/tablet/desktop)
/// - Context-aware value retrieval
/// - Scaling capabilities
/// - Type-safe overrides
///
/// Example:
/// ```dart
/// class MyToken extends ResponsiveToken {
///   const MyToken(super.mobile, super.tablet, super.desktop);
///
///   static const small = MyToken(8, 12, 16);
///   static const large = MyToken(16, 24, 32);
/// }
/// ```
abstract class ResponsiveToken {
  /// Value for mobile screens (< 600px)
  final double mobile;

  /// Value for tablet screens (>= 600px and < 1200px)
  final double tablet;

  /// Value for desktop screens (>= 1200px)
  final double desktop;

  const ResponsiveToken(this.mobile, this.tablet, this.desktop);

  /// Returns the appropriate value for the current screen type
  ///
  /// Automatically detects screen type using [ScreenEngine.screenType()]
  ///
  /// Example:
  /// ```dart
  /// final spacing = AppSpacing.md.of(context);
  /// ```
  double of(BuildContext context) {
    return switch (ScreenEngine.screenType(context)) {
      ScreenType.mobile => mobile,
      ScreenType.tablet => tablet,
      ScreenType.desktop => desktop,
    };
  }

  /// Returns the value for a specific screen type
  ///
  /// Useful when you need to bypass automatic detection
  ///
  /// Example:
  /// ```dart
  /// final mobileValue = AppSpacing.md.forType(ScreenType.mobile);
  /// ```
  double forType(ScreenType type) {
    return switch (type) {
      ScreenType.mobile => mobile,
      ScreenType.tablet => tablet,
      ScreenType.desktop => desktop,
    };
  }

  /// Returns the value multiplied by a factor
  ///
  /// Useful for dynamic scaling based on user preferences or animations
  ///
  /// Example:
  /// ```dart
  /// final scaledValue = AppSpacing.md.scaled(context, 1.5);
  /// ```
  double scaled(BuildContext context, double factor) => of(context) * factor;

  /// Returns a new instance with overridden values
  ///
  /// Allows customizing specific values while keeping others unchanged
  ///
  /// Example:
  /// ```dart
  /// final customSpacing = AppSpacing.md.overrideWith(mobile: 20);
  /// ```
  ResponsiveToken overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  });

  // ✅ ضروري لصحة المقارنات
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResponsiveToken &&
          runtimeType == other.runtimeType &&
          mobile == other.mobile &&
          tablet == other.tablet &&
          desktop == other.desktop);

  @override
  int get hashCode => Object.hash(runtimeType, mobile, tablet, desktop);

  @override
  String toString() =>
      '$runtimeType(mobile: $mobile, tablet: $tablet, desktop: $desktop)';
}
