import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

class FilterBarStyle {
  const FilterBarStyle(this.context);
  final BuildContext context;
  ColorScheme get colors => context.ui.theme.colors;
  EdgeInsets get padding => context.ui.padding.all(AppSpacing.sm);
  BorderRadius get chipRadius => context.ui.radius.md;
  double get gap => context.ui.spacing.sm;
}
