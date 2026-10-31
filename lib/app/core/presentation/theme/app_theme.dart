import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/build_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/dark_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/light_theme.dart';

class AppTheme {
  static ThemeData light() => buildTheme(colorScheme: lightColorScheme);
  static ThemeData dark() => buildTheme(colorScheme: darkColorScheme);

  /// Adds the screen-dependent parts (text sizes, button/input styles) on top
  /// of the active theme. Call from MaterialApp.builder.
  static ThemeData responsive(BuildContext context) =>
      buildResponsiveTheme(context, Theme.of(context));
}
