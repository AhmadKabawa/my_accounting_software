// components/outlined_button_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';

OutlinedButtonThemeData buildOutlinedButtonTheme(
  BuildContext contex, {
  required ColorScheme colorScheme,
}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      side: BorderSide(color: colorScheme.outline),
      textStyle: contex.textTheme.titleMedium,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
