import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

class DataTableStyle {
  const DataTableStyle(this.context, {required this.density});
  final BuildContext context;
  final AppDensity density;

  ColorScheme get colors => context.ui.theme.colors;
  double get rowHeight => density.rowHeight(context.ui.screen.type);
  double get headerHeight => density.headerHeight(context.ui.screen.type);
  double get gap => context.ui.spacing.md;
  EdgeInsets get cellPadding => context.ui.padding.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );
  Color get divider => colors.outlineVariant;

  /// Modern look: the table sits in a rounded, bordered surface, with a
  /// quiet header and a hover highlight on rows.
  BorderRadius get radius => context.ui.radius.md;
  Border get border => Border.all(color: divider);
  Color get headerBackground => colors.surfaceContainerLow;
  Color get rowHover => colors.surfaceContainerHighest;
  Color get surface => colors.surface;
}
