// components/input_decoration_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';

InputDecorationTheme buildInputDecorationTheme(
  BuildContext contex, {
  required ColorScheme colorScheme,
}) {
  return InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: colorScheme.onSurfaceVariant,
    suffixIconColor: colorScheme.onSurfaceVariant,
    labelStyle: contex.textTheme.labelMedium!.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    hintStyle: contex.textTheme.titleSmall!.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    floatingLabelStyle: contex.textTheme.labelLarge!.copyWith(
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
