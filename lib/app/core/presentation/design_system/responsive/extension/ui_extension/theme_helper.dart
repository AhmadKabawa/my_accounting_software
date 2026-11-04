part of '../ui_extension.dart';

class ThemeHelper {
  final BuildContext context;
  const ThemeHelper(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isLight => !isDark;

  /// ألوان [ColorScheme] القياسية فقط (primary, surface, error ...).
  ColorScheme get colors => Theme.of(context).colorScheme;

  /// الألوان الدلالية الخاصة (success, warning, info, debit, credit).
  /// تُقرأ من [AppSemanticColors] المسجّلة في الثيم؛ وإن غابت (ثيم لم يُبنَ
  /// عبر `AppTheme`) يُستخدم الافتراضي الموافق للوضع الحالي.
  AppSemanticColors get semanticColors =>
      Theme.of(context).extension<AppSemanticColors>() ??
      (isDark ? AppSemanticColors.dark : AppSemanticColors.light);
  TextTheme get textTheme => Theme.of(context).textTheme;

  T value<T>({required T dark, required T light}) {
    return isDark ? dark : light;
  }

  T? valueOrNull<T>({T? dark, T? light}) {
    if (dark != null && light != null) {
      return isDark ? dark : light;
    } else if (dark != null) {
      return isDark ? dark : null;
    } else if (light != null) {
      return isLight ? light : null;
    }
    return null;
  }
}
