import 'package:flutter/widgets.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/screen_engine.dart';

/// Sets the [AppDensity] for a subtree (a dense table, a compact form).
///
/// Without a scope the density is [AppDensity.comfortable], which keeps the
/// look every screen has today. Density follows the input style the screen
/// chooses, never a platform name. On a phone [compact] has no effect, so the
/// touch target never drops below the floor in [AppDensity].
class AppDensityScope extends InheritedWidget {
  const AppDensityScope({
    super.key,
    required this.density,
    required super.child,
  });

  final AppDensity density;

  /// The density in effect for [context] (comfortable when no scope).
  static AppDensity of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppDensityScope>()?.density ??
      AppDensity.comfortable;

  /// The control height to use, or null to keep the control's own height.
  ///
  /// Only [AppDensity.compact] on a non-phone screen shortens a control; it
  /// never makes one taller than it already is.
  static double? compactHeight(BuildContext context, AppDensity density) {
    if (density != AppDensity.compact) return null;
    if (ScreenEngine.screenType(context) == ScreenType.mobile) return null;
    return density.field;
  }

  @override
  bool updateShouldNotify(AppDensityScope oldWidget) =>
      density != oldWidget.density;
}
