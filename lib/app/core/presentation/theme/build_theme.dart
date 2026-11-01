import 'package:flutter/material.dart';

import 'package:accounting_software/app/core/presentation/theme/app_text_styles.dart';
import 'package:accounting_software/app/core/presentation/theme/components/app_bar_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/bottom_sheet_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/checkbox_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/chip_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/elevated_button_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/input_decoration_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/navigation_bar_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/outlined_button_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/components/text_theme.dart';

/// Builds the app theme without a [BuildContext], so it can be created before
/// MaterialApp exists (there is no MediaQuery yet at that point).
///
/// Called as-is it holds the mobile baseline sizes. [ResponsiveTheme] calls it
/// again under MaterialApp with [resolve] (responsive font sizes) and
/// [navigationBarHeight] to get the values for the current screen.
ThemeData buildTheme({
  required ColorScheme colorScheme,
  TextStyle Function(AppTextStyle style)? resolve,
  double? navigationBarHeight,
}) {
  final textTheme = buildTextTheme(colorScheme: colorScheme, resolve: resolve);

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
      colorScheme: colorScheme,
      height: navigationBarHeight,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
  );
}
