import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/helper/responsive_helper.dart';

/// Every visual value of `AppSidebar`, resolved for the current context.
class AppSidebarStyle {
  final BuildContext context;
  final bool collapsed;

  const AppSidebarStyle(this.context, {this.collapsed = false});

  static const _width = AppComponentSize(240, 256, 272);

  ColorScheme get _scheme => Theme.of(context).colorScheme;

  double get width => Rh.width(
    context,
    collapsed ? AppComponentSize.sidebarCollapsed : _width,
    mode: ResponsiveMode.adaptiveOnly,
  );

  double get iconSize => Rh.iconSize(context, AppIconSize.lg);
  EdgeInsets get padding => Rh.allPadding(context, AppSpacing.sm);
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
  BorderRadius get itemRadius => Rh.radius(context, AppRadius.md);
  Color get background => _scheme.surfaceContainer;
  Color get selectedBackground => _scheme.primaryContainer;
  Color get selectedForeground => _scheme.onPrimaryContainer;
  Color get foreground => _scheme.onSurfaceVariant;

  Color itemBackground({required bool selected}) =>
      selected ? selectedBackground : Colors.transparent;

  Color itemForeground({required bool selected}) =>
      selected ? selectedForeground : foreground;

  BorderDirectional get border =>
      BorderDirectional(end: BorderSide(color: _scheme.outlineVariant));
}
