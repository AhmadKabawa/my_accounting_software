// ═══════════════════════════════════════════════════════════════════
// UI Extensions System
// نظام شامل لتسهيل الوصول للقيم responsive والـ design tokens
// استخدام: context.ui.padding.all, context.ui.size.width, إلخ
// ═══════════════════════════════════════════════════════════════════
export '../engine/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_gap.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/screen_engine.dart';

// ═══════════════════════════════════════════════════════════════════
// MAIN EXTENSION على BuildContext
// ═══════════════════════════════════════════════════════════════════

extension UIContextExtension on BuildContext {
  /// الدخول الرئيسي لكل نظام UI
  /// استخدام: context.ui.padding.all(...), context.ui.spacing.md, إلخ
  UIHelper get ui => UIHelper(this);
}

// ═══════════════════════════════════════════════════════════════════
// UI HELPER - التجميعة الرئيسية
// ═══════════════════════════════════════════════════════════════════

class UIHelper {
  final BuildContext context;

  const UIHelper(this.context);

  /// نظام الـ Padding والـ Margin والـ Spacing
  PaddingHelper get padding => PaddingHelper(context);

  /// نظام الأحجام (width, height, sizes)
  SizeHelper get size => SizeHelper(context);

  /// نظام Typography
  TypographyHelper get text => TypographyHelper(context);

  /// نظام Spacing البسيط
  SpacingHelper get spacing => SpacingHelper(context);

  /// نظام BorderRadius
  RadiusHelper get radius => RadiusHelper(context);

  /// نظام الرموز والأيقونات
  IconHelper get icon => IconHelper(context);

  /// نظام الـ Elevation والظلال
  ElevationHelper get shadow => ElevationHelper(context);

  /// نظام Grid والـ responsive layout
  GridHelper get grid => GridHelper(context);

  /// معلومات الشاشة والـ Orientation
  ScreenHelper get screen => ScreenHelper(context);

  /// نظام Themes والألوان (extension اختياري)
  // ThemeHelper get theme => ThemeHelper(context);
  ThemeHelper get theme => ThemeHelper(context);
  // LocaleHelper get locale => LocaleHelper(context);
  ///
  DirectionHelper get dir => DirectionHelper(context);
}

class DirectionHelper {
  final BuildContext context;
  const DirectionHelper(this.context);

  bool get isRTL => Directionality.of(context) == TextDirection.rtl;

  T value<T>({required T rtl, required T ltr}) {
    return isRTL ? rtl : ltr;
  }

  Widget transformFlip({required Widget child, bool isRtlChild = true}) {
    return (isRTL)
        ? isRtlChild
              ? child
              : Transform.flip(flipX: true, child: child)
        : isRtlChild
        ? Transform.flip(flipX: true, child: child)
        : child;
  }

  IconData icon({required IconData rtl, required IconData ltr}) {
    return isRTL ? rtl : ltr;
  }
}

class ThemeHelper {
  final BuildContext context;
  const ThemeHelper(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isLight => !isDark;

  ColorScheme get colors => Theme.of(context).colorScheme;
  TextTheme get textTheme => Theme.of(context).textTheme;

  T value<T>({required T dark, required T light}) {
    return isDark ? dark : light;
  }

  T? valueOrNull<T>({T? dark, T? light}) {
    if (dark != null && light != null) {
      return isDark ? dark : light;
    } else if (dark != null) {
      return isDark ? dark : null;
    } else if (light != null) {
      return isLight ? light : null;
    }
    return null;
  }
}
// ═══════════════════════════════════════════════════════════════════
// PADDING HELPER
// ═══════════════════════════════════════════════════════════════════

class PaddingHelper {
  final BuildContext context;

  const PaddingHelper(this.context);

