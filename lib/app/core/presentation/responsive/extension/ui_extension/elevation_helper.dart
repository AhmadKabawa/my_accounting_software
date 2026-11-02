part of '../ui_extension.dart';

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
