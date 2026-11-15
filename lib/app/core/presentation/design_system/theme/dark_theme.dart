import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/design_system/theme/app_colors.dart';

/// الوضع الداكن: تصميم مستقل بالأسماء نفسها (انظر [AppDarkColors])، وليس
/// قلباً آلياً للفاتح. خريطة الأدوار مطابقة لـ `light_theme.dart`.
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppDarkColors.primary,
  onPrimary: AppDarkColors.onPrimary,
  primaryContainer: AppDarkColors.primaryContainer,
  onPrimaryContainer: AppDarkColors.onPrimaryContainer,
  secondary: AppDarkColors.secondary,
  onSecondary: AppDarkColors.onSecondary,
  secondaryContainer: AppDarkColors.secondaryContainer,
  onSecondaryContainer: AppDarkColors.onSecondaryContainer,
  error: AppDarkColors.error,
  onError: AppDarkColors.onError,
  errorContainer: AppDarkColors.errorContainer,
  onErrorContainer: AppDarkColors.error,
  surface: AppDarkColors.surface,
  onSurface: AppDarkColors.onSurface,
  onSurfaceVariant: AppDarkColors.onSurfaceVariant,
  surfaceContainerLowest: AppDarkColors.surface,
  surfaceContainerLow: AppDarkColors.surfaceLow,
  surfaceContainer: AppDarkColors.surfaceContainer,
  surfaceContainerHigh: AppDarkColors.surfaceHigh,
  surfaceContainerHighest: AppDarkColors.surfaceHighest,
  outline: AppDarkColors.outlineControl,
  outlineVariant: AppDarkColors.outline,
  shadow: AppDarkColors.shadow,
  scrim: AppDarkColors.scrim,
  surfaceTint: Colors.transparent,
  inverseSurface: AppDarkColors.inverseSurface,
  onInverseSurface: AppDarkColors.onInverseSurface,
  inversePrimary: AppDarkColors.inversePrimary,
);
