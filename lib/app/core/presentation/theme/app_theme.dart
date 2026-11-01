import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/build_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/dark_theme.dart';
import 'package:accounting_software/app/core/presentation/theme/light_theme.dart';

/// Context-free themes (mobile baseline sizes). Wrap the app content in
/// `ResponsiveTheme` (see MaterialApp.builder) to get responsive sizes.
class AppTheme {
  static ThemeData light() => buildTheme(colorScheme: lightColorScheme);
  static ThemeData dark() => buildTheme(colorScheme: darkColorScheme);
}
