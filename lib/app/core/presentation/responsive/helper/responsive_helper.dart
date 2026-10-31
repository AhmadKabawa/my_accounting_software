/// Export app enums from tokens file
export '../engine/app_enums.dart';

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_gap.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/scale_engine.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';

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
  static double _resolveValue({
    required BuildContext context,
    required double mobileValue,
    required double Function(ScreenType) resolveAdaptive,
    double? minValue,
    double? maxValue,
    required ResponsiveMode mode,
  }) {
    final screenType = ScreenEngine.screenType(context);

    switch (mode) {
      case ResponsiveMode.fixed:
        return mobileValue;

      case ResponsiveMode.scaleOnly:
        return ScaleEngine.scale(
          context,
          designValue: mobileValue,
          minValue: minValue ?? mobileValue,
          maxValue: maxValue ?? mobileValue,
        );

      case ResponsiveMode.adaptiveOnly:
        return resolveAdaptive(screenType);

      case ResponsiveMode.adaptiveScale:
        final designValue = resolveAdaptive(screenType);
        final min = minValue != null ? minValue : resolveAdaptive(screenType);
        final max = maxValue != null ? maxValue : resolveAdaptive(screenType);
        return ScaleEngine.scale(
          context,
          designValue: designValue,
          minValue: min,
          maxValue: max,
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
          minValue: (min ?? AppFontSize.xs).mobile,
          maxValue: (max ?? AppFontSize.display).mobile,
        );

      case ResponsiveMode.adaptiveOnly:
        return size.forType(screenType);

      case ResponsiveMode.adaptiveScale:
        final designValue = size.forType(screenType);
        final minValue = (min ?? AppFontSize.xs).forType(screenType);
        final maxValue = (max ?? AppFontSize.display).forType(screenType);
        return ScaleEngine.scaleFont(
          context,
          designValue: designValue,
          minValue: minValue,
          maxValue: maxValue,
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
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) {
    return TextStyle(
      fontSize: font(
        context,
        size,
        min: min,
        max: max,
        mode: mode,
      ),
      fontWeight: weight,
      color: color,
      height: height ?? 1.4,
      letterSpacing: letterSpacing,
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
      mobileValue: size.mobile,
      resolveAdaptive: size.forType,
      minValue: (min ?? AppSpacing.none).mobile,
      maxValue: (max ?? AppSpacing.giant).mobile,
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
      mobileValue: size.mobile,
      resolveAdaptive: size.forType,
      minValue: (min ?? AppComponentSize.none).mobile,
      maxValue: (max ?? AppComponentSize.full).mobile,
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
  /// - [min], [max]: Optional spacing limits (spacing() defaults apply)
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
    // null = "not specified" (so AppSpacing.none can zero a single side).
    // Priority: explicit side > horizontal/vertical > all.
    final resolvedLeft = left ?? horizontal ?? all ?? AppSpacing.none;
    final resolvedRight = right ?? horizontal ?? all ?? AppSpacing.none;
    final resolvedTop = top ?? vertical ?? all ?? AppSpacing.none;
    final resolvedBottom = bottom ?? vertical ?? all ?? AppSpacing.none;

    return EdgeInsets.only(
      left: spacing(
        context,
        resolvedLeft,
        min: min,
        max: max,
        mode: mode,
      ),
      right: spacing(
        context,
        resolvedRight,
        min: min,
        max: max,
        mode: mode,
      ),
      top: spacing(
        context,
        resolvedTop,
        min: min,
        max: max,
        mode: mode,
      ),
      bottom: spacing(
        context,
        resolvedBottom,
        min: min,
        max: max,
        mode: mode,
      ),
    );
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
    AppSpacing? horizontal,
    AppSpacing? vertical,
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
    AppSpacing? left,
    AppSpacing? right,
    AppSpacing? top,
    AppSpacing? bottom,
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
    final resolvedStart = start ?? horizontal ?? all ?? AppSpacing.none;
    final resolvedEnd = end ?? horizontal ?? all ?? AppSpacing.none;
    final resolvedTop = top ?? vertical ?? all ?? AppSpacing.none;
    final resolvedBottom = bottom ?? vertical ?? all ?? AppSpacing.none;

    return EdgeInsetsDirectional.only(
      start: spacing(
        context,
        resolvedStart,
        min: min,
        max: max,
        mode: mode,
      ),
      end: spacing(
        context,
        resolvedEnd,
        min: min,
        max: max,
        mode: mode,
      ),
      top: spacing(
        context,
        resolvedTop,
        min: min,
        max: max,
        mode: mode,
      ),
      bottom: spacing(
        context,
        resolvedBottom,
        min: min,
        max: max,
        mode: mode,
      ),
    );
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
    final screenType = ScreenEngine.screenType(context);

    /// Handle full circular radius as special case
    if (size == AppRadius.full) {
      return BorderRadius.circular(double.infinity);
    }

    /// Helper function to resolve radius value based on mode
    double getValue() {
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
          final designValue = size.forType(screenType);
          final minValue = (min ?? AppRadius.none).forType(screenType);
          final maxValue = (max ?? AppRadius.full).forType(screenType);
          return ScaleEngine.scale(
            context,
            designValue: designValue,
            minValue: minValue,
            maxValue: maxValue,
          );
      }
    }

    final r = getValue();
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
    final screenType = ScreenEngine.screenType(context);

    /// Handle full circular radius as special case
    if (size == AppRadius.full) {
      return BorderRadiusDirectional.circular(double.infinity);
    }

    /// Helper function to resolve radius value based on mode
    double getValue() {
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
          final designValue = size.forType(screenType);
          final minValue = (min ?? AppRadius.none).forType(screenType);
          final maxValue = (max ?? AppRadius.full).forType(screenType);
          return ScaleEngine.scale(
            context,
            designValue: designValue,
            minValue: minValue,
            maxValue: maxValue,
          );
      }
    }

    final r = getValue();
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
      mobileValue: size.mobile,
      resolveAdaptive: size.forType,
      minValue: (min ?? AppIconSize.sm).mobile,
      maxValue: (max ?? AppIconSize.huge).mobile,
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
  static double elevation(BuildContext context, AppElevation size) {
    final screenType = ScreenEngine.screenType(context);
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly;
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
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Gap(
    spacing(context, size, min: min, max: max, mode: mode),
    axis: axis,
  );

  // ══════════════════════════════════════════════════════════════
  // WIDGET SELECTION (Responsive widget alternatives)
  // ══════════════════════════════════════════════════════════════

  /// Returns different widgets based on screen type and orientation
  ///
  /// Useful for returning completely different layouts per screen size
  ///
  /// Parameters:
  /// - [mobile]: Widget for mobile (required, used as fallback)
  /// - [mobileLandscape]: Optional widget for mobile landscape
  /// - [tablet]: Optional widget for tablet
  /// - [tabletLandscape]: Optional widget for tablet landscape
  /// - [desktop]: Optional widget for desktop
  ///
  /// Example:
  /// ```dart
  /// Rh.widget(
  ///   context: context,
  ///   mobile: MobileLayout(),
  ///   tablet: TabletLayout(),
  ///   desktop: DesktopLayout(),
  /// )
  /// ```
  static Widget widget({
    required BuildContext context,
    required Widget mobile,
    Widget? mobileLandscape,
    Widget? tablet,
    Widget? tabletLandscape,
    Widget? desktop,
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
          tablet: tablet ?? mobile,
          tabletLandscape: tabletLandscape ?? tablet ?? mobile,
          desktop: desktop ?? tablet ?? mobile,
        );
    }
  }

  /// Returns different values based on screen type and orientation
  ///
  /// Useful for returning completely different layouts per screen size
  ///
  /// Parameters:
  /// - [mobile]: Widget for mobile (required, used as fallback)
  /// - [mobileLandscape]: Optional widget for mobile landscape
  /// - [tablet]: Optional widget for tablet
  /// - [tabletLandscape]: Optional widget for tablet landscape
  /// - [desktop]: Optional widget for desktop
  ///
  /// Example:
  /// ```dart
  /// Rh.widget(
  ///   context: context,
  ///   mobile: MobileLayout(),
  ///   tablet: TabletLayout(),
  ///   desktop: DesktopLayout(),
  /// )
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
        return _adaptiveValue(
          context,
          mobile: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: mobileH.forType(screenType),
              minValue: mobileH.mobile,
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: mobileV.forType(screenType),
              minValue: mobileV.mobile,
              maxValue: desktopV.forType(screenType),
            ),
          ),
          mobileLandscape: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: mobileH.forType(screenType),
              minValue: mobileH.mobile,
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: mobileV.forType(screenType),
              minValue: mobileV.mobile,
              maxValue: desktopV.forType(screenType),
            ),
          ),
          tablet: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: tabletH.forType(screenType),
              minValue: mobileH.forType(screenType),
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: tabletV.forType(screenType),
              minValue: mobileV.forType(screenType),
              maxValue: desktopV.forType(screenType),
            ),
          ),
          tabletLandscape: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: tabletH.forType(screenType),
              minValue: mobileH.forType(screenType),
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: tabletV.forType(screenType),
              minValue: mobileV.forType(screenType),
              maxValue: desktopV.forType(screenType),
            ),
          ),
          desktop: EdgeInsets.symmetric(
            horizontal: ScaleEngine.scale(
              context,
              designValue: desktopH.forType(screenType),
              minValue: mobileH.forType(screenType),
              maxValue: desktopH.forType(screenType),
            ),
            vertical: ScaleEngine.scale(
              context,
              designValue: desktopV.forType(screenType),
              minValue: mobileV.forType(screenType),
              maxValue: desktopV.forType(screenType),
            ),
          ),
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// CONTEXT EXTENSIONS — Convenient shortcut methods
// ═══════════════════════════════════════════════════════════════════

