import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_colors.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/build_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/dark_theme.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/extensions/app_semantic_colors.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/light_theme.dart';

class AppTheme {
  static ThemeData light() => buildTheme(
    colorScheme: lightColorScheme,
    semanticColors: AppSemanticColors.light,
    background: AppLightColors.background,
  );
  static ThemeData dark() => buildTheme(
    colorScheme: darkColorScheme,
    semanticColors: AppSemanticColors.dark,
    background: AppDarkColors.background,
  );
}
