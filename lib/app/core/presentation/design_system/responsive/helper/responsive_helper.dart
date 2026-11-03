/// Export app enums from tokens file
export '../engine/app_enums.dart';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_gap.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/scale_engine.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';

part 'responsive_helper/responsive_context_extension.dart';

/// Shortcut typedef for quick usage of ResponsiveHelper
typedef Rh = ResponsiveHelper;

/// Abstract class providing responsive design utilities
///
/// Handles responsive sizing, spacing, typography, and layout calculations
/// with support for different modes (fixed, scale-only, adaptive, adaptive-scale)
abstract final class ResponsiveHelper {
  // ══════════════════════════════════════════════════════════════
  // Helper for orientation-aware values
  // ══════════════════════════════════════════════════════════════

  /// Selects value based on current screen type and orientation
  ///
  /// Returns the most specific match:
  /// 1. Desktop → desktop value
  /// 2. Tablet landscape → tabletLandscape (if provided)
  /// 3. Mobile landscape → mobileLandscape (if provided)
  /// 4. Falls back to screen type values
  static T _adaptiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? mobileLandscape,
    required T tablet,
    T? tabletLandscape,
    required T desktop,
  }) {
    final screenType = ScreenEngine.screenType(context);
    final orientation = ScreenEngine.orientation(context);

    if (screenType == ScreenType.desktop) {
      return desktop;
    }

    if (screenType == ScreenType.tablet &&
        orientation == AppOrientation.landscape &&
        tabletLandscape != null) {
      return tabletLandscape;
    }

    if (screenType == ScreenType.mobile &&
        orientation == AppOrientation.landscape &&
        mobileLandscape != null) {
      return mobileLandscape;
    }

    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Helper to resolve value based on mode
  // ══════════════════════════════════════════════════════════════

  /// Resolves a responsive value based on the selected mode
  ///
  /// - [fixed]: Returns mobileValue unchanged
  /// - [scaleOnly]: Scales mobileValue by screen width ratio
  /// - [adaptiveOnly]: Returns value specific to screen type
  /// - [adaptiveScale]: Gets screen-type value then applies scaling
  ///
  /// [min] and [max] are tokens, not numbers: each mode reads them the same
  /// way it reads [size] (mobile value for [scaleOnly], the current screen
  /// type's value for [adaptiveScale]), so the limits never clip the token
  /// they belong to (e.g. giant = 112 on desktop must not be capped at 80).
  static double _resolveValue({
    required BuildContext context,
    required ResponsiveToken size,
    required ResponsiveToken min,
    required ResponsiveToken max,
    required ResponsiveMode mode,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: size.mobile,
          minValue: min.mobile,
          maxValue: max.mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.adaptiveScale(
          context,
          size: size,
          min: min,
          max: max,
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // FONT SIZE METHODS
  // ══════════════════════════════════════════════════════════════

  /// Returns responsive font size based on mode
  ///
  /// Handles text scaler preferences for accessibility
  ///
  /// Parameters:
  /// - [size]: Font size token to use
  /// - [min]: Minimum font size limit (optional)
  /// - [max]: Maximum font size limit (optional)
  /// - [respectTextScaler]: Whether to respect device text scale factor
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// fontSize: Rh.font(context, AppFontSize.lg)
  /// ```
  static double font(
    BuildContext context,
    AppFontSize size, {
    AppFontSize? min,
    AppFontSize? max,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return size.mobile;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scaleFont(
          context,
          designValue: size.mobile,
          minValue: (min ?? AppFontSize.tiny).mobile,
          maxValue: (max ?? AppFontSize.display).mobile,
          respectTextScaler: respectTextScaler,
        );

      case ResponsiveMode.adaptiveOnly:
        return size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        final scaled = ScaleEngine.adaptiveScale(
          context,
          size: size,
          min: min ?? AppFontSize.tiny,
          max: max ?? AppFontSize.display,
        );
        return ScaleEngine.applyTextScaler(
          context,
          scaled,
          respectTextScaler: respectTextScaler,
        );
    }
  }

  /// Creates a complete [TextStyle] with responsive font size
  ///
  /// Combines font size with typography properties
  ///
  /// Parameters:
  /// - [size]: Font size token
  /// - [weight]: Font weight (optional)
  /// - [color]: Text color (optional)
  /// - [height]: Line height multiplier (defaults to 1.4)
  /// - [letterSpacing]: Letter spacing (optional)
  /// - [min]: Minimum font size (optional)
  /// - [max]: Maximum font size (optional)
  /// - [respectTextScaler]: Whether to respect text scale (default: true)
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// Text('Hello',
  ///   style: Rh.textStyle(context, AppFontSize.lg, weight: FontWeight.bold)
  /// )
  /// ```
  static TextStyle textStyle(
    BuildContext context,
    AppFontSize size, {
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
    AppFontSize? min,
    AppFontSize? max,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    return TextStyle(
      fontSize: font(
        context,
        size,
        min: min,
        max: max,
        respectTextScaler: respectTextScaler,
        mode: mode,
      ),
      fontWeight: weight,
      color: color,
      height: height ?? 1.4,
      // Any non-zero letter spacing breaks Arabic letter joining, and ThemeData
      // merges M3's default spacing into null values, so default to 0 explicitly.
      letterSpacing: letterSpacing ?? 0,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SPACING METHODS
  // ══════════════════════════════════════════════════════════════

  /// Returns responsive spacing value based on mode
  ///
  /// Used for padding, margin, gaps, and other spacing calculations
  ///
  /// Parameters:
  /// - [size]: Spacing token to use
  /// - [min]: Minimum spacing limit (optional)
  /// - [max]: Maximum spacing limit (optional)
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.all(Rh.spacing(context, AppSpacing.md))
  /// ```
  static double spacing(
    BuildContext context,
    AppSpacing size, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    return _resolveValue(
      context: context,
      size: size,
      min: min ?? AppSpacing.none,
      max: max ?? AppSpacing.giant,
      mode: mode,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SIZE (WIDTH & HEIGHT) METHODS
  // ══════════════════════════════════════════════════════════════

  /// Internal method to resolve responsive sizes
  ///
  /// Used by width() and height() methods
  static double size_(
    BuildContext context,
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    return _resolveValue(
      context: context,
      size: size,
      min: min ?? AppComponentSize.none,
      max: max ?? AppComponentSize.full,
      mode: mode,
    );
  }

  /// Returns responsive width value
  ///
  /// Alias for size_() with clearer naming
  ///
  /// Example:
  /// ```dart
  /// width: Rh.width(context, AppComponentSize.cardWidth)
  /// ```
  static double width(
    BuildContext context,
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => size_(context, size, min: min, max: max, mode: mode);

  /// Returns responsive height value
  ///
  /// Alias for size_() with clearer naming
  ///
  /// Example:
  /// ```dart
  /// height: Rh.height(context, AppComponentSize.medium)
  /// ```
  static double height(
    BuildContext context,
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => size_(context, size, min: min, max: max, mode: mode);

  /// Shared by [padding] and [paddingDirectional]: resolves the four sides
  /// (individual side > horizontal/vertical group > [all]) and returns their
  /// responsive values as `[leading, trailing, top, bottom]`. Min/max default
  /// to the smallest/largest resolved side.
  static List<double> _paddingSides(
    BuildContext context, {
    required AppSpacing? all,
    required AppSpacing? horizontal,
    required AppSpacing? vertical,
    required AppSpacing? leading,
    required AppSpacing? trailing,
    required AppSpacing? top,
    required AppSpacing? bottom,
    required AppSpacing? min,
    required AppSpacing? max,
    required ResponsiveMode mode,
  }) {
    // null means "not set" — AppSpacing.none is a real value, so
    // padding(all: md, left: none) really gives left = 0.
    AppSpacing pick(AppSpacing? side, AppSpacing? group) =>
        side ?? group ?? all ?? AppSpacing.none;

    final sides = [
      pick(leading, horizontal),
      pick(trailing, horizontal),
      pick(top, vertical),
      pick(bottom, vertical),
    ];
    final effectiveMin =
        min ?? sides.reduce((a, b) => a.mobile < b.mobile ? a : b);
    final effectiveMax =
        max ?? sides.reduce((a, b) => a.mobile > b.mobile ? a : b);

    return [
      for (final side in sides)
        spacing(
          context,
          side,
          min: effectiveMin,
          max: effectiveMax,
          mode: mode,
        ),
    ];
  }

  // ══════════════════════════════════════════════════════════════
  // PADDING METHODS (Absolute — left/right for LTR)
  // ══════════════════════════════════════════════════════════════

  /// Creates responsive [EdgeInsets] padding with flexible configuration
  ///
  /// Supports all(), horizontal/vertical, and individual sides
  /// Priority: specific (left/right/top/bottom) > grouped (h/v) > all
  ///
  /// Parameters:
  /// - [all]: Applied to all sides (overridden by more specific values)
  /// - [horizontal]: Applied to left and right
  /// - [vertical]: Applied to top and bottom
  /// - [left], [right], [top], [bottom]: Individual sides
  /// - [min], [max]: Spacing limits (auto-detected if not provided)
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// Padding(
  ///   padding: Rh.padding(
  ///     context: context,
  ///     all: AppSpacing.md,
  ///   ),
  ///   child: child,
  /// )
  /// ```
  static EdgeInsets padding(
    BuildContext context, {
    AppSpacing? all,
    AppSpacing? horizontal,
    AppSpacing? vertical,
    AppSpacing? left,
    AppSpacing? right,
    AppSpacing? top,
    AppSpacing? bottom,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    /// Resolve left value with priority: explicit > horizontal > all
    final [l, r, t, b] = _paddingSides(
      context,
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      leading: left,
      trailing: right,
      top: top,
      bottom: bottom,
      min: min,
      max: max,
      mode: mode,
    );
    return EdgeInsets.only(left: l, right: r, top: t, bottom: b);
  }

  /// Shortcut for padding all sides equally
  ///
  /// Example:
  /// ```dart
  /// Rh.allPadding(context, AppSpacing.md)
  /// ```
  static EdgeInsets allPadding(
    BuildContext context,
    AppSpacing value, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => padding(context, all: value, min: min, max: max, mode: mode);

  /// Shortcut for symmetric horizontal and vertical padding
  ///
  /// Example:
  /// ```dart
  /// Rh.symmetricPadding(
  ///   context,
  ///   horizontal: AppSpacing.lg,
  ///   vertical: AppSpacing.md,
  /// )
  /// ```
  static EdgeInsets symmetricPadding(
    BuildContext context, {
    AppSpacing horizontal = AppSpacing.none,
    AppSpacing vertical = AppSpacing.none,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => padding(
    context,
    horizontal: horizontal,
    vertical: vertical,
    min: min,
    max: max,
    mode: mode,
  );

  /// Shortcut for padding specific sides only
  ///
  /// Example:
  /// ```dart
  /// Rh.onlyPadding(
  ///   context,
  ///   left: AppSpacing.md,
  ///   top: AppSpacing.sm,
  /// )
  /// ```
  static EdgeInsets onlyPadding(
    BuildContext context, {
    AppSpacing left = AppSpacing.none,
    AppSpacing right = AppSpacing.none,
    AppSpacing top = AppSpacing.none,
    AppSpacing bottom = AppSpacing.none,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => padding(
    context,
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    min: min,
    max: max,
    mode: mode,
  );

  // ══════════════════════════════════════════════════════════════
  // PADDING DIRECTIONAL (start/end for RTL support)
  // ══════════════════════════════════════════════════════════════

  /// Creates responsive [EdgeInsetsDirectional] with RTL support
  ///
  /// Uses start/end instead of left/right for proper RTL handling
  /// Priority: specific (start/end/top/bottom) > grouped (h/v) > all
  ///
  /// Parameters:
  /// - [all]: Applied to all sides
  /// - [horizontal]: Applied to start and end
  /// - [vertical]: Applied to top and bottom
  /// - [start], [end]: Directional horizontal sides (RTL-aware)
  /// - [top], [bottom]: Vertical sides
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// Padding(
  ///   padding: Rh.paddingDirectional(
  ///     context: context,
  ///     start: AppSpacing.md,
  ///     end: AppSpacing.md,
  ///   ),
  ///   child: child,
  /// )
  /// ```
  static EdgeInsetsDirectional paddingDirectional({
    required BuildContext context,
    AppSpacing? all,
    AppSpacing? horizontal,
    AppSpacing? vertical,
    AppSpacing? start,
    AppSpacing? end,
    AppSpacing? top,
    AppSpacing? bottom,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    /// Resolve start value with priority: explicit > horizontal > all
    final [st, en, t, b] = _paddingSides(
      context,
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      leading: start,
      trailing: end,
      top: top,
      bottom: bottom,
      min: min,
      max: max,
      mode: mode,
    );
    return EdgeInsetsDirectional.only(start: st, end: en, top: t, bottom: b);
  }

  /// Shared by [radius] and [radiusDirectional]: the responsive corner size
  /// for [size] in the given [mode].
  static double _radiusValue(
    BuildContext context,
    AppRadius size, {
    required AppRadius? min,
    required AppRadius? max,
    required ResponsiveMode mode,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return size.mobile;
      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: size.mobile,
          minValue: (min ?? AppRadius.none).mobile,
          maxValue: (max ?? AppRadius.full).mobile,
        );
      case ResponsiveMode.adaptiveOnly:
        return size.forType(screenType);
      case ResponsiveMode.adaptiveScale:
        return ScaleEngine.adaptiveScale(
          context,
          size: size,
          min: min ?? AppRadius.none,
          max: max ?? AppRadius.full,
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BORDER RADIUS METHODS
  // ══════════════════════════════════════════════════════════════

  /// Creates responsive [BorderRadius] with flexible corner control
  ///
  /// Allows selecting which corners to round
  ///
  /// Parameters:
  /// - [size]: Radius token to use
  /// - [min], [max]: Radius limits
  /// - [topLeft], [topRight], [bottomLeft], [bottomRight]: Corner selection
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: Rh.radius(context, AppRadius.md),
  ///   ),
  /// )
  /// ```
  static BorderRadius radius(
    BuildContext context,
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    bool topLeft = true,
    bool topRight = true,
    bool bottomLeft = true,
    bool bottomRight = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    final r = _radiusValue(context, size, min: min, max: max, mode: mode);
    final corner = Radius.circular(r);
    const sharp = Radius.zero;

    /// Optimize for all corners rounded case
    if (topLeft && topRight && bottomLeft && bottomRight) {
      return BorderRadius.circular(r);
    }

    return BorderRadius.only(
      topLeft: topLeft ? corner : sharp,
      topRight: topRight ? corner : sharp,
      bottomLeft: bottomLeft ? corner : sharp,
      bottomRight: bottomRight ? corner : sharp,
    );
  }

  /// Shortcut for circular radius (all corners rounded)
  ///
  /// Example:
  /// ```dart
  /// Rh.circularRadius(context, AppRadius.md)
  /// ```
  static BorderRadius circularRadius(
    BuildContext context,
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => radius(context, size, min: min, max: max, mode: mode);

  /// Shortcut for top corners only (BottomSheet style)
  ///
  /// Example:
  /// ```dart
  /// Rh.topRadius(context, AppRadius.lg)
  /// ```
  static BorderRadius topRadius(
    BuildContext context,
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => radius(
    context,
    size,
    min: min,
    max: max,
    topLeft: true,
    topRight: true,
    bottomLeft: false,
    bottomRight: false,
    mode: mode,
  );

  /// Shortcut for bottom corners only
  ///
  /// Example:
  /// ```dart
  /// Rh.bottomRadius(context, AppRadius.md)
  /// ```
  static BorderRadius bottomRadius(
    BuildContext context,
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => radius(
    context,
    size,
    min: min,
    max: max,
    topLeft: false,
    topRight: false,
    bottomLeft: true,
    bottomRight: true,
    mode: mode,
  );

  // ══════════════════════════════════════════════════════════════
  // BORDER RADIUS DIRECTIONAL (start/end for RTL)
  // ══════════════════════════════════════════════════════════════

  /// Creates responsive [BorderRadiusDirectional] with RTL support
  ///
  /// Uses start/end instead of left/right for proper RTL handling
  ///
  /// Parameters:
  /// - [size]: Radius token to use
  /// - [topStart], [topEnd], [bottomStart], [bottomEnd]: Corner selection
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: Rh.radiusDirectional(context, AppRadius.md),
  ///   ),
  /// )
  /// ```
  static BorderRadiusDirectional radiusDirectional(
    BuildContext context,
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    bool topStart = true,
    bool topEnd = true,
    bool bottomStart = true,
    bool bottomEnd = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    final r = _radiusValue(context, size, min: min, max: max, mode: mode);
    final corner = Radius.circular(r);
    const sharp = Radius.zero;

    /// Optimize for all corners rounded case
    if (topStart && topEnd && bottomStart && bottomEnd) {
      return BorderRadiusDirectional.circular(r);
    }

    return BorderRadiusDirectional.only(
      topStart: topStart ? corner : sharp,
      topEnd: topEnd ? corner : sharp,
      bottomStart: bottomStart ? corner : sharp,
      bottomEnd: bottomEnd ? corner : sharp,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ICON SIZE METHODS
  // ══════════════════════════════════════════════════════════════

  /// Returns responsive icon size based on mode
  ///
  /// Example:
  /// ```dart
  /// Icon(Icons.star, size: Rh.iconSize(context, AppIconSize.md))
  /// ```
  static double iconSize(
    BuildContext context,
    AppIconSize size, {
    AppIconSize? min,
    AppIconSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    return _resolveValue(
      context: context,
      size: size,
      min: min ?? AppIconSize.sm,
      max: max ?? AppIconSize.huge,
      mode: mode,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ELEVATION METHODS
  // ══════════════════════════════════════════════════════════════

  /// Returns responsive elevation value
  ///
  /// Elevation typically uses adaptiveOnly mode (no scaling)
  ///
  /// Example:
  /// ```dart
  /// elevation: Rh.elevation(context, AppElevation.md)
  /// ```
  static double elevation(
    BuildContext context,
    AppElevation size, {
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    final screenType = ScreenEngine.screenType(context);
    switch (mode) {
      case ResponsiveMode.fixed:
        return size.mobile;
      case ResponsiveMode.scaleOnly:
      case ResponsiveMode.adaptiveOnly:
      case ResponsiveMode.adaptiveScale:
        return size.forType(screenType);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GAP METHODS (requires app_gap package)
  // ══════════════════════════════════════════════════════════════

  /// Returns a responsive [Gap] widget for spacing
  ///
  /// Gap is more efficient than SizedBox for spacing in Flex layouts
  ///
  /// Parameters:
  /// - [size]: Spacing token
  /// - [axis]: Layout direction (vertical by default)
  ///
  /// Example:
  /// ```dart
  /// Column(
  ///   children: [
  ///     Widget1(),
  ///     Rh.gapSpace(context, AppSpacing.md),
  ///     Widget2(),
  ///   ],
  /// )
  /// ```
  static Gap gapSpace(
    BuildContext context,
    AppSpacing size, {
    Axis? axis,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Gap(
    spacing(context, size, min: min, max: max, mode: mode),
    axis: axis,
  );

  // ══════════════════════════════════════════════════════════════
  // WIDGET SELECTION (Responsive widget alternatives)
  // ══════════════════════════════════════════════════════════════

  /// Builds the layout that matches the **device** (screen type and
  /// orientation); only the chosen builder runs, the others are never called.
  ///
  /// Decided by the whole screen ([ScreenEngine.screenType]), so use it for
  /// device-level choices such as the app shell. To decide by the width a
  /// widget really gets (inside a screen or a pane), use `AdaptiveLayout`.
  ///
  /// Parameters:
  /// - [mobile]: Builder for mobile (required, used as fallback)
  /// - [mobileLandscape]: Optional builder for mobile landscape
  /// - [tablet]: Optional builder for tablet (falls back to [mobile])
  /// - [tabletLandscape]: Optional builder for tablet landscape
  /// - [desktop]: Optional builder for desktop (falls back to [tablet])
  ///
  /// Example:
  /// ```dart
  /// Rh.builder(
  ///   context: context,
  ///   mobile: (_) => const MobileLayout(),
  ///   tablet: (_) => const TabletLayout(),
  ///   desktop: (_) => const DesktopLayout(),
  /// )
  /// ```
  static Widget builder({
    required BuildContext context,
    required WidgetBuilder mobile,
    WidgetBuilder? mobileLandscape,
    WidgetBuilder? tablet,
    WidgetBuilder? tabletLandscape,
    WidgetBuilder? desktop,
  }) => _adaptiveValue<WidgetBuilder>(
    context,
    mobile: mobile,
    mobileLandscape: mobileLandscape,
    tablet: tablet ?? mobile,
    tabletLandscape: tabletLandscape ?? tablet ?? mobile,
    desktop: desktop ?? tablet ?? mobile,
  )(context);

  /// Returns different values based on screen type and orientation
  ///
  /// Parameters:
  /// - [mobile]: Value for mobile (required, used as fallback)
  /// - [mobileLandscape]: Optional value for mobile landscape
  /// - [tablet]: Optional value for tablet
  /// - [tabletLandscape]: Optional value for tablet landscape
  /// - [desktop]: Optional value for desktop
  ///
  /// Example:
  /// ```dart
  /// final columns = Rh.value(context: context, mobile: 1, desktop: 3);
  /// ```
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? mobileLandscape,
    T? tablet,
    T? tabletLandscape,
    T? desktop,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    switch (mode) {
      case ResponsiveMode.fixed:
        return mobile;
      case ResponsiveMode.scaleOnly:
      case ResponsiveMode.adaptiveOnly:
      case ResponsiveMode.adaptiveScale:
        return _adaptiveValue<T>(
          context,
          mobile: mobile,
          mobileLandscape: mobileLandscape,
          tablet: tablet ?? mobile,
          tabletLandscape: tabletLandscape ?? tablet ?? mobile,
          desktop: desktop ?? tablet ?? mobile,
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GRID CROSS AXIS COUNT
  // ══════════════════════════════════════════════════════════════

  /// Returns responsive grid column count based on screen type
  ///
  /// Used for GridView and similar layout widgets
  ///
  /// Parameters:
  /// - [mobile]: Columns for mobile (default: 2)
  /// - [mobileLandscape]: Columns for mobile landscape (default: 3)
  /// - [tablet]: Columns for tablet (default: 3)
  /// - [tabletLandscape]: Columns for tablet landscape (default: 4)
  /// - [desktop]: Columns for desktop (default: 4)
  ///
  /// Example:
  /// ```dart
  /// GridView.builder(
  ///   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  ///     crossAxisCount: Rh.crossAxisCount(context),
  ///   ),
  ///   itemBuilder: (context, index) => GridTile(child: items[index]),
  /// )
  /// ```
  static int crossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int mobileLandscape = 3,
    int tablet = 3,
    int tabletLandscape = 4,
    int desktop = 4,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    switch (mode) {
      case ResponsiveMode.fixed:
        return mobile;
      case ResponsiveMode.scaleOnly:
      case ResponsiveMode.adaptiveOnly:
      case ResponsiveMode.adaptiveScale:
        return _adaptiveValue(
          context,
          mobile: mobile,
          mobileLandscape: mobileLandscape,
          tablet: tablet,
          tabletLandscape: tabletLandscape,
          desktop: desktop,
        );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // PAGE PADDING (Preset configurations)
  // ══════════════════════════════════════════════════════════════

  /// Returns ready-to-use page padding based on screen type
  ///
  /// Provides sensible defaults for page-level padding
  /// Can be customized per screen type
  ///
  /// Parameters:
  /// - [mobileH]/[mobileV]: Mobile horizontal/vertical padding
  /// - [tabletH]/[tabletV]: Tablet horizontal/vertical padding
  /// - [desktopH]/[desktopV]: Desktop horizontal/vertical padding
  /// - [mode]: Responsive calculation mode
  ///
  /// Example:
  /// ```dart
  /// Scaffold(
  ///   body: Padding(
  ///     padding: Rh.pagePadding(context),
  ///     child: content,
  ///   ),
  /// )
  /// ```
  static EdgeInsets pagePadding(
    BuildContext context, {
    AppSpacing mobileH = AppSpacing.md,
    AppSpacing mobileV = AppSpacing.sm,
    AppSpacing tabletH = AppSpacing.xl,
    AppSpacing tabletV = AppSpacing.md,
    AppSpacing desktopH = AppSpacing.huge,
    AppSpacing desktopV = AppSpacing.md,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return EdgeInsets.symmetric(
          horizontal: mobileH.mobile,
          vertical: mobileV.mobile,
        );

      case ResponsiveMode.scaleOnly:
        return EdgeInsets.symmetric(
          horizontal: ScaleEngine.scale(
            context,
            designValue: mobileH.mobile,
            minValue: mobileH.mobile,
            maxValue: desktopH.mobile,
          ),
          vertical: ScaleEngine.scale(
            context,
            designValue: mobileV.mobile,
            minValue: mobileV.mobile,
            maxValue: desktopV.mobile,
          ),
        );

      case ResponsiveMode.adaptiveOnly:
        return _adaptiveValue(
          context,
          mobile: EdgeInsets.symmetric(
            horizontal: mobileH.forType(screenType),
            vertical: mobileV.forType(screenType),
          ),
          mobileLandscape: EdgeInsets.symmetric(
            horizontal: mobileH.forType(screenType),
            vertical: mobileV.forType(screenType),
          ),
          tablet: EdgeInsets.symmetric(
            horizontal: tabletH.forType(screenType),
            vertical: tabletV.forType(screenType),
          ),
          tabletLandscape: EdgeInsets.symmetric(
            horizontal: tabletH.forType(screenType),
            vertical: tabletV.forType(screenType),
          ),
          desktop: EdgeInsets.symmetric(
            horizontal: desktopH.forType(screenType),
            vertical: desktopV.forType(screenType),
          ),
        );

      case ResponsiveMode.adaptiveScale:
        // Blend the per-screen page tokens continuously instead of
        // scaling a per-type value a second time.
        return EdgeInsets.symmetric(
          horizontal: ScaleEngine.interpolate(
            context,
            AppSpacing(mobileH.mobile, tabletH.tablet, desktopH.desktop),
          ),
          vertical: ScaleEngine.interpolate(
            context,
            AppSpacing(mobileV.mobile, tabletV.tablet, desktopV.desktop),
          ),
        );
    }
  }
}
