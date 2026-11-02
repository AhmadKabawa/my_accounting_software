import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/engine/app_enums.dart';

NavigationBarThemeData buildNavigationBarTheme({
  required ColorScheme colorScheme,
}) {
  return NavigationBarThemeData(
    elevation: 0,
    height: AppSpacing.xl.mobile,
    backgroundColor: colorScheme.surface,
    indicatorColor: colorScheme.surfaceContainerHighest,

    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: colorScheme.primary);
      }

      return IconThemeData(color: colorScheme.onSurfaceVariant);
    }),
  );
}
