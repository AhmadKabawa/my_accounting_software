import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/build_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/dark_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/light_theme.dart';

class AppTheme {
  static ThemeData light(BuildContext context) =>
      buildTheme(context: context, colorScheme: lightColorScheme);
  static ThemeData dark(BuildContext context) =>
      buildTheme(context: context, colorScheme: darkColorScheme);
}
