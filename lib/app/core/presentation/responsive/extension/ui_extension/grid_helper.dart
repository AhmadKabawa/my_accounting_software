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
