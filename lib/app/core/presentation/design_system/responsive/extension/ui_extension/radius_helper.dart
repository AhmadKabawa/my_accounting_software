part of '../ui_extension.dart';

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
