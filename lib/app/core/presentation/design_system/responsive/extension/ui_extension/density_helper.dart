part of '../ui_extension.dart';

// Density access is centralized here so widgets do not duplicate scope logic.
class DensityHelper {
  final BuildContext context;
  const DensityHelper(this.context);

  /// Nearest density scope, or comfortable when no scope is present.
  AppDensity get current => AppDensityScope.of(context);

  /// Explicit override takes precedence over the nearest scope.
  AppDensity resolve([AppDensity? override]) => override ?? current;

  bool isCompact([AppDensity? override]) =>
      resolve(override) == AppDensity.compact;

  /// Phone check used to preserve the existing touch-target behavior.
  bool get isPhone => ScreenEngine.screenType(context) == ScreenType.mobile;

  double rowHeight([AppDensity? override]) =>
      resolve(override).rowHeight(ScreenEngine.screenType(context));

  double fieldHeight([AppDensity? override]) =>
      resolve(override).fieldHeight(ScreenEngine.screenType(context));

  double headerHeight([AppDensity? override]) =>
      resolve(override).headerHeight(ScreenEngine.screenType(context));
}
