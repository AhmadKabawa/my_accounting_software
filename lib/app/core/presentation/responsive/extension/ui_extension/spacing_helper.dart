part of '../ui_extension.dart';

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
    Axis? axis,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
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
