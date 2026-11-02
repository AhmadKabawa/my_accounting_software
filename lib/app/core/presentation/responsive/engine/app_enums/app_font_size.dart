part of '../app_enums.dart';

// ═══════════════════════════════════════════════════════════════════
// FONT SIZE TOKENS
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Typography size tokens for responsive text
///
/// Each token represents a typographic intent, automatically adapting
/// to screen size while maintaining proper readability and hierarchy.
///
/// Example:
/// ```dart
/// Text(
///   'Hello World',
///   style: AppFontSize.lg.style(context, weight: FontWeight.bold),
/// )
/// ```
class AppFontSize extends ResponsiveToken {
  const AppFontSize(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// Tiny text — captions, metadata, timestamps
  /// Mobile: 8px | Tablet: 10px | Desktop: 12px
  static const tiny = AppFontSize(8, 10, 12);

  /// Extra small text — secondary information, badges
  /// Mobile: 10px | Tablet: 12px | Desktop: 14px
  static const xs = AppFontSize(10, 12, 14);

  /// Small text — helper text, footnotes, labels
  /// Mobile: 12px | Tablet: 13px | Desktop: 14px
  static const sm = AppFontSize(12, 13, 14);

  /// Base text — body text, paragraphs (default)
  /// Mobile: 14px | Tablet: 15px | Desktop: 16px
  static const base = AppFontSize(14, 15, 16);

  /// Medium text — emphasized body text, list items
  /// Mobile: 16px | Tablet: 17px | Desktop: 18px
  static const md = AppFontSize(16, 17, 18);

  /// Large text — subheadings, section titles
  /// Mobile: 18px | Tablet: 20px | Desktop: 22px
  static const lg = AppFontSize(18, 20, 22);

  /// Extra large text — headings (H3), card titles
  /// Mobile: 20px | Tablet: 22px | Desktop: 24px
  static const xl = AppFontSize(20, 22, 24);

  /// Double extra large text — major headings (H2)
  /// Mobile: 24px | Tablet: 26px | Desktop: 28px
  static const xxl = AppFontSize(24, 26, 28);

  /// Triple extra large text — section headings (H1)
  /// Mobile: 28px | Tablet: 30px | Desktop: 32px
  static const xxxl = AppFontSize(28, 30, 32);

  /// Hero text — main headlines, featured content
  /// Mobile: 32px | Tablet: 36px | Desktop: 40px
  static const hero = AppFontSize(32, 36, 40);

  /// Display text — very large headlines (welcome screens)
  /// Mobile: 40px | Tablet: 44px | Desktop: 48px
  static const display = AppFontSize(40, 44, 48);

  @override
  AppFontSize overrideWith({double? mobile, double? tablet, double? desktop}) {
    return AppFontSize(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a [TextStyle] with this font size
  ///
  /// Convenient method for quick text styling with responsive sizes
  ///
  /// Parameters:
  /// - [weight]: Font weight (bold, regular, etc.)
  /// - [color]: Text color
  /// - [height]: Line height multiplier
  /// - [decoration]: Text decoration (underline, etc.)
  ///
  /// Example:
  /// ```dart
  /// Text(
  ///   'Title',
  ///   style: AppFontSize.xl.style(
  ///     context,
  ///     weight: FontWeight.bold,
  ///     color: Colors.blue,
  ///   ),
  /// )
  /// ```
  TextStyle style(
    BuildContext context, {
    FontWeight? weight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) => TextStyle(
    fontSize: of(context),
    fontWeight: weight,
    color: color,
    height: height,
    decoration: decoration,
  );
}
