import 'package:flutter/material.dart';

/// Motion tokens. Motion serves meaning (showing a layer, confirming a save),
/// never decoration. With "reduce motion" on in the device, [duration] gives
/// [Duration.zero], so transitions become an instant change.
///
/// ```dart
/// AnimatedContainer(
///   duration: AppMotion.duration(context, AppMotionDuration.base),
///   curve: AppMotion.standard,
/// )
/// ```
enum AppMotionDuration {
  /// Hover, state change, checkbox.
  fast(Duration(milliseconds: 150)),

  /// Opening menus, switching tabs.
  base(Duration(milliseconds: 200)),

  /// Dialogs, bottom sheets, page transitions.
  slow(Duration(milliseconds: 300));

  const AppMotionDuration(this.value);

  final Duration value;
}

abstract final class AppMotion {
  /// Default curve.
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// Elements entering.
  static const Curve enter = Cubic(0.05, 0.7, 0.1, 1);

  /// Elements leaving.
  static const Curve exit = Cubic(0.3, 0, 0.8, 0.15);

  /// The duration of [token], or [Duration.zero] when the device asks to
  /// reduce motion.
  static Duration duration(BuildContext context, AppMotionDuration token) =>
      reduceMotion(context) ? Duration.zero : token.value;

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}
