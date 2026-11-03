import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// Every visual value of `AppSidebar`, resolved for the current context.
/// Nothing here is a literal: sizes come from tokens, colors from the theme.
class AppSidebarStyle {
  final BuildContext context;

  const AppSidebarStyle(this.context);

  /// The sidebar only shows on desktop; the other values keep it consistent
  /// if it is ever used on a smaller screen.
  static const _width = AppComponentSize(240, 256, 272);

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  // ═══════════════════════════════════════════
  // 🔹 SIZES
  // ═══════════════════════════════════════════

  double get width =>
      Rh.width(context, _width, mode: ResponsiveMode.adaptiveOnly);

  double get iconSize => Rh.iconSize(context, AppIconSize.lg);

  EdgeInsets get padding => Rh.allPadding(context, AppSpacing.sm);

  double get itemGap => Rh.spacing(context, AppSpacing.xs);

  double get iconLabelGap => Rh.spacing(context, AppSpacing.smMd);

  double get itemMinHeight => Rh.width(context, AppComponentSize.large);

  EdgeInsetsDirectional get itemPadding => EdgeInsetsDirectional.symmetric(
    horizontal: Rh.spacing(context, AppSpacing.smMd),
    vertical: Rh.spacing(context, AppSpacing.sm),
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
