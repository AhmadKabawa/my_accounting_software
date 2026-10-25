import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/app_text_styles.dart';

/// ======================================================
/// 📝 BUILD TEXT THEME
/// ======================================================
/// هذا الملف يربط بين TextStyles الخاصة بك وبين
/// ColorScheme حتى يصبح النظام ديناميكي (Light / Dark)
TextTheme buildTextTheme({
  required BuildContext context,
  required ColorScheme colorScheme,
}) {
  return TextTheme(
    // ======================================================
    // 🔥 DISPLAY (أكبر مستوى نص في التطبيق)
    // يستخدم في:
    // - Hero Section
    // - عناوين رئيسية جدًا
    // - Landing Screen
    // ======================================================
    displayLarge: AppTextStyles.displayLarge(
      context,
    ).copyWith(color: colorScheme.onSurface),

    displayMedium: AppTextStyles.displayMedium(
      context,
    ).copyWith(color: colorScheme.onSurface),

    displaySmall: AppTextStyles.displaySmall(
      context,
    ).copyWith(color: colorScheme.onSurface),

    // ======================================================
    // 📰 HEADLINE (عناوين الصفحات)
    // يستخدم في:
    // - عنوان Screen
    // - عنوان قسم داخل الصفحة
    // ======================================================
    headlineLarge: AppTextStyles.headlineLarge(
      context,
    ).copyWith(color: colorScheme.onSurface),

    headlineMedium: AppTextStyles.headlineMedium(
      context,
    ).copyWith(color: colorScheme.onSurface),

    headlineSmall: AppTextStyles.headlineSmall(
      context,
    ).copyWith(color: colorScheme.onSurface),

    // ======================================================
    // 🏷 TITLE (عناوين داخل Cards أو Sections)
    // ======================================================
    titleLarge: AppTextStyles.titleLarge(
      context,
    ).copyWith(color: colorScheme.onSurface),

    // أقل أهمية من Large لذلك نعطيه لون ثانوي
    titleMedium: AppTextStyles.titleMedium(
      context,
    ).copyWith(color: colorScheme.onSurfaceVariant),

    titleSmall: AppTextStyles.titleSmall(
      context,
    ).copyWith(color: colorScheme.onSurfaceVariant),

    // ======================================================
    // 📄 BODY (النصوص العادية)
    // ======================================================

    // النص الأساسي
    bodyLarge: AppTextStyles.bodyLarge(
      context,
    ).copyWith(color: colorScheme.onSurface),

    // نص وصف
    bodyMedium: AppTextStyles.bodyMedium(
      context,
    ).copyWith(color: colorScheme.onSurfaceVariant),

    // نص صغير جدًا
    bodySmall: AppTextStyles.bodySmall(
      context,
    ).copyWith(color: colorScheme.onSurfaceVariant),

    // ======================================================
    // 🔖 LABEL (نصوص الأزرار والـ Chips)
    // ======================================================
    labelLarge: AppTextStyles.labelLarge(
      context,
    ).copyWith(color: colorScheme.onSurface),

    labelMedium: AppTextStyles.labelMedium(
      context,
    ).copyWith(color: colorScheme.onSurfaceVariant),

    labelSmall: AppTextStyles.labelSmall(
      context,
    ).copyWith(color: colorScheme.onSurfaceVariant),
  );
}
