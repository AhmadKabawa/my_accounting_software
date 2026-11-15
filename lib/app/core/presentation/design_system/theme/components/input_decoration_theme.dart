// components/input_decoration_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

/// Fields sit on a surface with a control border (3:1 contrast). Focus is a
/// 2px ring in [focusColor]; errors keep the error color.
InputDecorationTheme buildInputDecorationTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
  required Color focusColor,
}) {
  return InputDecorationTheme(
    errorMaxLines: 3,
    filled: true,
    fillColor: colorScheme.surface,
    prefixIconColor: colorScheme.onSurfaceVariant,
    suffixIconColor: colorScheme.onSurfaceVariant,
    labelStyle: textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    hintStyle: textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    floatingLabelStyle: textTheme.labelLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    border: _border(colorScheme.outline),
    enabledBorder: _border(colorScheme.outline),
    focusedBorder: _border(focusColor, width: AppBorderWidth.thick.mobile),
    errorBorder: _border(colorScheme.error),
    focusedErrorBorder: _border(
      colorScheme.error,
      width: AppBorderWidth.thick.mobile,
    ),
  );
}

OutlineInputBorder _border(Color color, {double? width}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md.mobile),
    borderSide: BorderSide(
      color: color,
      width: width ?? AppBorderWidth.thin.mobile,
    ),
  );
}
