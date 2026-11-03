part of '../ui_extension.dart';

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

  /// Device-level builder selection (only the chosen builder runs)
  Widget widget({
    required WidgetBuilder mobile,
    WidgetBuilder? mobileLandscape,
    WidgetBuilder? tablet,
    WidgetBuilder? tabletLandscape,
    WidgetBuilder? desktop,
  }) => Rh.builder(
    context: context,
    mobile: mobile,
    mobileLandscape: mobileLandscape,
    tablet: tablet,
    tabletLandscape: tabletLandscape,
    desktop: desktop,
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
