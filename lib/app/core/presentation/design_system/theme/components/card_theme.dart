import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

/// Border first: a thin outline on a surface, no shadow (shadows are for
/// floating layers only).
CardThemeData buildCardTheme({required ColorScheme colorScheme}) {
  return CardThemeData(
    color: colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    elevation: AppElevation.none.mobile,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg.mobile),
      side: BorderSide(
        color: colorScheme.outlineVariant,
        width: AppBorderWidth.thin.mobile,
      ),
    ),
    margin: EdgeInsets.zero,
  );
}
