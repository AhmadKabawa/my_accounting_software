import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_text_styles.dart';

/// Builds the [TextTheme] from the [AppTextStyles] baseline (mobile) sizes and
/// the [ColorScheme], so the theme works in Light / Dark without a
/// BuildContext. Responsive sizes are resolved per widget (see `AppText`).
TextTheme buildTextTheme({required ColorScheme colorScheme}) {
  TextStyle style(AppTextStyle textStyle, Color color) =>
      textStyle.baseline.copyWith(color: color);

  return TextTheme(
    // DISPLAY — hero sections, landing screens
    displayLarge: style(AppTextStyles.displayLarge, colorScheme.onSurface),
    displayMedium: style(AppTextStyles.displayMedium, colorScheme.onSurface),
    displaySmall: style(AppTextStyles.displaySmall, colorScheme.onSurface),

    // HEADLINE — screen and section titles
    headlineLarge: style(AppTextStyles.headlineLarge, colorScheme.onSurface),
    headlineMedium: style(AppTextStyles.headlineMedium, colorScheme.onSurface),
    headlineSmall: style(AppTextStyles.headlineSmall, colorScheme.onSurface),

    // TITLE — card / section titles (less important ones use a secondary color)
    titleLarge: style(AppTextStyles.titleLarge, colorScheme.onSurface),
    titleMedium: style(
      AppTextStyles.titleMedium,
      colorScheme.onSurfaceVariant,
    ),
    titleSmall: style(AppTextStyles.titleSmall, colorScheme.onSurfaceVariant),

    // BODY — regular text
    bodyLarge: style(AppTextStyles.bodyLarge, colorScheme.onSurface),
    bodyMedium: style(AppTextStyles.bodyMedium, colorScheme.onSurfaceVariant),
    bodySmall: style(AppTextStyles.bodySmall, colorScheme.onSurfaceVariant),

    // LABEL — buttons and chips
    labelLarge: style(AppTextStyles.labelLarge, colorScheme.onSurface),
    labelMedium: style(
      AppTextStyles.labelMedium,
      colorScheme.onSurfaceVariant,
    ),
    labelSmall: style(AppTextStyles.labelSmall, colorScheme.onSurfaceVariant),
  );
}
