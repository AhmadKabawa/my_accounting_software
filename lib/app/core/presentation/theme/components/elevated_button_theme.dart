// components/elevated_button_theme.dart
import 'package:flutter/material.dart';

ElevatedButtonThemeData buildElevatedButtonTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.4),
      disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: textTheme.titleMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
