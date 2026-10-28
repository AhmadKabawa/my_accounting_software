import 'package:flutter/material.dart';

import 'package:accounting_software/app/core/presentation/theme/components/app_bar_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/bottom_sheet_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/checkbox_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/chip_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/elevated_button_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/input_decoration_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/navigation_bar_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/outlined_button_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/text_theme.dart';

/// [context] is only needed for the responsive parts (font sizes and the
/// navigation bar height). Every other component theme is built from the
/// [ColorScheme] and the already-built [TextTheme]; reading `Theme.of(context)`
/// here would return the fallback theme, because this runs above MaterialApp.
ThemeData buildTheme({
  required BuildContext context,
  required ColorScheme colorScheme,
}) {
  final textTheme = buildTextTheme(context: context, colorScheme: colorScheme);

  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    fontFamily: 'Cairo',
    colorScheme: colorScheme,
    textTheme: textTheme,
    appBarTheme: buildAppBarTheme(colorScheme: colorScheme, textTheme: textTheme),
    bottomSheetTheme: buildBottomSheetTheme(colorScheme: colorScheme),
    checkboxTheme: buildCheckboxTheme(colorScheme: colorScheme),
    chipTheme: buildChipTheme(colorScheme: colorScheme, textTheme: textTheme),
    elevatedButtonTheme: buildElevatedButtonTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ),
    outlinedButtonTheme: buildOutlinedButtonTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ),
    inputDecorationTheme: buildInputDecorationTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ),
    navigationBarTheme: buildNavigationBarTheme(
      context,
      colorScheme: colorScheme,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
  );
}
