import 'package:flutter/material.dart';

/// ==================== Theme Mode Extension ====================
/// إضافة وظائف مساعدة على ThemeMode

extension ThemeModeExtension on ThemeMode {
  /// الحصول على Icon للثيم
  IconData get icon {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// الحصول على اسم الثيم بالعربي
  String get nameAr {
    switch (this) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي';
    }
  }

  /// الحصول على اسم الثيم بالإنجليزي
  String get nameEn {
    switch (this) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

extension ThemeExtension on BuildContext {
  /// هل الوضع داكن؟
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// هل الوضع فاتح؟
  bool get isLight => Theme.of(this).brightness == Brightness.light;

  /// إرجاع لون حسب الثيم
  Color themeColor({required Color dark, required Color light}) {
    return isDark ? dark : light;
  }

  /// إرجاع أي قيمة حسب الثيم
  T themeValue<T>({required T dark, required T light}) {
    return isDark ? dark : light;
  }

  T? themeValueOrNull<T>({T? dark, T? light}) {
    if (dark != null && light != null) {
      return isDark ? dark : light;
    } else if (dark != null) {
      return isDark ? dark : null;
    } else if (light != null) {
      return isLight ? light : null;
    }
    return null;
  }

  /// اختصار للوصول إلى colorScheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// اختصار للوصول إلى textTheme
  TextTheme get textTheme => Theme.of(this).textTheme;
}
