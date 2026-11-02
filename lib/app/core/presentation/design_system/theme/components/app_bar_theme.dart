// components/appbar_theme.dart
import 'package:flutter/material.dart';

AppBarTheme buildAppBarTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
    actionsIconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
    titleTextStyle: textTheme.titleMedium,
  );
}
