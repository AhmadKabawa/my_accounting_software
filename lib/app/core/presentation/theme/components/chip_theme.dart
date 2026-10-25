// components/chip_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';

ChipThemeData buildChipTheme(
  BuildContext contex, {
  required ColorScheme colorScheme,
}) {
  return ChipThemeData(
    disabledColor: colorScheme.onSurface.withOpacity(0.1),
    labelStyle: contex.textTheme.labelMedium,
    selectedColor: colorScheme.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: colorScheme.onPrimary,
  );
}