/// Extends [BuildContext] with responsive helper shortcuts
///
/// Allows using `context.sp()` instead of `Rh.spacing(context, ...)`
extension ResponsiveContextExtension on BuildContext {
  /// Shortcut for [ResponsiveHelper.spacing]
  /// Usage: `context.sp(AppSpacing.md)`
  double spacing(
    AppSpacing size, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.spacing(this, size, min: min, max: max, mode: mode);

  /// Shortcut for [ResponsiveHelper.font]
  /// Usage: `context.fs(AppFontSize.lg)`
  double fontSize(
    AppFontSize size, {
    AppFontSize? min,
    AppFontSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.font(
    this,
    size,
    min: min,
    max: max,
    mode: mode,
  );

  /// Shortcut for [ResponsiveHelper.iconSize]
  /// Usage: `context.icon(AppIconSize.md)`
  double icon(
    AppIconSize size, {
    AppIconSize? min,
    AppIconSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.iconSize(this, size, min: min, max: max, mode: mode);

  /// Shortcut for [ResponsiveHelper.size_]
  /// Usage: `context.sz(AppComponentSize.medium)`
  double size(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.size_(this, size, min: min, max: max, mode: mode);

  /// Shortcut for [ResponsiveHelper.elevation]
  /// Usage: `context.el(AppElevation.md)`
  double elevation(
    AppElevation size, {
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => ResponsiveHelper.elevation(this, size);

  /// Shortcut for [ResponsiveHelper.padding]
  /// Usage: `context.pad(all: AppSpacing.md)`
  EdgeInsets pad({
    AppSpacing? all,
    AppSpacing? h,
    AppSpacing? v,
    AppSpacing? l,
    AppSpacing? r,
    AppSpacing? t,
    AppSpacing? b,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.padding(
    this,
    all: all,
    horizontal: h,
    vertical: v,
    left: l,
    right: r,
    top: t,
    bottom: b,
    min: min,
    max: max,
    mode: mode,
  );

  /// Shortcut for [ResponsiveHelper.circularRadius]
  /// Usage: `context.rad(AppRadius.md)`
  BorderRadius rad(
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.circularRadius(
    this,
    size,
    min: min,
    max: max,
    mode: mode,
  );

  /// Shortcut for [ResponsiveHelper.gapSpace]
  /// Usage: `context.gap(AppSpacing.md)`
  Widget gap(
    AppSpacing size, {
    Axis? axis,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.gapSpace(
    this,
    size,
    axis: axis,
    min: min,
    max: max,
    mode: mode,
  );
  double w(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.width(this, size, min: min, max: max, mode: mode);

  double h(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.height(this, size, min: min, max: max, mode: mode);
  TextStyle txt(
    AppFontSize size, {
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
    AppFontSize? min,
    AppFontSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.textStyle(
    this,
    size,
    weight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    min: min,
    max: max,
    mode: mode,
  );
  EdgeInsets padH(AppSpacing value) =>
      ResponsiveHelper.symmetricPadding(this, horizontal: value);

  EdgeInsets padV(AppSpacing value) =>
      ResponsiveHelper.symmetricPadding(this, vertical: value);

  EdgeInsets padAll(AppSpacing value) =>
      ResponsiveHelper.allPadding(this, value);
  BorderRadius radTop(AppRadius size) => ResponsiveHelper.topRadius(this, size);

  BorderRadius radBottom(AppRadius size) =>
      ResponsiveHelper.bottomRadius(this, size);
  Widget responsive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
    Widget? mobileLandscape,
    Widget? tabletLandscape,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => ResponsiveHelper.widget(
    context: this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    mobileLandscape: mobileLandscape,
    tabletLandscape: tabletLandscape,
    mode: mode,
  );
  int grid({int mobile = 2, int tablet = 3, int desktop = 4}) =>
      ResponsiveHelper.crossAxisCount(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
