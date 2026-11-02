// components/input_decoration_theme.dart
import 'package:flutter/material.dart';

InputDecorationTheme buildInputDecorationTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: colorScheme.onSurfaceVariant,
    suffixIconColor: colorScheme.onSurfaceVariant,
    labelStyle: textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    hintStyle: textTheme.titleSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    floatingLabelStyle: textTheme.labelLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    border: _border(colorScheme.outline),
    enabledBorder: _border(colorScheme.outline),
    focusedBorder: _border(colorScheme.primary),
    errorBorder: _border(colorScheme.error),
    focusedErrorBorder: _border(colorScheme.error, width: 2),
  );
}

OutlineInputBorder _border(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}
