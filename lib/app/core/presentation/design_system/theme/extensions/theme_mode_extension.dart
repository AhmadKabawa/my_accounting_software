import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/translations/app_keys.dart';

/// وظائف عرض مساعدة على [ThemeMode] (أيقونة واسم مترجم).
extension ThemeModeExtension on ThemeMode {
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

  /// مفتاح ترجمة اسم الوضع؛ اعرضه عبر `AppText` أو `.tran`.
  AppKey get nameKey {
    switch (this) {
      case ThemeMode.light:
        return AppKeys.theme.light;
      case ThemeMode.dark:
        return AppKeys.theme.dark;
      case ThemeMode.system:
        return AppKeys.theme.system;
    }
  }
}
