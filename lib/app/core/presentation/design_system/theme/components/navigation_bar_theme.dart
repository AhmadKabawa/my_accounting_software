import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

/// The active item uses primaryContainer / onPrimaryContainer (nav-item-active).
NavigationBarThemeData buildNavigationBarTheme({
  required ColorScheme colorScheme,
}) {
  return NavigationBarThemeData(
    elevation: AppElevation.none.mobile,
    height: AppSpacing.xl.mobile,
    backgroundColor: colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    indicatorColor: colorScheme.primaryContainer,

    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: colorScheme.onPrimaryContainer);
      }

      return IconThemeData(color: colorScheme.onSurfaceVariant);
    }),
  );
}
