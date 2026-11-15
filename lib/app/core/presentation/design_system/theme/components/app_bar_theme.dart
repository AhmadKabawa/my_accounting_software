// components/appbar_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

AppBarTheme buildAppBarTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  final iconSize = AppIconSize.lg.mobile;
  return AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: colorScheme.onSurface, size: iconSize),
    actionsIconTheme: IconThemeData(
      color: colorScheme.onSurface,
      size: iconSize,
    ),
    titleTextStyle: textTheme.titleMedium,
  );
}