  /// All sides equal
  EdgeInsets all(
    AppSpacing value, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.allPadding(context, value, min: min, max: max, mode: mode);

  /// Symmetric (horizontal + vertical)
  EdgeInsets symmetric({
    AppSpacing? horizontal,
    AppSpacing? vertical,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.symmetricPadding(
    context,
    horizontal: horizontal,
    vertical: vertical,
    min: min,
    max: max,
    mode: mode,
  );

  /// Only specific sides
  EdgeInsets only({
    AppSpacing? left,
    AppSpacing? right,
    AppSpacing? top,
    AppSpacing? bottom,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.onlyPadding(
    context,
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    min: min,
    max: max,
    mode: mode,
  );

  /// Horizontal only
  EdgeInsets horizontal(
    AppSpacing value, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => symmetric(horizontal: value, min: min, max: max, mode: mode);

  /// Vertical only
  EdgeInsets vertical(
    AppSpacing value, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => symmetric(vertical: value, min: min, max: max, mode: mode);

  /// Directional padding (RTL support)
  EdgeInsetsDirectional directional({
    // AppSpacing all = AppSpacing.none,
    // AppSpacing horizontal = AppSpacing.none,
    // AppSpacing vertical = AppSpacing.none,
    AppSpacing? start,
    AppSpacing? end,
    AppSpacing? top,
    AppSpacing? bottom,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.paddingDirectional(
    context: context,
    // all: all,
    // horizontal: horizontal,
    // vertical: vertical,
    start: start,
    end: end,
    top: top,
    bottom: bottom,
    min: min,
    max: max,
    mode: mode,
  );

  /// Page-level padding (مع defaults ذكية)
  EdgeInsets page({
    AppSpacing mobileH = AppSpacing.md,
    AppSpacing mobileV = AppSpacing.sm,
    AppSpacing tabletH = AppSpacing.xl,
    AppSpacing tabletV = AppSpacing.md,
    AppSpacing desktopH = AppSpacing.huge,
    AppSpacing desktopV = AppSpacing.md,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.pagePadding(
    context,
    mobileH: mobileH,
    mobileV: mobileV,
    tabletH: tabletH,
    tabletV: tabletV,
    desktopH: desktopH,
    desktopV: desktopV,
    mode: mode,
  );
}

// ═══════════════════════════════════════════════════════════════════
// SIZE HELPER
// ═══════════════════════════════════════════════════════════════════

class SizeHelper {
  final BuildContext context;

  const SizeHelper(this.context);

  /// Width responsive
  double width(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.width(context, size, min: min, max: max, mode: mode);

  /// Height responsive
  double height(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.height(context, size, min: min, max: max, mode: mode);

  /// SizedBox بـ width
  SizedBox sizedBoxWidth(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => SizedBox(
    width: width(size, min: min, max: max, mode: mode),
  );

  /// SizedBox بـ height
  SizedBox sizedBoxHeight(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => SizedBox(
    height: height(size, min: min, max: max, mode: mode),
  );

  /// SizedBox بـ width و height
  SizedBox sizedBox(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => SizedBox(
    width: width(size, min: min, max: max, mode: mode),
    height: height(size, min: min, max: max, mode: mode),
  );

  /// Box constraints
  BoxConstraints constraints(AppComponentSize size, {bool isWidth = true}) =>
      isWidth
      ? BoxConstraints(minWidth: width(size))
      : BoxConstraints(minHeight: height(size));
}

// ═══════════════════════════════════════════════════════════════════
// TYPOGRAPHY HELPER
// ═══════════════════════════════════════════════════════════════════

class TypographyHelper {
  final BuildContext context;

  const TypographyHelper(this.context);

  /// Font size فقط
  double size(
    AppFontSize fontSize, {
    AppFontSize? min,
    AppFontSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.font(
    context,
    fontSize,
    min: min,
    max: max,
    mode: mode,
  );

  /// Text style كامل
  TextStyle style(
    AppFontSize fontSize, {
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
    AppFontSize? min,
    AppFontSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.textStyle(
    context,
    fontSize,
    weight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    min: min,
    max: max,
    mode: mode,
  );

  /// Headline 1
  TextStyle h1({
    FontWeight weight = FontWeight.bold,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.display,
    weight: weight,
    color: color,
    height: height ?? 1.2,
  );

  /// Headline 2
  TextStyle h2({
    FontWeight weight = FontWeight.bold,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.xxxl,
    weight: weight,
    color: color,
    height: height ?? 1.2,
  );

  /// Headline 3
  TextStyle h3({
    FontWeight weight = FontWeight.bold,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.xxl,
    weight: weight,
    color: color,
    height: height ?? 1.3,
  );

  /// Subtitle 1
  TextStyle subtitle1({
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.lg,
    weight: weight,
    color: color,
    height: height ?? 1.4,
  );

  /// Subtitle 2
  TextStyle subtitle2({
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.md,
    weight: weight,
    color: color,
    height: height ?? 1.4,
  );

  /// Body text
  TextStyle body({
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.base,
    weight: weight,
    color: color,
    height: height ?? 1.5,
  );

  /// Body small
  TextStyle bodySmall({
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.sm,
    weight: weight,
    color: color,
    height: height ?? 1.5,
  );

  /// Caption
  TextStyle caption({
    FontWeight weight = FontWeight.normal,
    Color? color,
    double? height,
  }) => style(
    AppFontSize.xs,
    weight: weight,
    color: color,
    height: height ?? 1.4,
  );

  /// Button text
  TextStyle button({
    FontWeight weight = FontWeight.w600,
    Color? color,
    double? letterSpacing,
  }) => style(
    AppFontSize.md,
    weight: weight,
    color: color,
    letterSpacing: letterSpacing ?? 0,
    height: 1.2,
  );
}

// ═══════════════════════════════════════════════════════════════════
// SPACING HELPER (Simple spacing values)
// ═══════════════════════════════════════════════════════════════════

class SpacingHelper {
  final BuildContext context;

  const SpacingHelper(this.context);

  /// Get spacing value responsive
  double value(
    AppSpacing spacing, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.spacing(context, spacing, min: min, max: max, mode: mode);

  /// Gap widget
  Gap gap(
    AppSpacing spacing, {
    Axis axis = Axis.vertical,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) =>
      Rh.gapSpace(context, spacing, axis: axis, min: min, max: max, mode: mode);

  /// Shortcuts
  double get none => value(AppSpacing.none);
  double get xs => value(AppSpacing.xs);
  double get sm => value(AppSpacing.sm);
  double get smMd => value(AppSpacing.smMd);
  double get md => value(AppSpacing.md);
  double get mdLg => value(AppSpacing.mdLg);
  double get lg => value(AppSpacing.lg);
  double get xl => value(AppSpacing.xl);
  double get xxl => value(AppSpacing.xxl);
  double get xxxl => value(AppSpacing.xxxl);
  double get huge => value(AppSpacing.huge);
  double get giant => value(AppSpacing.giant);
}

// ═══════════════════════════════════════════════════════════════════
// RADIUS HELPER
// ═══════════════════════════════════════════════════════════════════

class RadiusHelper {
  final BuildContext context;

  const RadiusHelper(this.context);

  /// Full radius
  BorderRadius all(
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.circularRadius(context, size, min: min, max: max, mode: mode);

  /// Specific corners
  BorderRadius corners(
    AppRadius size, {
    bool topLeft = true,
    bool topRight = true,
    bool bottomLeft = true,
    bool bottomRight = true,
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.radius(
    context,
    size,
    min: min,
    max: max,
    topLeft: topLeft,
    topRight: topRight,
    bottomLeft: bottomLeft,
    bottomRight: bottomRight,
    mode: mode,
  );

  /// Top corners only (bottom sheet style)
  BorderRadius top(
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.topRadius(context, size, min: min, max: max, mode: mode);

  /// Bottom corners only
  BorderRadius bottom(
    AppRadius size, {
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.bottomRadius(context, size, min: min, max: max, mode: mode);

  /// Directional (RTL support)
  BorderRadiusDirectional directional(
    AppRadius size, {
    bool topStart = true,
    bool topEnd = true,
    bool bottomStart = true,
    bool bottomEnd = true,
    AppRadius? min,
    AppRadius? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.radiusDirectional(
    context,
    size,
    min: min,
    max: max,
    topStart: topStart,
    topEnd: topEnd,
    bottomStart: bottomStart,
    bottomEnd: bottomEnd,
    mode: mode,
  );

  /// Shortcuts
  BorderRadius get none => all(AppRadius.none);
  BorderRadius get xs => all(AppRadius.xs);
  BorderRadius get sm => all(AppRadius.sm);
  BorderRadius get md => all(AppRadius.md);
  BorderRadius get lg => all(AppRadius.lg);
  BorderRadius get xl => all(AppRadius.xl);
  BorderRadius get xxl => all(AppRadius.xxl);
  BorderRadius get full => all(AppRadius.full);
}

// ═══════════════════════════════════════════════════════════════════
// ICON HELPER
// ═══════════════════════════════════════════════════════════════════

class IconHelper {
  final BuildContext context;

  const IconHelper(this.context);

  /// Icon size responsive
  double size(
    AppIconSize iconSize, {
    AppIconSize? min,
    AppIconSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.iconSize(context, iconSize, min: min, max: max, mode: mode);

  /// Shortcuts
  double get sm => size(AppIconSize.sm);
  double get md => size(AppIconSize.md);
  double get lg => size(AppIconSize.lg);
  double get xl => size(AppIconSize.xl);
  double get xxl => size(AppIconSize.xxl);
  double get huge => size(AppIconSize.huge);
}

// ═══════════════════════════════════════════════════════════════════
// ELEVATION HELPER
// ═══════════════════════════════════════════════════════════════════

class ElevationHelper {
  final BuildContext context;

  const ElevationHelper(this.context);

  /// Elevation value
  double value(AppElevation elevation) => Rh.elevation(context, elevation);

  /// Shadow list
  List<BoxShadow> shadows(AppElevation elevation) => [
    BoxShadow(
      offset: Offset(0, value(elevation) / 2),
      blurRadius: value(elevation),
      spreadRadius: value(elevation) / 4,
      color: Colors.black.withOpacity(0.1),
    ),
  ];

  /// Shortcuts
  double get none => value(AppElevation.none);
  double get xs => value(AppElevation.xs);
  double get sm => value(AppElevation.sm);
  double get md => value(AppElevation.md);
  double get lg => value(AppElevation.lg);
  double get xl => value(AppElevation.xl);
  double get xxl => value(AppElevation.xxl);
}

// ═══════════════════════════════════════════════════════════════════
// GRID HELPER
// ═══════════════════════════════════════════════════════════════════

class GridHelper {
  final BuildContext context;

  const GridHelper(this.context);

  /// Cross axis count responsive
  int crossAxisCount({
    int mobile = 2,
    int mobileLandscape = 3,
    int tablet = 3,
    int tabletLandscape = 4,
    int desktop = 4,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.crossAxisCount(
    context,
    mobile: mobile,
    mobileLandscape: mobileLandscape,
    tablet: tablet,
    tabletLandscape: tabletLandscape,
    desktop: desktop,
    mode: mode,
  );

  /// Widget selection responsive
  Widget widget({
    required Widget mobile,
    Widget? mobileLandscape,
    Widget? tablet,
    Widget? tabletLandscape,
    Widget? desktop,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.widget(
    context: context,
    mobile: mobile,
    mobileLandscape: mobileLandscape,
    tablet: tablet,
    tabletLandscape: tabletLandscape,
    desktop: desktop,
    mode: mode,
  );

  /// value selection responsive
  T value<T>({
    required T mobile,
    T? mobileLandscape,
    T? tablet,
    T? tabletLandscape,
    T? desktop,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.value(
    context: context,
    mobile: mobile,
    mobileLandscape: mobileLandscape,
    tablet: tablet,
    tabletLandscape: tabletLandscape,
    desktop: desktop,
    mode: mode,
  );
}

// ═══════════════════════════════════════════════════════════════════
// SCREEN HELPER
// ═══════════════════════════════════════════════════════════════════

class ScreenHelper {
  final BuildContext context;

  const ScreenHelper(this.context);

  /// Get current screen type
  ScreenType get type => ScreenEngine.screenType(context);

  /// Get current orientation
  AppOrientation get orientation => ScreenEngine.orientation(context);

  /// Check if mobile
  bool get isMobile => type == ScreenType.mobile;

  /// Check if tablet
  bool get isTablet => type == ScreenType.tablet;

  /// Check if desktop
  bool get isDesktop => type == ScreenType.desktop;

  /// Check if portrait
  bool get isPortrait => orientation == AppOrientation.portrait;

  /// Check if landscape
  bool get isLandscape => orientation == AppOrientation.landscape;

  /// Screen width
  double width({double rate = 1}) => MediaQuery.of(context).size.width * rate;

  /// Screen height
  double height({double rate = 1}) => MediaQuery.of(context).size.height * rate;

  /// Screen size
  Size get size => MediaQuery.of(context).size;

  /// Device pixel ratio
  double get pixelRatio => MediaQuery.of(context).devicePixelRatio;

  /// SafeArea padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(context).padding;

  /// ViewInsets (keyboard height, etc)
  EdgeInsets get viewInsets => MediaQuery.of(context).viewInsets;
}
