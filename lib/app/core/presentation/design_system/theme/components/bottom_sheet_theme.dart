// components/bottom_sheet_theme.dart
import 'package:flutter/material.dart';

BottomSheetThemeData buildBottomSheetTheme({
  required ColorScheme colorScheme,
}) {
  return BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: colorScheme.surface,
    modalBackgroundColor: colorScheme.surface,
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
