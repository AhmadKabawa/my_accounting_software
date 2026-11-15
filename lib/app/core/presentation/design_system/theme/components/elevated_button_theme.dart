// components/elevated_button_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_text_styles.dart';

ElevatedButtonThemeData buildElevatedButtonTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: AppElevation.none.mobile,
      foregroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      disabledForegroundColor: colorScheme.onSurface.withOpacity(0.4),
      disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
      minimumSize: Size(0, AppComponentSize.hitArea.mobile),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.mobile),
      textStyle: AppTextStyles.buttonText.baseline,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md.mobile),
      ),
    ),
  );
}
