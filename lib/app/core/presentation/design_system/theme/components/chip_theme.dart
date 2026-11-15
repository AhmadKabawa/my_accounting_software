// components/chip_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

/// Chips are fully rounded. A selected chip uses primaryContainer so its label
/// keeps a readable contrast (it is not a solid primary fill).
ChipThemeData buildChipTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return ChipThemeData(
    shape: const StadiumBorder(),
    side: BorderSide(
      color: colorScheme.outlineVariant,
      width: AppBorderWidth.thin.mobile,
    ),
    disabledColor: colorScheme.onSurface.withOpacity(0.1),
    labelStyle: textTheme.labelMedium,
    selectedColor: colorScheme.primaryContainer,
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.smMd.mobile,
      vertical: AppSpacing.sm.mobile,
    ),
    checkmarkColor: colorScheme.onPrimaryContainer,
  );
}
