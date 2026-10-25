import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/styles/styles_extension.dart';

NavigationBarThemeData buildNavigationBarTheme(
  BuildContext context, {
  required ColorScheme colorScheme,
}) {
  return NavigationBarThemeData(
    elevation: 0,
    height: context.uiStyles.navbar.height, // 🔥 هنا الربط
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
