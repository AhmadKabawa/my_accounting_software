// components/checkbox_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

CheckboxThemeData buildCheckboxTheme({required ColorScheme colorScheme}) {
  return CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xs.mobile),
    ),
    // The control border keeps the 3:1 contrast against the surface.
    side: BorderSide(
      color: colorScheme.outline,
      width: AppBorderWidth.thick.mobile,
    ),
    checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primary;
      }
      return colorScheme.surface;
    }),
  );
}
