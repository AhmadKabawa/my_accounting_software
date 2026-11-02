// components/checkbox_theme.dart
import 'package:flutter/material.dart';
 

CheckboxThemeData buildCheckboxTheme({required ColorScheme colorScheme}) {
  return CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primary;
      }
      return colorScheme.surface;
    }),
  );
}
