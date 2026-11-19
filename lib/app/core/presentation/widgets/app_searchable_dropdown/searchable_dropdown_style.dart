import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/extension/ui_extension.dart';

/// Theme and token resolver for SearchableDropdown.
class SearchableDropdownStyle {
  const SearchableDropdownStyle(this.context);
  final BuildContext context;

  ColorScheme get colors => context.ui.theme.colors;
  BorderRadius get radius => context.ui.radius.all(AppRadius.md);
  EdgeInsets get optionPadding => context.ui.padding.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );
  double get maxOptionsHeight =>
      context.ui.size.height(AppComponentSize.cardHeight) * 2;
}
