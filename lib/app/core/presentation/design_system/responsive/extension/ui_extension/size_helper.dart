part of '../ui_extension.dart';

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
