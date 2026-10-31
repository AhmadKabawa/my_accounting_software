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

/// Context-free base theme: colors, shapes and the font family.
/// Safe to build once and use directly as MaterialApp.theme/darkTheme.
ThemeData buildTheme({required ColorScheme colorScheme}) => ThemeData(
  useMaterial3: true,
  brightness: colorScheme.brightness,
  fontFamily: 'Cairo',
  colorScheme: colorScheme,
  bottomSheetTheme: buildBottomSheetTheme(colorScheme: colorScheme),
  checkboxTheme: buildCheckboxTheme(colorScheme: colorScheme),
  scaffoldBackgroundColor: colorScheme.surface,
);

/// Responsive layer: text sizes and component styles that depend on the screen.
/// Must be called with a context BELOW MaterialApp (e.g. MaterialApp.builder),
/// so [Theme] and [MediaQuery] resolve correctly.
ThemeData buildResponsiveTheme(BuildContext context, ThemeData base) {
  final colorScheme = base.colorScheme;
  final textTheme = base.textTheme.merge(
    buildTextTheme(context: context, colorScheme: colorScheme),
  );
  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: buildAppBarTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ),
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
  );
}
