import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// Every visual value of `AppSidebar`, resolved for the current context.
///
/// The look comes from tokens: the active pill is `AppSaasColors.selected`
/// (the brand color), the pill shape is `AppSurfaceShape.pill`, and the
/// surface is the card surface; change those and the sidebar follows.
class AppSidebarStyle {
  final BuildContext context;
  final bool collapsed;

  const AppSidebarStyle(this.context, {this.collapsed = false});

  static const _width = AppComponentSize(240, 256, 272);

  ColorScheme get _scheme => Theme.of(context).colorScheme;
  AppSaasColors get _saas => context.ui.theme.saasColors;

  double get width => Rh.width(
    context,
    collapsed ? AppComponentSize.sidebarCollapsed : _width,
    mode: ResponsiveMode.adaptiveOnly,
  );

  double get iconSize => Rh.iconSize(context, AppIconSize.lg);
  EdgeInsets get padding => Rh.allPadding(context, AppSpacing.sm);
  double get childIconSize => Rh.iconSize(context, AppIconSize.md);
  EdgeInsets get chevronPadding => Rh.allPadding(context, AppSpacing.xs);
  double get chevronSize => Rh.iconSize(context, AppIconSize.sm);
  double get childIndent => Rh.spacing(context, AppSpacing.lg);

  /// Gap between the tree line and the child pill.
  double get childLineGap => Rh.spacing(context, AppSpacing.sm);
  double get itemGap => Rh.spacing(context, AppSpacing.xs);
  double get iconLabelGap => Rh.spacing(context, AppSpacing.smMd);
  double get itemMinHeight => Rh.width(context, AppComponentSize.large);

  EdgeInsetsDirectional get itemPadding => EdgeInsetsDirectional.symmetric(
    horizontal: Rh.spacing(
      context,
      collapsed ? AppSpacing.sm : AppSpacing.smMd,
    ),
    vertical: Rh.spacing(context, AppSpacing.sm),
  );

  EdgeInsets get togglePadding => Rh.allPadding(context, AppSpacing.xs);
  BorderRadius get itemRadius => AppSurfaceShape.pill.circular(context);

  Color get background => _scheme.surface;
  Color get selectedBackground => _saas.selected;
  Color get selectedForeground => _saas.onSelected;
  Color get foreground => _scheme.onSurfaceVariant;

  /// The parent of the active child: no fill, the brand color on the label.
  Color get ancestorForeground => _saas.selected;

  /// The tree line joining a parent to its children.
  Color get line => _scheme.outlineVariant;
  double get lineWidth => AppBorderWidth.thin.of(context);

  Color itemBackground({required bool selected}) =>
      selected ? selectedBackground : Colors.transparent;

  Color itemForeground({required bool selected, bool ancestor = false}) =>
      selected
      ? selectedForeground
      : ancestor
      ? ancestorForeground
      : foreground;

  BorderDirectional get border =>
      BorderDirectional(end: BorderSide(color: _scheme.outlineVariant));
}
