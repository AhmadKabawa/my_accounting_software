import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/theme/app_text_styles.dart';

/// ======================================================
/// 📝 BUILD TEXT THEME
/// ======================================================
/// يربط بين TextStyles الخاصة بك وبين ColorScheme حتى يصبح النظام ديناميكي
/// (Light / Dark).
///
/// لا يحتاج BuildContext: [resolve] هي التي تحدد الحجم.
/// - بدونها: حجم الـ mobile الأساسي (يصلح عند بناء الثيم قبل MaterialApp).
/// - داخل الشجرة (ResponsiveTheme): `(style) => style.resolve(context)`
///   للحصول على الحجم المتجاوب.
TextTheme buildTextTheme({
  required ColorScheme colorScheme,
  TextStyle Function(AppTextStyle style)? resolve,
}) {
  TextStyle style(AppTextStyle token, Color color) =>
      (resolve?.call(token) ?? token.baseline).copyWith(color: color);

  final primary = colorScheme.onSurface;
  // الأقل أهمية يأخذ لوناً ثانوياً
  final secondary = colorScheme.onSurfaceVariant;

  return TextTheme(
    // 🔥 DISPLAY — Hero Section، عناوين رئيسية جداً، Landing Screen
    displayLarge: style(AppTextStyles.displayLarge, primary),
    displayMedium: style(AppTextStyles.displayMedium, primary),
    displaySmall: style(AppTextStyles.displaySmall, primary),

    // 📰 HEADLINE — عنوان Screen، عنوان قسم داخل الصفحة
    headlineLarge: style(AppTextStyles.headlineLarge, primary),
    headlineMedium: style(AppTextStyles.headlineMedium, primary),
    headlineSmall: style(AppTextStyles.headlineSmall, primary),

    // 🏷 TITLE — عناوين داخل Cards أو Sections
    titleLarge: style(AppTextStyles.titleLarge, primary),
    titleMedium: style(AppTextStyles.titleMedium, secondary),
    titleSmall: style(AppTextStyles.titleSmall, secondary),

    // 📄 BODY — النص الأساسي، نص وصف، نص صغير جداً
    bodyLarge: style(AppTextStyles.bodyLarge, primary),
    bodyMedium: style(AppTextStyles.bodyMedium, secondary),
    bodySmall: style(AppTextStyles.bodySmall, secondary),

    // 🔖 LABEL — نصوص الأزرار والـ Chips
    labelLarge: style(AppTextStyles.labelLarge, primary),
    labelMedium: style(AppTextStyles.labelMedium, secondary),
    labelSmall: style(AppTextStyles.labelSmall, secondary),
  );
}
