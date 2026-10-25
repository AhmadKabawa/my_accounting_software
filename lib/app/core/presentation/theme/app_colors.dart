import 'package:flutter/material.dart';

/// ملف يحتوي على جميع ألوان التطبيق
/// الألوان الأساسية مأخوذة من النسخة الأولى
/// التنظيم والهيكل مأخوذ من النسخة الثانية
class AppColors {
  AppColors._();

  /* ==================== 🎨 PRIMARY COLORS (الأزرق الأساسي) ==================== */
  /// اللون الأساسي للتطبيق - من النسخة الأولى (#4b68ff)
  static const Color primary = Color(0xFF4b68ff);

  /// نسخة فاتحة من الأساسي (مشتق من accent في النسخة الأولى)
  static const Color primaryLight = Color(0xFF277359);

  /// نسخة غامقة من الأساسي
  static const Color primaryDark = Color(0xFF5BCFA0);

  /// اللون الذي يظهر فوق الأساسي (نص، أيقونات)
  static const Color onPrimary = white;

  /* ==================== 🟡 SECONDARY COLORS (الأصفر الثانوي) ==================== */
  /// اللون الثانوي - من النسخة الأولى (#FFE24B)
  static const Color secondary = Color(0xFFFFE24B);

  /// نسخة فاتحة من الثانوي
  static const Color secondaryLight = Color(0xFFFFF0A3);

  /// نسخة غامقة من الثانوي
  static const Color secondaryDark = Color(0xFFE6CA29);

  /// اللون الذي يظهر فوق الثانوي
  static const Color onSecondary = black;

  /* ==================== 🟠 ACCENT COLORS (البرتقالي) ==================== */
  /// اللون التمييزي - من النسخة الثانية للتنوع
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8C61);
  static const Color accentDark = Color(0xFFE85A2B);
  static const Color onAccent = white;

  /* ==================== ✅ STATUS COLORS (من النسخة الأولى) ==================== */
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);

  /// ألوان الحالة مع تحسينات للوضع الغامق
  static const Color successDark = Color(0xFF4CAF50);
  static const Color warningDark = Color(0xFFFFC107);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color infoDark = Color(0xFF2196F3);

  /* ==================== ⚫ NEUTRAL COLORS (من النسخة الأولى) ==================== */
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF232323); // أسود رمادي
  /* ==================== ❌ ERROR LIGHT ==================== */

  /// خلفية تنبيه خطأ في الوضع الفاتح
  static const Color errorLight = Color(0xFFFEE2E2);

  /* ==================== 📦 CARD LIGHT ==================== */

  /// لون Card في الوضع الفاتح (فرق بسيط عن الأبيض)
  static const Color cardLight = Color(0xFFF8FAFC);

  /* ==================== 🚧 BORDER LIGHT ==================== */

  /// حدود خفيفة جدًا للوضع الفاتح
  static const Color borderLight = Color(0xFFE5E7EB);

  /* ==================== 🌞 SURFACE CONTAINER LEVELS (LIGHT) ==================== */

  /// أقل مستوى فوق الخلفية
  static const Color surfaceContainerLowLight = Color(0xFFFAFAFA);

  /// Card عادي
  static const Color surfaceContainerLight = Color(0xFFF5F5F5);

  /// Card مرتفع / Dialog
  static const Color surfaceContainerHighLight = Color(0xFFEEEEEE);

  /// أعلى مستوى
  static const Color surfaceContainerHighestLight = Color(0xFFE5E7EB);

  /* ==================== 🌙 SURFACE CONTAINER LEVELS (DARK) ==================== */

  /// أقل مستوى فوق الخلفية الداكنة
  static const Color surfaceContainerLowDark = Color(0xFF273549);

  /// Card عادي في الداكن
  static const Color surfaceContainerDark = Color(0xFF2F3E55);

  /// Card مرتفع
  static const Color surfaceContainerHighDark = Color.fromARGB(255, 39, 51, 68);

  /// أعلى مستوى
  static const Color surfaceContainerHighestDark = Color(0xFF41546E);

  /// تدرجات الرمادي من النسخة الأولى
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);

  /* ==================== 📝 TEXT COLORS (من النسخة الأولى) ==================== */
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = white;

  /// ألوان النص للوضع الغامق (من النسخة الثانية)
  static const Color textPrimaryDark = Color(0xFFE5E7EB);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  /* ==================== 🎭 BACKGROUND COLORS (من النسخة الأولى) ==================== */
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  /// خلفيات إضافية من النسخة الثانية
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF0F172A);

  /* ==================== 📦 CONTAINER COLORS (من النسخة الأولى) ==================== */
  static const Color lightContainer = Color(0xFFF6F6F6);
  static const Color darkContainer = Color(0x1AFFFFFF);

  /// حاويات إضافية من النسخة الثانية
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);

  /* ==================== 🎛️ BUTTON COLORS (من النسخة الأولى) ==================== */
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  /* ==================== 🚧 BORDER COLORS (من النسخة الأولى) ==================== */
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  /// حدود إضافية من النسخة الثانية
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF475569);
  static const Color divider = Color(0xFFE5E7EB);

  /* ==================== 🔘 INPUT COLORS (من النسخة الثانية) ==================== */
  static const Color inputBackground = Color(0xFFF1F5F9);
  static const Color disabled = Color(0xFFCBD5E1);

  /* ==================== 🌫️ GLASSMORPHISM (من النسخة الثانية) ==================== */
  static final Color glassLight = white.withOpacity(0.1);
  static final Color glassDark = surfaceDark.withOpacity(0.3);
  static final Color glassBlur = white.withOpacity(0.05);

  /* ==================== 🏷️ CATEGORY COLORS (من النسخة الثانية) ==================== */
  static const Color categoryShoes = secondary;
  static const Color categoryClothes = primary;
  static const Color categoryEquipment = accent;

  /* ==================== ✨ GRADIENTS (من النسخة الثانية) ==================== */
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [dark, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /* ==================== 🎯 SHADOWS & OVERLAYS (من النسخة الثانية) ==================== */
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  /* ==================== 🛠️ HELPER METHODS ==================== */
}
