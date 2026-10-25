import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/app_colors.dart';

/// ===============================
/// 🌙 DARK COLOR SCHEME
/// ===============================
final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark, // يحدد أن النظام داكن
  // ======================================================
  // 🎯 PRIMARY
  // ======================================================
  primary: AppColors.primaryDark,

  // اللون الأساسي في الداكن (أفتح ليظهر فوق الخلفية الداكنة)
  onPrimary: AppColors.black,

  // نص فوق primary
  primaryContainer: AppColors.primaryDark,

  // خلفية زر مختار
  onPrimaryContainer: AppColors.primaryLight,
  // نص داخله

  // ======================================================
  // 🎯 SECONDARY
  // ======================================================
  secondary: AppColors.secondaryLight,

  // لون مساعد في الداكن
  onSecondary: AppColors.black,

  secondaryContainer: AppColors.secondaryDark,

  // خلفية عناصر ثانوية
  onSecondaryContainer: AppColors.secondaryLight,

  // ======================================================
  // 🎯 TERTIARY
  // ======================================================
  tertiary: AppColors.accentLight,

  // لون إبراز في الداكن
  onTertiary: AppColors.black,

  tertiaryContainer: AppColors.accentDark,

  // خلفية إبراز
  onTertiaryContainer: AppColors.accentLight,

  // ======================================================
  // ❌ ERROR
  // ======================================================
  error: AppColors.errorDark,

  // لون خطأ في الداكن
  onError: AppColors.white,

  errorContainer: AppColors.errorDark,

  // خلفية رسالة خطأ
  onErrorContainer: AppColors.white,

  // ======================================================
  // 🧱 SURFACE
  // ======================================================
  surface: AppColors.surfaceDark,

  // خلفية التطبيق
  onSurface: AppColors.textPrimaryDark,
  // النص الأساسي

  // ======================================================
  // 📦 SURFACE VARIANT
  // ======================================================
  surfaceVariant: AppColors.cardDark,

  // Card في الداكن
  onSurfaceVariant: AppColors.textSecondaryDark,
  // نص ثانوي

  // ======================================================
  // 🪜 SURFACE CONTAINER LEVELS
  // ======================================================
  surfaceContainerLow: AppColors.surfaceContainerLowDark,

  // Card منخفض
  surfaceContainer: AppColors.surfaceContainerDark,

  // Card عادي
  surfaceContainerHigh: AppColors.surfaceContainerHighDark,

  // Dialog
  surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
  // أعلى elevation

  // ======================================================
  // 🧩 OUTLINE
  // ======================================================
  outline: AppColors.borderDark,

  // حدود
  outlineVariant: AppColors.borderDark,
  // Divider

  // ======================================================
  // 🌫️ SHADOW
  // ======================================================
  shadow: AppColors.shadow,
  scrim: AppColors.overlay,
  surfaceTint: AppColors.primaryLight,

  // ======================================================
  // 🔄 INVERSE
  // ======================================================
  inverseSurface: AppColors.surfaceLight,

  // خلفية SnackBar في الداكن
  onInverseSurface: AppColors.textPrimary,
  inversePrimary: AppColors.primary,
);
