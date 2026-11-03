part of '../responsive_helper.dart';

// ═══════════════════════════════════════════════════════════════════
// CONTEXT EXTENSIONS — Convenient shortcut methods
// ═══════════════════════════════════════════════════════════════════

/// Extends [BuildContext] with responsive helper shortcuts
///
/// Allows using `context.spacing()` instead of `Rh.spacing(context, ...)`
extension ResponsiveContextExtension on BuildContext {
  /// Shortcut for [ResponsiveHelper.spacing]
  /// Usage: `context.spacing(AppSpacing.md)`
  double spacing(
    AppSpacing size, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.spacing(this, size, min: min, max: max, mode: mode);

  /// Shortcut for [ResponsiveHelper.font]
  /// Usage: `context.fontSize(AppFontSize.lg)`
  double fontSize(
    AppFontSize size, {
    AppFontSize? min,
    AppFontSize? max,
    bool respectTextScaler = true,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.font(
    this,
    size,
    min: min,
    max: max,
    respectTextScaler: respectTextScaler,
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
  /// Usage: `context.componentSize(AppComponentSize.medium)`
  // Not named `size`: BuildContext already has a `size` getter, which wins over
  // an extension member and makes `context.size(...)` uncallable.
  double componentSize(
    AppComponentSize size, {
    AppComponentSize? min,
    AppComponentSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => ResponsiveHelper.size_(this, size, min: min, max: max, mode: mode);

  /// Shortcut for [ResponsiveHelper.elevation]
  /// Usage: `context.elevation(AppElevation.md)`
  double elevation(
    AppElevation size, {
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => ResponsiveHelper.elevation(this, size, mode: mode);

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
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
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
    bool respectTextScaler = true,
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
    respectTextScaler: respectTextScaler,
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
    required WidgetBuilder mobile,
    WidgetBuilder? tablet,
    WidgetBuilder? desktop,
    WidgetBuilder? mobileLandscape,
    WidgetBuilder? tabletLandscape,
  }) => ResponsiveHelper.builder(
    context: this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
    mobileLandscape: mobileLandscape,
    tabletLandscape: tabletLandscape,
  );
  int grid({int mobile = 2, int tablet = 3, int desktop = 4}) =>
      ResponsiveHelper.crossAxisCount(
        this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
