// components/elevated_button_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';

ElevatedButtonThemeData buildElevatedButtonTheme(
  BuildContext contex, {
  required ColorScheme colorScheme,
}) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.4),
      disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: contex.textTheme.titleMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
