import 'package:flutter/material.dart';

/// ألوان التطبيق، وفق "Ledger Design System" (طبقتان):
///
/// 1. [AppColors]: السلالم الخام (`green-50…900` و`neutral-0…900`). لا تُستعمل
///    من الشاشات ولا من المكوّنات.
/// 2. [AppLightColors] و[AppDarkColors]: الأدوار (`primary`, `surface`,
///    `on-surface`…) بالأسماء نفسها. الفاتح يشير إلى السلالم، والداكن تصميم
///    مستقل بقيم صريحة (ليس قلباً آلياً للفاتح).
///
/// الوصول من الواجهات يكون عبر `context.ui.theme.colors` (ColorScheme) و
/// `context.ui.theme.semanticColors` فقط. الأدوار تُمرَّر إلى الثيم في
/// `light_theme.dart` و`dark_theme.dart` و`app_semantic_colors.dart`.
abstract final class AppColors {
  AppColors._();

  // ─── Brand: أخضر مائل للفيروزي ───
  static const Color green50 = Color(0xFFEEF8F2);
  static const Color green100 = Color(0xFFD6EEDF);
  static const Color green200 = Color(0xFFB0DCC3);
  static const Color green300 = Color(0xFF7EC3A1);
  static const Color green400 = Color(0xFF4AA57E);
  static const Color green500 = Color(0xFF2B8A64);
  static const Color green600 = Color(0xFF1F7352);
  static const Color green700 = Color(0xFF1A5C43);
  static const Color green800 = Color(0xFF164A37);
  static const Color green900 = Color(0xFF11392B);

  // ─── Neutrals: رماديات محايدة بميل أخضر خفيف ───
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF7F8F7);
  static const Color neutral100 = Color(0xFFF0F2F1);
  static const Color neutral200 = Color(0xFFE3E6E4);
  static const Color neutral300 = Color(0xFFD0D4D2);
  static const Color neutral400 = Color(0xFF8F9692);
  static const Color neutral500 = Color(0xFF6B726E);
  static const Color neutral600 = Color(0xFF4B524F);
  static const Color neutral700 = Color(0xFF3E4341);
  static const Color neutral800 = Color(0xFF262A28);
  static const Color neutral900 = Color(0xFF171A19);
}

/// أدوار الوضع الفاتح.
abstract final class AppLightColors {
  AppLightColors._();

  // ─── Roles ───
  static const Color primary = AppColors.green600;
  static const Color onPrimary = AppColors.neutral0;
  static const Color primaryHover = AppColors.green700;
  static const Color primaryContainer = AppColors.green100;
  static const Color onPrimaryContainer = AppColors.green900;
  static const Color secondary = AppColors.neutral700;
  static const Color onSecondary = AppColors.neutral0;
  static const Color secondaryContainer = AppColors.neutral200;
  static const Color onSecondaryContainer = AppColors.neutral900;

  /// خلفية الصفحة (Scaffold).
  static const Color background = AppColors.neutral50;

  /// البطاقات والجداول.
  static const Color surface = AppColors.neutral0;
  static const Color surfaceLow = AppColors.neutral50;
  static const Color surfaceContainer = AppColors.neutral100;
  static const Color surfaceHigh = Color(0xFFE8EBE9);
  static const Color surfaceHighest = AppColors.neutral200;
  static const Color onSurface = AppColors.neutral900;
  static const Color onSurfaceVariant = AppColors.neutral600;
  static const Color onSurfaceMuted = AppColors.neutral500;

  /// فواصل وحدود البطاقات (زخرفية).
  static const Color outline = AppColors.neutral200;
  static const Color outlineStrong = AppColors.neutral300;

  /// حدود الحقول والـ Controls (تباين 3:1).
  static const Color outlineControl = AppColors.neutral400;
  static const Color focusRing = AppColors.green500;
  static const Color scrim = Color(0x99171A19);

  /// ظل الطبقات العائمة (يُطبَّق بشفافية 8–16%).
  static const Color shadow = AppColors.neutral900;

  /// Snackbar.
  static const Color inverseSurface = AppColors.neutral800;
  static const Color onInverseSurface = AppColors.neutral0;
  static const Color inversePrimary = AppColors.green300;

  // ─── Semantic ───
  static const Color success = Color(0xFF3F7A1F);
  static const Color onSuccess = AppColors.neutral0;
  static const Color successContainer = Color(0xFFEEF6E8);
  static const Color warning = Color(0xFF8A5200);
  static const Color onWarning = AppColors.neutral0;
  static const Color warningContainer = Color(0xFFFFF3DC);
  static const Color error = Color(0xFFB3261E);
  static const Color onError = AppColors.neutral0;
  static const Color errorContainer = Color(0xFFFDECEA);
  static const Color info = Color(0xFF1A62B5);
  static const Color onInfo = AppColors.neutral0;
  static const Color infoContainer = Color(0xFFE7F0FB);

  // ─── Accounting: محايدة عمداً (لا أحمر/أخضر) ───
  static const Color debit = Color(0xFF2F3E4E);
  static const Color credit = Color(0xFF2F4A3F);
  static const Color balancePositive = AppColors.neutral900;
  static const Color balanceNegative = Color(0xFF9B3D1F);

