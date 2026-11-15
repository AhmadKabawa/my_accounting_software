// components/outlined_button_theme.dart
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_text_styles.dart';

OutlinedButtonThemeData buildOutlinedButtonTheme({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
}) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: colorScheme.onSurface,
      side: BorderSide(
        color: colorScheme.outline,
        width: AppBorderWidth.thin.mobile,
      ),
      textStyle: AppTextStyles.buttonText.baseline,
      minimumSize: Size(0, AppComponentSize.hitArea.mobile),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.mobile),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md.mobile),
      ),
    ),
  );
}
