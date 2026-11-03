import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// Every visual value of `AppNavigationRail`, resolved for the current context.
/// Nothing here is a literal: sizes come from `Rh.*` tokens, colors from the
/// theme.
class AppNavigationRailStyle {
  final BuildContext context;

  const AppNavigationRailStyle(this.context);

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  // ═══════════════════════════════════════════
  // 🔹 SIZES
  // ═══════════════════════════════════════════

  double get iconSize => Rh.iconSize(context, AppIconSize.lg);

  EdgeInsets get padding => Rh.allPadding(context, AppSpacing.sm);

  /// An item is as wide as the rail's content box.
  double get itemWidth => Rh.width(context, AppComponentSize.xLarge);

  double get width => itemWidth + padding.horizontal;

  double get itemGap => Rh.spacing(context, AppSpacing.xs);

  double get iconLabelGap => Rh.spacing(context, AppSpacing.xs);

  EdgeInsets get itemPadding => Rh.symmetricPadding(
    context,
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.sm,
  );

  BorderRadius get itemRadius => Rh.radius(context, AppRadius.md);

  // ═══════════════════════════════════════════
  // 🔹 COLORS
  // ═══════════════════════════════════════════

  Color get background => _scheme.surfaceContainer;

  Color get selectedBackground => _scheme.secondaryContainer;

  Color get selectedForeground => _scheme.onSecondaryContainer;

  Color get foreground => _scheme.onSurfaceVariant;

  Color itemBackground({required bool selected}) =>
      selected ? selectedBackground : Colors.transparent;

  Color itemForeground({required bool selected}) =>
      selected ? selectedForeground : foreground;

  /// Hairline on the side facing the content (the end side, so it follows RTL).
  BorderDirectional get border =>
      BorderDirectional(end: BorderSide(color: _scheme.outlineVariant));
}
