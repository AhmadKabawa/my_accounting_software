import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_tokens.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';

// ═══════════════════════════════════════════════════════════════════
// RESPONSIVE MODE ENUM
// ═══════════════════════════════════════════════════════════════════

/// Defines how responsive values are calculated
///
/// Each mode provides a different strategy for handling responsive values:
/// - [fixed]: Uses mobile baseline only, no adaptation
/// - [scaleOnly]: Scales mobile baseline by screen width
/// - [adaptiveOnly]: Different values per screen type, no scaling
/// - [adaptiveScale]: Different values AND scales by width (default)
enum ResponsiveMode {
  /// Fixed value - uses mobile baseline only
  fixed,

  /// Scale only - scales mobile baseline by screen width
  scaleOnly,

  /// Adaptive only - different values per screen type, no scaling
  adaptiveOnly,

  /// Adaptive + Scale (default) - different values AND scales by width
  adaptiveScale,
}

// ═══════════════════════════════════════════════════════════════════
// SCREEN TYPE & ORIENTATION
// ═══════════════════════════════════════════════════════════════════

/// Screen type based on device width
///
/// Breakpoints:
/// - [mobile]: width < 768px (phones)
/// - [tablet]: width >= 768px and < 1280px (tablets, foldables)
/// - [desktop]: width >= 1280px (desktops, laptops, large tablets)
enum ScreenType {
  /// Mobile devices (phones) - width < 768px
  mobile,

  /// Tablet devices - width >= 768px and < 1280px
  tablet,

  /// Desktop devices - width >= 1280px
  desktop,
}

/// Device orientation state
enum AppOrientation {
  /// Portrait mode (height > width)
  portrait,

  /// Landscape mode (width > height)
  landscape,
}

// ═══════════════════════════════════════════════════════════════════
// BASE WIDTH (Figma Frame Reference)
// ═══════════════════════════════════════════════════════════════════

/// Reference screen widths for design tokens (Figma frame sizes)
///
/// These values represent common device widths used as design references:
/// - Small phones: 320px (iPhone SE, Galaxy Fold folded)
/// - Standard phones: 375px (iPhone 12/13/14)
/// - Pro phones: 390px (iPhone 15 Pro)
/// - Large phones: 430px (iPhone 15 Pro Max)
/// - Wide phones/foldables: 600px (Galaxy Fold unfolded)
/// - Tablets: 768px (iPad Mini)
/// - Large tablets: 1024px (iPad Pro 11")
/// - Desktops: 1280px (HD ready)
/// - Wide desktops: 1440px (Full HD+)
enum AppBaseWidth {
  /// Small phones (iPhone SE, Galaxy Fold folded) - 320px
  small(320),

  /// Standard phones (iPhone 12/13/14) - 375px
  phone(375),

  /// Pro phones (iPhone 15 Pro) - 390px
  phonePro(390),

  /// Large phones (iPhone 15 Pro Max) - 430px
  phoneLarge(430),

  /// Wide phones / foldables (Galaxy Fold unfolded) - 600px
  phoneWide(600),

  /// Tablets (iPad Mini) - 768px
  tablet(768),

  /// Large tablets (iPad Pro 11") - 1024px
  tabletLarge(1024),

  /// Desktop (HD ready) - 1280px
  desktop(1280),

  /// Wide desktop (Full HD+) - 1440px
  desktopWide(1440);

  const AppBaseWidth(this.value);

  /// The width value in pixels
  final double value;
}

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
  /// Value for mobile screens (< 768px)
  final double mobile;

  /// Value for tablet screens (>= 768px and < 1280px)
  final double tablet;

  /// Value for desktop screens (>= 1280px)
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
  /// Mobile: 4px | Tablet: 10px | Desktop: 8px
  static const xs = AppSpacing(4, 10, 8);

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

class AppAspectRatio extends ResponsiveToken {
  const AppAspectRatio(super.mobile, super.tablet, super.desktop);

  // ─── Predefined tokens ───────────────────────────────────────────

  /// Tiny component — small badges, indicators
  /// Mobile: 16:9 | Tablet: 1  | Desktop: 4 / 3
  static const bannerImage = AppComponentSize(1, 16 / 10, 16 / 9);

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
}

   // ─────────────────────────────────────────────────────────────────
