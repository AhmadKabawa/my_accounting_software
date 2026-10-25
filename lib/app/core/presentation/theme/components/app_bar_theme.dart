// components/appbar_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';

AppBarTheme buildAppBarTheme(
  BuildContext contex, {
  required ColorScheme colorScheme,
}) {
  return AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
    actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
    titleTextStyle: contex.textTheme.titleMedium,
  );
}
