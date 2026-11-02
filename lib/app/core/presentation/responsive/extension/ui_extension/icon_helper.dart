part of '../ui_extension.dart';

// ═══════════════════════════════════════════════════════════════════
// ICON HELPER
// ═══════════════════════════════════════════════════════════════════

class IconHelper {
  final BuildContext context;

  const IconHelper(this.context);

  /// Icon size responsive
  double size(
    AppIconSize iconSize, {
    AppIconSize? min,
    AppIconSize? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.iconSize(context, iconSize, min: min, max: max, mode: mode);

  /// Shortcuts
  double get sm => size(AppIconSize.sm);
  double get md => size(AppIconSize.md);
  double get lg => size(AppIconSize.lg);
  double get xl => size(AppIconSize.xl);
  double get xxl => size(AppIconSize.xxl);
  double get huge => size(AppIconSize.huge);
}
