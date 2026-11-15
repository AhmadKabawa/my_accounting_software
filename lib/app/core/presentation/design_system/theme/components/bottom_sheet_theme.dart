// components/bottom_sheet_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';

/// Bottom sheet: radius xl on the top corners, a surface, no tint.
BottomSheetThemeData buildBottomSheetTheme({required ColorScheme colorScheme}) {
  return BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: colorScheme.surface,
    modalBackgroundColor: colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl.mobile),
      ),
    ),
  );
}
