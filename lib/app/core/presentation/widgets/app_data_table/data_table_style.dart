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
  BorderRadius get cardRadius => context.ui.radius.md;
  Color get divider => colors.outlineVariant;
}