/*
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_tokens.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';

 
// ═══════════════════════════════════════════════════════════════════
// RESPONSIVE MODE ENUM
// ═══════════════════════════════════════════════════════════════════

enum ResponsiveMode {
  /// Fixed value - uses mobile baseline only
  fixed,

  /// Scale only - scales mobile baseline by screen width
  scaleOnly,

  /// Adaptive only - different values per screen type, no scaling
  adaptiveOnly,

  /// Adaptive + Scale (default) - different values AND scales by width
  adaptiveScale,
}

// ═══════════════════════════════════════════════════════════════════
// SCREEN TYPE & ORIENTATION
// ═══════════════════════════════════════════════════════════════════

enum ScreenType {
  mobile, // width < 768px
  tablet, // width >= 768px and < 1280px
  desktop, // width >= 1280px
}

enum AppOrientation { portrait, landscape }

// ═══════════════════════════════════════════════════════════════════
// BASE WIDTH (Figma Frame Reference)
// ═══════════════════════════════════════════════════════════════════

enum AppBaseWidth {
  small(320),
  phone(375),
  phonePro(390),
  phoneLarge(430),
  phoneWide(600),
  tablet(768),
  tabletLarge(1024),
  desktop(1280),
  desktopWide(1440);

  const AppBaseWidth(this.value);
  final double value;
}

// ═══════════════════════════════════════════════════════════════════
// MIXIN: Responsive Value Behavior (لكل الـ Enums)
// ═══════════════════════════════════════════════════════════════════
class ResponsiveOverride with ResponsiveEnumMixin {
  @override
  final double mobile;
  @override
  final double tablet;
  @override
  final double desktop;

  const ResponsiveOverride(this.mobile, this.tablet, this.desktop);
}
/// Mixin يوفر responsive behavior لأي enum
mixin ResponsiveEnumMixin {
  double get mobile;
  double get tablet;
  double get desktop;

  /// الطريقة الموحدة لكل الـ enums
  double of(BuildContext context) {
    return switch (ScreenEngine.screenType(context)) {
      ScreenType.mobile => mobile,
      ScreenType.tablet => tablet,
      ScreenType.desktop => desktop,
    };
  }

  /// للحصول على القيمة لنوع شاشة محدد
  double forType(ScreenType type) {
    return switch (type) {
      ScreenType.mobile => mobile,
      ScreenType.tablet => tablet,
      ScreenType.desktop => desktop,
    };
  }

  /// ضرب القيمة في factor معين
  double scaled(BuildContext context, double factor) => of(context) * factor;
}

// ═══════════════════════════════════════════════════════════════════
// SPACING TOKENS
// ═══════════════════════════════════════════════════════════════════

enum AppSpacing with ResponsiveEnumMixin {
  none(0, 0, 0),
  xs(4, 10, 8),
  sm(8, 12, 16),
  smMd(12, 16, 20),
  md(16, 20, 24),
  mdLg(20, 24, 28),
  lg(24, 32, 40),
  xl(32, 40, 48),
  xxl(40, 48, 56),
  xxxl(48, 56, 64),
  huge(64, 72, 80),
  giant(80, 96, 112);

  const AppSpacing(this.mobile, this.tablet, this.desktop);

  @override
  final double mobile;
  @override
  final double tablet;
  @override
  final double desktop;

  String get label => switch (this) {
    none => 'no spacing',
    xs => 'extra small',
    sm => 'small',
    smMd => 'small-medium',
    md => 'medium (default)',
    mdLg => 'medium-large',
    lg => 'large',
    xl => 'extra large',
    xxl => 'double extra large',
    xxxl => 'triple extra large',
    huge => 'huge',
    giant => 'giant',
  };

 ResponsiveOverride overrideWith({
  double? mobile,
  double? tablet,
  double? desktop,
}) {
  return ResponsiveOverride(
    mobile ?? this.mobile,
    tablet ?? this.tablet,
    desktop ?? this.desktop,
  );
}
}

// ═══════════════════════════════════════════════════════════════════
// RADIUS TOKENS
// ═══════════════════════════════════════════════════════════════════

enum AppRadius with ResponsiveEnumMixin {
  none(0, 0, 0),
  xs(4, 6, 8),
  sm(8, 10, 12),
  md(12, 14, 16),
  lg(16, 20, 24),
  xl(24, 28, 32),
  xxl(32, 40, 48),
  full(999, 999, 999);

  const AppRadius(this.mobile, this.tablet, this.desktop);

  @override
  final double mobile;
  @override
  final double tablet;
  @override
  final double desktop;

  /// Returns BorderRadius for all corners
  BorderRadius circular(BuildContext context) =>
      BorderRadius.circular(of(context));

  /// Returns BorderRadiusDirectional (RTL-aware)
  BorderRadiusDirectional directional(BuildContext context) =>
      BorderRadiusDirectional.circular(of(context));

  /// Returns BorderRadius for specific corners
  BorderRadius corners(
    BuildContext context, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final value = of(context);
    final corner = Radius.circular(value);
    return BorderRadius.only(
      topLeft: topLeft ? corner : Radius.zero,
      topRight: topRight ? corner : Radius.zero,
      bottomLeft: bottomLeft ? corner : Radius.zero,
      bottomRight: bottomRight ? corner : Radius.zero,
    );
  }

  /// Top corners only (for BottomSheet)
  BorderRadius top(BuildContext context) =>
      corners(context, topLeft: true, topRight: true);

  /// Bottom corners only
  BorderRadius bottom(BuildContext context) =>
      corners(context, bottomLeft: true, bottomRight: true);
}

// ═══════════════════════════════════════════════════════════════════
// FONT SIZE TOKENS
// ═══════════════════════════════════════════════════════════════════

enum AppFontSize with ResponsiveEnumMixin {
  tiny(8, 10, 12),
  xs(10, 12, 14),
  sm(12, 13, 14),
  base(14, 15, 16),
  md(16, 17, 18),
  lg(18, 20, 22),
  xl(20, 22, 24),
  xxl(24, 26, 28),
  xxxl(28, 30, 32),
  hero(32, 36, 40),
  display(40, 44, 48);

  const AppFontSize(this.mobile, this.tablet, this.desktop);

  @override
  final double mobile;
  @override
  final double tablet;
  @override
  final double desktop;

  /// Creates a TextStyle with this font size
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

// ═══════════════════════════════════════════════════════════════════
// ICON SIZE TOKENS
// ═══════════════════════════════════════════════════════════════════

enum AppIconSize with ResponsiveEnumMixin {
  sm(16, 18, 20),
  md(20, 22, 24),
  lg(24, 28, 32),
  xl(32, 36, 40),
  xxl(40, 44, 48),
  huge(48, 52, 56);

  const AppIconSize(this.mobile, this.tablet, this.desktop);

  @override
  final double mobile;
  @override
  final double tablet;
  @override
  final double desktop;
}

// ═══════════════════════════════════════════════════════════════════
// ELEVATION TOKENS
// ═══════════════════════════════════════════════════════════════════

enum AppElevation with ResponsiveEnumMixin {
  none(0, 0, 0),
  xs(1, 2, 2),
  sm(2, 3, 4),
  md(4, 6, 8),
  lg(8, 12, 16),
  xl(12, 16, 20),
  xxl(16, 20, 24);

  const AppElevation(this.mobile, this.tablet, this.desktop);

  @override
  final double mobile;
  @override
  final double tablet;
  @override
  final double desktop;

  /// Creates BoxShadow list for Material elevation
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

// ═══════════════════════════════════════════════════════════════════
// COMPONENT SIZE TOKENS
// ═══════════════════════════════════════════════════════════════════

enum AppComponentSize with ResponsiveEnumMixin {
  none(0, 0, 0),
  tiny(32, 36, 40),
  small(36, 40, 44),
  medium(40, 44, 48),
  large(48, 52, 56),
  xLarge(56, 60, 64),
  cardWidth(280, 320, 360),
  cardHeight(200, 240, 280),
  avatar(40, 48, 56),
  avatarSmall(32, 36, 40),
  avatarLarge(64, 72, 80),
  hitArea(44, 48, 52),
  full(double.infinity, double.infinity, double.infinity);

  const AppComponentSize(this.mobile, this.tablet, this.desktop);

  @override
  final double mobile;
  @override
  final double tablet;
  @override
  final double desktop;

  /// Creates a SizedBox with this size
  SizedBox sizedBox(BuildContext context, {bool isWidth = false}) {
    final value = of(context);
    return isWidth ? SizedBox(width: value) : SizedBox(height: value);
  }

  /// Creates BoxConstraints with this size as minimum
  BoxConstraints constraints(BuildContext context, {bool isWidth = true}) {
    final value = of(context);
    return isWidth
        ? BoxConstraints(minWidth: value)
        : BoxConstraints(minHeight: value);
  }
}

*/

