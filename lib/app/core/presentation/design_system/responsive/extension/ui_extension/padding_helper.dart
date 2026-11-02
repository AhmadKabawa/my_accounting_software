part of '../ui_extension.dart';

// ═══════════════════════════════════════════════════════════════════
// PADDING HELPER
// ═══════════════════════════════════════════════════════════════════

class PaddingHelper {
  final BuildContext context;

  const PaddingHelper(this.context);

  /// All sides equal
  EdgeInsets all(
    AppSpacing value, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.allPadding(context, value, min: min, max: max, mode: mode);

  /// Symmetric (horizontal + vertical)
  EdgeInsets symmetric({
    AppSpacing horizontal = AppSpacing.none,
    AppSpacing vertical = AppSpacing.none,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.symmetricPadding(
    context,
    horizontal: horizontal,
    vertical: vertical,
    min: min,
    max: max,
    mode: mode,
  );

  /// Only specific sides
  EdgeInsets only({
    AppSpacing left = AppSpacing.none,
    AppSpacing right = AppSpacing.none,
    AppSpacing top = AppSpacing.none,
    AppSpacing bottom = AppSpacing.none,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.onlyPadding(
    context,
    left: left,
    right: right,
    top: top,
    bottom: bottom,
    min: min,
    max: max,
    mode: mode,
  );

  /// Horizontal only
  EdgeInsets horizontal(
    AppSpacing value, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => symmetric(horizontal: value, min: min, max: max, mode: mode);

  /// Vertical only
  EdgeInsets vertical(
    AppSpacing value, {
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => symmetric(vertical: value, min: min, max: max, mode: mode);

  /// Directional padding (RTL support)
  EdgeInsetsDirectional directional({
    // AppSpacing all = AppSpacing.none,
    // AppSpacing horizontal = AppSpacing.none,
    // AppSpacing vertical = AppSpacing.none,
    AppSpacing start = AppSpacing.none,
    AppSpacing end = AppSpacing.none,
    AppSpacing top = AppSpacing.none,
    AppSpacing bottom = AppSpacing.none,
    AppSpacing? min,
    AppSpacing? max,
    ResponsiveMode mode = ResponsiveMode.adaptiveScale,
  }) => Rh.paddingDirectional(
    context: context,
    // all: all,
    // horizontal: horizontal,
    // vertical: vertical,
    start: start,
    end: end,
    top: top,
    bottom: bottom,
    min: min,
    max: max,
    mode: mode,
  );

  /// Page-level padding (مع defaults ذكية)
  EdgeInsets page({
    AppSpacing mobileH = AppSpacing.md,
    AppSpacing mobileV = AppSpacing.sm,
    AppSpacing tabletH = AppSpacing.xl,
    AppSpacing tabletV = AppSpacing.md,
    AppSpacing desktopH = AppSpacing.huge,
    AppSpacing desktopV = AppSpacing.md,
    ResponsiveMode mode = ResponsiveMode.adaptiveOnly,
  }) => Rh.pagePadding(
    context,
    mobileH: mobileH,
    mobileV: mobileV,
    tabletH: tabletH,
    tabletV: tabletV,
    desktopH: desktopH,
    desktopV: desktopV,
    mode: mode,
  );
}
