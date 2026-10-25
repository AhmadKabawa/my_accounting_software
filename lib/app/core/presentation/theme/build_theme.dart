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

ThemeData buildTheme({
  required BuildContext context,
  required ColorScheme colorScheme,
}) => ThemeData(
  useMaterial3: true,
  brightness: colorScheme.brightness,
  fontFamily: 'Cairo',
  colorScheme: colorScheme,

  textTheme: buildTextTheme(context: context, colorScheme: colorScheme),
  appBarTheme: buildAppBarTheme(context, colorScheme: colorScheme),
  bottomSheetTheme: buildBottomSheetTheme(context, colorScheme: colorScheme),
  checkboxTheme: buildCheckboxTheme(context, colorScheme: colorScheme),
  chipTheme: buildChipTheme(context, colorScheme: colorScheme),
  elevatedButtonTheme: buildElevatedButtonTheme(
    context,
    colorScheme: colorScheme,
  ),
  outlinedButtonTheme: buildOutlinedButtonTheme(
    context,
    colorScheme: colorScheme,
  ),
  inputDecorationTheme: buildInputDecorationTheme(
    context,
    colorScheme: colorScheme,
  ),
  navigationBarTheme: buildNavigationBarTheme(
    context,
    colorScheme: colorScheme,
  ),
  scaffoldBackgroundColor: colorScheme.surface,
);