/*
// ─────────────────────────────────────────────────────────────────
// app_enums.dart
// All design-system enums.
// Import this file (or the barrel) to use AppSpacing, AppRadius, etc.
//
// Depends on: app_tokens.dart (for raw values)
//             flutter/material.dart (AppRadius needs BorderRadius)
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_tokens.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';
// ─────────────────────────────────────────────────────────────────
// app_enums.dart
// All design-system enums.
// Import this file (or the barrel) to use AppSpacing, AppRadius, etc.
//
// Depends on: app_tokens.dart (for raw values)
//             flutter/material.dart (AppRadius needs BorderRadius)
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_tokens.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';

// ═══════════════════════════════════════════════════════════════════
// VALUE CLASSES (تضاف في الأعلى)
// ═══════════════════════════════════════════════════════════════════

/// Spacing value class with responsive support
class AppSpacingValue {
  final double mobile;
  final double tablet;
  final double desktop;

  const AppSpacingValue(this.mobile, this.tablet, this.desktop);

  double resolve(BuildContext context) {
    switch (ScreenEngine.screenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  double get(BuildContext context) => resolve(context);
}

/// Radius value class with responsive support
class AppRadiusValue {
  final double mobile;
  final double tablet;
  final double desktop;

  const AppRadiusValue(this.mobile, this.tablet, this.desktop);

  double resolve(BuildContext context) {
    switch (ScreenEngine.screenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  double get(BuildContext context) => resolve(context);
}

/// Font size value class with responsive support
class AppFontSizeValue {
  final double mobile;
  final double tablet;
  final double desktop;

  const AppFontSizeValue(this.mobile, this.tablet, this.desktop);

  double resolve(BuildContext context) {
    switch (ScreenEngine.screenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  double get(BuildContext context) => resolve(context);
}

/// Icon size value class with responsive support
class AppIconSizeValue {
  final double mobile;
  final double tablet;
  final double desktop;

  const AppIconSizeValue(this.mobile, this.tablet, this.desktop);

  double resolve(BuildContext context) {
    switch (ScreenEngine.screenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  double get(BuildContext context) => resolve(context);
}

/// Elevation value class with responsive support
class AppElevationValue {
  final double mobile;
  final double tablet;
  final double desktop;

  const AppElevationValue(this.mobile, this.tablet, this.desktop);

  double resolve(BuildContext context) {
    switch (ScreenEngine.screenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  double get(BuildContext context) => resolve(context);
}

/// Component size value class with responsive support
class AppComponentSizeValue {
  final double mobile;
  final double tablet;
  final double desktop;

  const AppComponentSizeValue(this.mobile, this.tablet, this.desktop);

  double resolve(BuildContext context) {
    switch (ScreenEngine.screenType(context)) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  double get(BuildContext context) => resolve(context);
}

// ═══════════════════════════════════════════════════════════════════
// SPACING
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
///   padding: EdgeInsets.all(AppSpacing.md.get(context)),
/// )
/// ```
enum AppSpacing {
  /// No spacing — 0px on all devices
  /// Mobile: 0px (baseline) | Tablet: 0px | Desktop: 0px
  none(SpacingTokens.s0, SpacingTokens.s0, SpacingTokens.s0),

  /// Extra small spacing — minimal gap between tightly grouped elements
  /// Mobile: 4px (baseline) | Tablet: 10px | Desktop: 8px
  xs(SpacingTokens.s4, 10, SpacingTokens.s8),

  /// Small spacing — between related elements (icon + label)
  /// Mobile: 8px (baseline) | Tablet: 12px | Desktop: 16px
  sm(SpacingTokens.s8, SpacingTokens.s12, SpacingTokens.s16),

  /// Small-medium spacing — between form fields or list items
  /// Mobile: 12px (baseline) | Tablet: 16px | Desktop: 20px
  smMd(SpacingTokens.s12, SpacingTokens.s16, SpacingTokens.s20),

  /// Medium spacing (default) — standard padding for cards and containers
  /// Mobile: 16px (baseline) | Tablet: 20px | Desktop: 24px
  md(SpacingTokens.s16, SpacingTokens.s20, SpacingTokens.s24),

  /// Medium-large spacing — between sections within a card
  /// Mobile: 20px (baseline) | Tablet: 24px | Desktop: 28px
  mdLg(SpacingTokens.s20, SpacingTokens.s24, 28),

  /// Large spacing — between major UI sections
  /// Mobile: 24px (baseline) | Tablet: 32px | Desktop: 40px
  lg(SpacingTokens.s24, SpacingTokens.s32, SpacingTokens.s40),

  /// Extra large spacing — screen-level padding
  /// Mobile: 32px (baseline) | Tablet: 40px | Desktop: 48px
  xl(SpacingTokens.s32, SpacingTokens.s40, SpacingTokens.s48),

  /// Double extra large spacing — between screen sections
  /// Mobile: 40px (baseline) | Tablet: 48px | Desktop: 56px
  xxl(SpacingTokens.s40, SpacingTokens.s48, 56),

  /// Triple extra large spacing — major content blocks
  /// Mobile: 48px (baseline) | Tablet: 56px | Desktop: 64px
  xxxl(SpacingTokens.s48, 56, SpacingTokens.s64),

  /// Huge spacing — between full-screen sections
  /// Mobile: 64px (baseline) | Tablet: 72px | Desktop: 80px
  huge(SpacingTokens.s64, 72, SpacingTokens.s80),

  /// Giant spacing — hero sections and major landmarks
  /// Mobile: 80px (baseline) | Tablet: 96px | Desktop: 112px
  giant(SpacingTokens.s80, 96, 112);

  final double mobile; // Baseline value (primary)
  final double tablet; // Medium value (scaled)
  final double desktop; // Larger value (further scaled)

  const AppSpacing(this.mobile, this.tablet, this.desktop);

  /// Returns the spacing value based on the current screen type
  double get(BuildContext context) {
    return resolve(ScreenEngine.screenType(context));
  }

  /// Resolves spacing value for a specific screen type
  double resolve(ScreenType type) => switch (type) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet,
    ScreenType.desktop => desktop,
  };

  /// Returns scaled spacing value multiplied by the given factor
  double getScaled(BuildContext context, {required double factor}) =>
      get(context) * factor;
      
  /// Creates an AppSpacingValue with overridden values
  AppSpacingValue overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppSpacingValue(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Human-readable description of the spacing intent
  String get description => switch (this) {
    AppSpacing.none => 'no spacing',
    AppSpacing.xs => 'extra small',
    AppSpacing.sm => 'small',
    AppSpacing.smMd => 'small-medium',
    AppSpacing.md => 'medium (default)',
    AppSpacing.mdLg => 'medium-large',
    AppSpacing.lg => 'large',
    AppSpacing.xl => 'extra large',
    AppSpacing.xxl => 'double extra large',
    AppSpacing.xxxl => 'triple extra large',
    AppSpacing.huge => 'huge',
    AppSpacing.giant => 'giant',
  };
}

// ═══════════════════════════════════════════════════════════════════
// RADIUS
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Intent-based radius tokens with RTL/Directional support
///
/// Mobile values serve as the baseline (primary) reference
enum AppRadius {
  /// No radius — sharp corners on all devices
  /// Mobile: 0px (baseline) | Tablet: 0px | Desktop: 0px
  none(RadiusTokens.r0, RadiusTokens.r0, RadiusTokens.r0),

  /// Extra small radius — subtle rounding for badges and small elements
  /// Mobile: 4px (baseline) | Tablet: 6px | Desktop: 8px
  xs(RadiusTokens.r4, 6, RadiusTokens.r8),

  /// Small radius — standard for buttons and input fields
  /// Mobile: 8px (baseline) | Tablet: 10px | Desktop: 12px
  sm(RadiusTokens.r8, 10, RadiusTokens.r12),

  /// Medium radius — default for cards and containers
  /// Mobile: 12px (baseline) | Tablet: 14px | Desktop: 16px
  md(RadiusTokens.r12, 14, RadiusTokens.r16),

  /// Large radius — prominent cards and modals
  /// Mobile: 16px (baseline) | Tablet: 20px | Desktop: 24px
  lg(RadiusTokens.r16, RadiusTokens.r20, RadiusTokens.r24),

  /// Extra large radius — hero images and feature cards
  /// Mobile: 24px (baseline) | Tablet: 28px | Desktop: 32px
  xl(RadiusTokens.r24, 28, RadiusTokens.r32),

  /// Double extra large radius — large containers and dialogs
  /// Mobile: 32px (baseline) | Tablet: 40px | Desktop: 48px
  xxl(RadiusTokens.r32, RadiusTokens.r40, RadiusTokens.r48),

  /// Full circular radius (pill shape) — completely rounded, same on all devices
  /// Mobile: 999px (baseline) | Tablet: 999px | Desktop: 999px
  full(RadiusTokens.r999, RadiusTokens.r999, RadiusTokens.r999);

  final double mobile; // Baseline value (primary)
  final double tablet; // Medium value (scaled)
  final double desktop; // Larger value (further scaled)

  const AppRadius(this.mobile, this.tablet, this.desktop);

  /// Returns the radius value based on the current screen type
  double get(BuildContext context) => resolve(ScreenEngine.screenType(context));

  /// Resolves radius value for a specific screen type
  double resolve(ScreenType type) => switch (type) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet,
    ScreenType.desktop => desktop,
  };

  /// Creates an AppRadiusValue with overridden values
  AppRadiusValue overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppRadiusValue(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a BorderRadius with the resolved value on all corners
  BorderRadius circular(BuildContext context) =>
      BorderRadius.circular(get(context));

  /// Creates a directional BorderRadius with the resolved value on all corners
  BorderRadiusDirectional circularDirectional(BuildContext context) =>
      BorderRadiusDirectional.circular(get(context));

  /// Creates a BorderRadius with the resolved value on specified corners only
  BorderRadius only({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
    required BuildContext context,
  }) {
    final value = get(context);
    return BorderRadius.only(
      topLeft: topLeft ? Radius.circular(value) : Radius.zero,
      topRight: topRight ? Radius.circular(value) : Radius.zero,
      bottomLeft: bottomLeft ? Radius.circular(value) : Radius.zero,
      bottomRight: bottomRight ? Radius.circular(value) : Radius.zero,
    );
  }

  /// Creates a directional BorderRadius with the resolved value on specified corners only
  BorderRadiusDirectional onlyDirectional({
    bool topStart = false,
    bool topEnd = false,
    bool bottomStart = false,
    bool bottomEnd = false,
    required BuildContext context,
  }) {
    final value = get(context);
    return BorderRadiusDirectional.only(
      topStart: topStart ? Radius.circular(value) : Radius.zero,
      topEnd: topEnd ? Radius.circular(value) : Radius.zero,
      bottomStart: bottomStart ? Radius.circular(value) : Radius.zero,
      bottomEnd: bottomEnd ? Radius.circular(value) : Radius.zero,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FONT SIZE
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Intent-based font size tokens
///
/// Mobile values serve as the baseline (primary) reference
enum AppFontSize {
  /// Tiny text — badges, micro labels, timestamp counters
  /// Mobile: 8px (baseline) | Tablet: 10px | Desktop: 12px
  tiny(8, 10, 12),

  /// Extra small text — captions, metadata, helper text
  /// Mobile: 10px (baseline) | Tablet: 12px | Desktop: 14px
  xs(FontTokens.f10, FontTokens.f12, FontTokens.f14),

  /// Small text — secondary text, small labels, hints
  /// Mobile: 12px (baseline) | Tablet: 13px | Desktop: 14px
  sm(FontTokens.f12, 13, FontTokens.f14),

  /// Base text — body text, paragraphs, standard content
  /// Mobile: 14px (baseline) | Tablet: 15px | Desktop: 16px
  base(FontTokens.f14, 15, FontTokens.f16),

  /// Medium text — subtitles, list titles, emphasized content
  /// Mobile: 16px (baseline) | Tablet: 17px | Desktop: 18px
  md(FontTokens.f16, 17, FontTokens.f18),

  /// Large text — section titles, card headers
  /// Mobile: 18px (baseline) | Tablet: 20px | Desktop: 22px
  lg(FontTokens.f18, FontTokens.f20, 22),

  /// Extra large text — card titles, prominent headings
  /// Mobile: 20px (baseline) | Tablet: 22px | Desktop: 24px
  xl(FontTokens.f20, 22, FontTokens.f24),

  /// Double extra large — screen titles, page headers
  /// Mobile: 24px (baseline) | Tablet: 26px | Desktop: 28px
  xxl(FontTokens.f24, 26, 28),

  /// Triple extra large — section headers, major headings
  /// Mobile: 28px (baseline) | Tablet: 30px | Desktop: 32px
  xxxl(FontTokens.f28, 30, FontTokens.f32),

  /// Hero text — main headlines, welcome messages
  /// Mobile: 32px (baseline) | Tablet: 36px | Desktop: 40px
  hero(FontTokens.f32, FontTokens.f36, FontTokens.f40),

  /// Display text — marketing content, landing page headlines
  /// Mobile: 40px (baseline) | Tablet: 44px | Desktop: 48px
  display(FontTokens.f40, 44, FontTokens.f48);

  final double mobile; // Baseline value (primary)
  final double tablet; // Medium value (scaled)
  final double desktop; // Larger value (further scaled)

  const AppFontSize(this.mobile, this.tablet, this.desktop);

  /// Returns the font size based on the current screen type
  double get(BuildContext context) => resolve(ScreenEngine.screenType(context));

  /// Resolves font size for a specific screen type
  double resolve(ScreenType type) => switch (type) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet,
    ScreenType.desktop => desktop,
  };

  /// Creates an AppFontSizeValue with overridden values
  AppFontSizeValue overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppFontSizeValue(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a TextStyle with the resolved font size and optional styling
  TextStyle style({
    required BuildContext context,
    FontWeight? weight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: get(context),
      fontWeight: weight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ICON SIZE
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Intent-based icon size tokens
///
/// Mobile values serve as the baseline (primary) reference
enum AppIconSize {
  /// Small icons — inline with text, within buttons
  /// Mobile: 16px (baseline) | Tablet: 18px | Desktop: 20px
  sm(IconTokens.i16, 18, IconTokens.i20),

  /// Medium icons — standard for buttons and list items
  /// Mobile: 20px (baseline) | Tablet: 22px | Desktop: 24px
  md(IconTokens.i20, 22, IconTokens.i24),

  /// Large icons — navigation items, feature icons
  /// Mobile: 24px (baseline) | Tablet: 28px | Desktop: 32px
  lg(IconTokens.i24, 28, IconTokens.i32),

  /// Extra large icons — empty states, illustrations
  /// Mobile: 32px (baseline) | Tablet: 36px | Desktop: 40px
  xl(IconTokens.i32, 36, IconTokens.i40),

  /// Double extra large — hero icons, feature highlights
  /// Mobile: 40px (baseline) | Tablet: 44px | Desktop: 48px
  xxl(IconTokens.i40, 44, IconTokens.i48),

  /// Huge icons — major feature sections, onboarding
  /// Mobile: 48px (baseline) | Tablet: 52px | Desktop: 56px
  huge(IconTokens.i48, 52, 56);

  final double mobile; // Baseline value (primary)
  final double tablet; // Medium value (scaled)
  final double desktop; // Larger value (further scaled)

  const AppIconSize(this.mobile, this.tablet, this.desktop);

  /// Returns the icon size based on the current screen type
  double get(BuildContext context) => resolve(ScreenEngine.screenType(context));

  /// Resolves icon size for a specific screen type
  double resolve(ScreenType type) => switch (type) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet,
    ScreenType.desktop => desktop,
  };

  /// Creates an AppIconSizeValue with overridden values
  AppIconSizeValue overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppIconSizeValue(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ELEVATION
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Intent-based elevation tokens with responsive support
///
/// Mobile values serve as the baseline (subtle shadows for touch interfaces)
/// Tablet values are medium (more screen real estate)
/// Desktop values are larger (mouse interactions benefit from more depth)
enum AppElevation {
  /// No elevation — completely flat surfaces
  /// Mobile: 0px (baseline) | Tablet: 0px | Desktop: 0px
  none(ElevationTokens.e0, ElevationTokens.e0, ElevationTokens.e0),

  /// Extra small — hover states, subtle lifts
  /// Mobile: 1px (baseline) | Tablet: 2px | Desktop: 2px
  xs(ElevationTokens.e1, 2, 2),

  /// Small — cards on cards, nested elements
  /// Mobile: 2px (baseline) | Tablet: 3px | Desktop: 4px
  sm(ElevationTokens.e2, 3, 4),

  /// Medium — default cards, standard surfaces
  /// Mobile: 4px (baseline) | Tablet: 6px | Desktop: 8px
  md(ElevationTokens.e4, 6, 8),

  /// Large — dialogs, modals, popups
  /// Mobile: 8px (baseline) | Tablet: 12px | Desktop: 16px
  lg(ElevationTokens.e8, 12, 16),

  /// Extra large — navigation bars, headers, drawers
  /// Mobile: 12px (baseline) | Tablet: 16px | Desktop: 20px
  xl(ElevationTokens.e12, 16, 20),

  /// Double extra large — floating action buttons, overlays
  /// Mobile: 16px (baseline) | Tablet: 20px | Desktop: 24px
  xxl(ElevationTokens.e16, 20, 24);

  final double mobile; // Baseline value (primary)
  final double tablet; // Medium value (scaled)
  final double desktop; // Larger value (further scaled)

  const AppElevation(this.mobile, this.tablet, this.desktop);

  /// Returns the elevation value based on the current screen type
  double get(BuildContext context) => resolve(ScreenEngine.screenType(context));

  /// Resolves elevation value for a specific screen type
  double resolve(ScreenType type) => switch (type) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet,
    ScreenType.desktop => desktop,
  };

  /// Creates an AppElevationValue with overridden values
  AppElevationValue overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppElevationValue(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a list of BoxShadow based on the resolved elevation
  List<BoxShadow> shadows(BuildContext context) {
    final value = get(context);
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

// ═══════════════════════════════════════════════════════════════════
// COMPONENT SIZE (WIDTH & HEIGHT)
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Intent-based component size tokens
///
/// Use for consistent component dimensions (buttons, inputs, cards, avatars).
/// Mobile values serve as the baseline (primary).
/// `full` returns double.infinity — use only when the parent has bounded constraints.
enum AppComponentSize {
  /// No size — zero dimension
  /// Mobile: 0px (baseline) | Tablet: 0px | Desktop: 0px
  none(0, 0, 0),

  /// Tiny touch target — icon buttons, small interactive elements
  /// Mobile: 32px (baseline) | Tablet: 36px | Desktop: 40px
  tiny(SizeTokens.s32, 36, SizeTokens.s40),

  /// Small component — small buttons, chips, badges
  /// Mobile: 36px (baseline) | Tablet: 40px | Desktop: 44px
  small(SizeTokens.s36, SizeTokens.s40, 44),

  /// Medium component — default buttons, input fields
  /// Mobile: 40px (baseline) | Tablet: 44px | Desktop: 48px
  medium(SizeTokens.s40, 44, SizeTokens.s48),

  /// Large component — primary CTAs, large inputs
  /// Mobile: 48px (baseline) | Tablet: 52px | Desktop: 56px
  large(SizeTokens.s48, 52, 56),

  /// Extra large component — hero buttons, prominent actions
  /// Mobile: 56px (baseline) | Tablet: 60px | Desktop: 64px
  xLarge(SizeTokens.s56, 60, SizeTokens.s64),

  /// Card width — portrait-style cards, product cards
  /// Mobile: 280px (baseline) | Tablet: 320px | Desktop: 360px
  cardWidth(SizeTokens.s280, SizeTokens.s320, SizeTokens.s360),

  /// Card height — image cards, media cards
  /// Mobile: 200px (baseline) | Tablet: 240px | Desktop: 280px
  cardHeight(200, 240, 280),

  /// Avatar size — user avatars, profile images
  /// Mobile: 40px (baseline) | Tablet: 48px | Desktop: 56px
  avatar(SizeTokens.s40, SizeTokens.s48, 56),

  /// Small avatar — list avatars, comment avatars
  /// Mobile: 32px (baseline) | Tablet: 36px | Desktop: 40px
  avatarSmall(SizeTokens.s32, 36, SizeTokens.s40),

  /// Large avatar — profile headers, account screens
  /// Mobile: 64px (baseline) | Tablet: 72px | Desktop: 80px
  avatarLarge(SizeTokens.s64, 72, SizeTokens.s80),

  /// Hit area — minimum touch target (accessibility)
  /// Mobile: 44px (baseline) | Tablet: 48px | Desktop: 52px
  hitArea(44, 48, 52),

  /// Fills available space — returns double.infinity
  /// ⚠️ Only use when parent has bounded constraints
  /// Mobile: infinity | Tablet: infinity | Desktop: infinity
  full(double.infinity, double.infinity, double.infinity);

  final double mobile; // Baseline value (primary)
  final double tablet; // Medium value (scaled)
  final double desktop; // Larger value (further scaled)

  const AppComponentSize(this.mobile, this.tablet, this.desktop);

  /// Returns the component size based on the current screen type
  double get(BuildContext context) => resolve(ScreenEngine.screenType(context));

  /// Resolves component size for a specific screen type
  double resolve(ScreenType type) => switch (type) {
    ScreenType.mobile => mobile,
    ScreenType.tablet => tablet,
    ScreenType.desktop => desktop,
  };

  /// Creates an AppComponentSizeValue with overridden values
  AppComponentSizeValue overrideWith({
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return AppComponentSizeValue(
      mobile ?? this.mobile,
      tablet ?? this.tablet,
      desktop ?? this.desktop,
    );
  }

  /// Creates a SizedBox with the resolved dimension
  SizedBox sizedBox({required BuildContext context, bool isWidth = false}) {
    final value = get(context);
    return isWidth ? SizedBox(width: value) : SizedBox(height: value);
  }

  /// Creates BoxConstraints with the resolved minimum dimension
  BoxConstraints getConstraints(BuildContext context, {bool isWidth = true}) {
    final value = get(context);
    return isWidth
        ? BoxConstraints(minWidth: value)
        : BoxConstraints(minHeight: value);
  }
}

// ... rest of the file (AppBaseWidth, ScreenType, AppOrientation remains unchanged)
// ═══════════════════════════════════════════════════════════════════
// BASE WIDTH (For Figma Frame Reference)
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Base width reference values for design frames
///
/// These represent common screen widths used as design references in Figma
enum AppBaseWidth {
  /// 320px — Small / legacy phones (iPhone SE, older Android)
  small(320),

  /// 375px — Standard design base, automatically default for mobile (iPhone X-15)
  phone(375),

  /// 390px — iPhone 14 Pro / 15 / 15 Pro
  phonePro(390),

  /// 430px — iPhone Plus / Pro Max models
  phoneLarge(430),

  /// 600px — Large phone landscape orientation
  phoneWide(600),

  /// 768px — iPad portrait, automatically default for tablet
  tablet(768),

  /// 1024px — iPad landscape
  tabletLarge(1024),

  /// 1280px — Standard desktop Figma frame, automatically default for desktop
  desktop(1280),

  /// 1440px — Wide desktop screens
  desktopWide(1440);

  const AppBaseWidth(this.value);
  final double value;
}

// ═══════════════════════════════════════════════════════════════════
// SCREEN TYPE & ORIENTATION
// ═══════════════════════════════════════════════════════════════════

/// 🎯 Screen type classification based on device width
enum ScreenType {
  /// Mobile devices (phones) — width < 768px
  mobile,

  /// Tablet devices — width >= 768px and < 1280px
  tablet,

  /// Desktop devices — width >= 1280px
  desktop,
}

/// 🎯 Screen orientation states
enum AppOrientation {
  /// Portrait mode (height > width)
  portrait,

  /// Landscape mode (width > height)
  landscape,
}
*/