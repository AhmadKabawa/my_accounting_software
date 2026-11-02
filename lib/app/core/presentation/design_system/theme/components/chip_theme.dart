// components/chip_theme.dart
import 'package:flutter/material.dart';

ChipThemeData buildChipTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return ChipThemeData(
    disabledColor: colorScheme.onSurface.withOpacity(0.1),
    labelStyle: textTheme.labelMedium,
    selectedColor: colorScheme.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: colorScheme.onPrimary,
  );
}
