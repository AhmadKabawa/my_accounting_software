import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_text_styles.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/app_bar_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/bottom_sheet_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/card_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/checkbox_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/chip_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/elevated_button_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/input_decoration_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/navigation_bar_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/outlined_button_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/components/text_theme.dart';

/// Builds the [ThemeData] from the [ColorScheme] alone. It runs above
/// MaterialApp, where there is no BuildContext/MediaQuery, so every size here
/// is the mobile baseline; responsive sizes are resolved by the widgets.
/// [semanticColors] is registered as a [ThemeExtension] (success/warning/...).
///
/// [background] is the page color (Scaffold). It is separate from
/// `colorScheme.surface`, which is the color of cards and tables.
ThemeData buildTheme({
  required ColorScheme colorScheme,
  required AppSemanticColors semanticColors,
  required Color background,
}) {
  final textTheme = buildTextTheme(colorScheme: colorScheme);

  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    fontFamily: AppFontFamily.sans,
    colorScheme: colorScheme,
    extensions: [semanticColors],
    textTheme: textTheme,
    appBarTheme: buildAppBarTheme(
      colorScheme: colorScheme,
      textTheme: textTheme,
    ),
    bottomSheetTheme: buildBottomSheetTheme(colorScheme: colorScheme),
    cardTheme: buildCardTheme(colorScheme: colorScheme),
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
      focusColor: semanticColors.focusRing,
    ),
    navigationBarTheme: buildNavigationBarTheme(colorScheme: colorScheme),
    scaffoldBackgroundColor: background,
  );
}
