import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/app_colors.dart';

/// ===============================
/// 🌞 LIGHT COLOR SCHEME
/// ===============================
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: AppColors.brand,
  brightness: Brightness.light,
).copyWith(
  // ======================================================
  // 🎯 PRIMARY (اللون الأساسي الرئيسي للتطبيق)
  // ======================================================
  primary: AppColors.brand,

  // يستخدم في: AppBar - ElevatedButton - FAB - العناصر التفاعلية المهمة
  onPrimary: AppColors.white,

  // primaryContainer / onPrimaryContainer / surfaceTint / inversePrimary
  // تُولَّد تلقائياً من AppColors.brand عبر ColorScheme.fromSeed (تباين متناسق).

  // ======================================================
  // 🎯 SECONDARY (لون مساعد أقل أهمية من الأساسي)
  // ======================================================
  secondary: AppColors.secondary,

  // يستخدم في: Filter chips - عناصر ثانوية - Highlights خفيفة
  onSecondary: AppColors.white,

  // نص فوق secondary
  secondaryContainer: AppColors.secondaryLight,

  // خلفية عناصر ثانوية مميزة
  onSecondaryContainer: AppColors.secondaryDark,
  // نص داخل secondaryContainer

  // ======================================================
  // 🎯 TERTIARY (Accent / لون إبراز إضافي)
  // ======================================================
  tertiary: AppColors.accent,

  // يستخدم في: Badges - عناصر مميزة - CTA إضافي
  onTertiary: AppColors.black,

  // نص فوق tertiary
  tertiaryContainer: AppColors.accentLight,

  // خلفية إبراز خفيفة
  onTertiaryContainer: AppColors.accentDark,
  // نص داخلها

  // ======================================================
  // ❌ ERROR (ألوان الأخطاء)
  // ======================================================
  error: AppColors.error,

  // لون زر خطأ - نص خطأ - أيقونة خطأ
  onError: AppColors.white,

  // نص فوق زر خطأ
  errorContainer: AppColors.errorLight,

  // خلفية رسالة خطأ (مثلاً Alert)
  onErrorContainer: AppColors.errorDark,
  // نص داخل خلفية الخطأ

  // ======================================================
  // 🧱 SURFACE (الخلفيات الأساسية)
  // ======================================================
  surface: AppColors.backgroundLight,

  // خلفية Scaffold - الشاشة الرئيسية
  onSurface: AppColors.textPrimary,
  // النص الأساسي في التطبيق

  // ======================================================
  // 📦 SURFACE VARIANT (Container فوق الخلفية)
  // ======================================================
  surfaceVariant: AppColors.cardLight,

  // Card - TextField - Containers خفيفة
  onSurfaceVariant: AppColors.textSecondary,
  // نص ثانوي داخل الكروت

  // ======================================================
  // 🪜 SURFACE CONTAINER LEVELS (Elevation بدون Shadow)
  // ======================================================
  surfaceContainerLow: AppColors.surfaceContainerLowLight,

  // Card بسيط جدًا
  surfaceContainer: AppColors.surfaceContainerLight,

  // Card عادي
  surfaceContainerHigh: AppColors.surfaceContainerHighLight,

  // Dialog - BottomSheet متوسط
  surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
  // أعلى مستوى ارتفاع

  // ======================================================
  // 🧩 OUTLINE (الحدود)
  // ======================================================
  outline: AppColors.border,

  // Border TextField - OutlinedButton
  outlineVariant: AppColors.borderLight,
  // Divider - حدود خفيفة جدًا

  // ======================================================
  // 🌫️ SHADOW & OVERLAY
  // ======================================================
  shadow: AppColors.shadow,

  // لون الظلال
  scrim: AppColors.overlay,

  // خلفية معتمة خلف Dialog

  // ======================================================
  // 🔄 INVERSE (يستخدم في SnackBar غالبًا)
  // ======================================================
  inverseSurface: AppColors.surfaceDark,

  // خلفية SnackBar في الوضع الفاتح
  onInverseSurface: AppColors.textPrimaryDark,

  // نص SnackBar
);