  // ─── Document status (fg / bg) ───
  static const Color statusDraft = AppColors.neutral600;
  static const Color statusDraftContainer = Color(0xFFECEFED);
  static const Color statusApproved = info;
  static const Color statusApprovedContainer = infoContainer;
  static const Color statusPosted = Color(0xFF14563D);
  static const Color statusPostedContainer = Color(0xFFDDF1E7);
  static const Color statusCanceled = Color(0xFF5F6662);
  static const Color statusCanceledContainer = AppColors.neutral100;
  static const Color statusReversed = Color(0xFF5E4296);
  static const Color statusReversedContainer = Color(0xFFEFEAF8);

  // ─── Charts: 8 سلاسل (Okabe-Ito) آمنة لعمى الألوان ───
  static const List<Color> chart = [
    Color(0xFF0072B2),
    Color(0xFFB87500),
    Color(0xFF00855F),
    Color(0xFFB04C85),
    Color(0xFF3A93C9),
    Color(0xFFC24E12),
    Color(0xFF8A7E00),
    AppColors.neutral500,
  ];
}

/// أدوار الوضع الداكن: تصميم مستقل (رمادي منخفض التشبع بدرجات متقاربة).
abstract final class AppDarkColors {
  AppDarkColors._();

  // ─── Roles ───
  static const Color primary = Color(0xFF4FBF92);
  static const Color onPrimary = Color(0xFF0B2A1E);
  static const Color primaryHover = Color(0xFF6FD0A9);
  static const Color primaryContainer = Color(0xFF173B2C);
  static const Color onPrimaryContainer = Color(0xFFBFEBD6);
  static const Color secondary = Color(0xFFD4D4D4);
  static const Color onSecondary = Color(0xFF171717);
  static const Color secondaryContainer = Color(0xFF2A2A2A);
  static const Color onSecondaryContainer = Color(0xFFECECEC);
  static const Color background = Color(0xFF171717);
  static const Color surface = Color(0xFF1C1C1C);
  static const Color surfaceLow = Color(0xFF1C1C1C);
  static const Color surfaceContainer = Color(0xFF222222);
  static const Color surfaceHigh = Color(0xFF2A2A2A);
  static const Color surfaceHighest = Color(0xFF323232);
  static const Color onSurface = Color(0xFFECECEC);
  static const Color onSurfaceVariant = Color(0xFFA8A8A8);
  static const Color onSurfaceMuted = Color(0xFF8A8A8A);
  static const Color outline = Color(0xFF242424);
  static const Color outlineStrong = Color(0xFF2E2E2E);
  static const Color outlineControl = Color(0xFF6A6A6A);
  static const Color focusRing = Color(0xFF4FBF92);
  static const Color scrim = Color(0xB3000000);

  /// في الداكن يُستعاض عن الظل بدرجة سطح أفتح وحدّ؛ يبقى الظل للعناصر العائمة.
  static const Color shadow = Color(0xFF000000);

  /// Snackbar. القيم غير واردة في ملف التصميم للداكن؛ اشتُقت من on-surface
  /// وbackground لتبقى عالية التباين (15:1).
  static const Color inverseSurface = Color(0xFFECECEC);
  static const Color onInverseSurface = Color(0xFF171717);
  static const Color inversePrimary = Color(0xFF1F7352);

  // ─── Semantic ───
  static const Color success = Color(0xFF8FD16A);
  static const Color onSuccess = background;
  static const Color successContainer = Color(0xFF1F2B18);
  static const Color warning = Color(0xFFF2B13C);
  static const Color onWarning = background;
  static const Color warningContainer = Color(0xFF2E2410);
  static const Color error = Color(0xFFFF8F86);
  static const Color onError = onPrimary;
  static const Color errorContainer = Color(0xFF3A1D1B);
  static const Color info = Color(0xFF7DB8F5);
  static const Color onInfo = background;
  static const Color infoContainer = Color(0xFF162536);

  // ─── Accounting ───
  static const Color debit = Color(0xFFB9C7D6);
  static const Color credit = Color(0xFFB7D2C4);
  static const Color balancePositive = Color(0xFFECECEC);
  static const Color balanceNegative = Color(0xFFF0A27E);

  // ─── Document status (fg / bg) ───
  static const Color statusDraft = Color(0xFFB5B5B5);
  static const Color statusDraftContainer = Color(0xFF2A2A2A);
  static const Color statusApproved = Color(0xFF7DB8F5);
  static const Color statusApprovedContainer = Color(0xFF162536);
  static const Color statusPosted = Color(0xFF8FDDBA);
  static const Color statusPostedContainer = Color(0xFF173B2C);
  static const Color statusCanceled = Color(0xFF8A8A8A);
  static const Color statusCanceledContainer = Color(0xFF222222);
  static const Color statusReversed = Color(0xFFBDA8F0);
  static const Color statusReversedContainer = Color(0xFF2B2342);

  // ─── Charts ───
  static const List<Color> chart = [
    Color(0xFF56B4E9),
    Color(0xFFF5B83D),
    Color(0xFF2FBF94),
    Color(0xFFE08FBD),
    Color(0xFF8FD0F2),
    Color(0xFFF0824A),
    Color(0xFFE8DC4A),
    Color(0xFFA8A8A8),
  ];
}
