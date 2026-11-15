import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_colors.dart';

/// الوضع الفاتح: أدوار Ledger Design System مربوطة بـ [ColorScheme].
///
/// - `surface` = البطاقات والجداول (أبيض). خلفية الصفحة هي
///   [AppLightColors.background] وتُمرَّر إلى `buildTheme` كـ scaffold.
/// - `outline` = حدود الحقول والـ Controls (outline-control، تباين 3:1).
/// - `outlineVariant` = حدود البطاقات والفواصل (outline).
/// - لا يوجد لون tertiary: العلامة لون واحد (الأخضر) + محايدات.
/// - الأدوار التي لا تملك خانة في [ColorScheme] (onSurfaceMuted,
///   outlineStrong, focusRing...) في `AppSemanticColors`.
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppLightColors.primary,
  onPrimary: AppLightColors.onPrimary,
  primaryContainer: AppLightColors.primaryContainer,
  onPrimaryContainer: AppLightColors.onPrimaryContainer,
  secondary: AppLightColors.secondary,
  onSecondary: AppLightColors.onSecondary,
  secondaryContainer: AppLightColors.secondaryContainer,
  onSecondaryContainer: AppLightColors.onSecondaryContainer,
  error: AppLightColors.error,
  onError: AppLightColors.onError,
  errorContainer: AppLightColors.errorContainer,
  onErrorContainer: AppLightColors.error,
  surface: AppLightColors.surface,
  onSurface: AppLightColors.onSurface,
  onSurfaceVariant: AppLightColors.onSurfaceVariant,
  surfaceContainerLowest: AppLightColors.surface,
  surfaceContainerLow: AppLightColors.surfaceLow,
  surfaceContainer: AppLightColors.surfaceContainer,
  surfaceContainerHigh: AppLightColors.surfaceHigh,
  surfaceContainerHighest: AppLightColors.surfaceHighest,
  outline: AppLightColors.outlineControl,
  outlineVariant: AppLightColors.outline,
  shadow: AppLightColors.shadow,
  scrim: AppLightColors.scrim,
  // لا tint فوق الأسطح: العمق بالحدود لا بالظلال.
  surfaceTint: Colors.transparent,
  inverseSurface: AppLightColors.inverseSurface,
  onInverseSurface: AppLightColors.onInverseSurface,
  inversePrimary: AppLightColors.inversePrimary,
);
