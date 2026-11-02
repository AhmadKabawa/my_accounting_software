// components/outlined_button_theme.dart
import 'package:flutter/material.dart';

OutlinedButtonThemeData buildOutlinedButtonTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      side: BorderSide(color: colorScheme.outline),
      textStyle: textTheme.titleMedium,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
