import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/responsive/helper/responsive_helper.dart';

/// [height] defaults to the mobile baseline; ResponsiveTheme passes the
/// responsive value once a MediaQuery is available.
NavigationBarThemeData buildNavigationBarTheme({
  required ColorScheme colorScheme,
  double? height,
}) {
  return NavigationBarThemeData(
    elevation: 0,
    height: height ?? AppSpacing.xl.mobile,
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
