part of '../ui_extension.dart';

class ThemeHelper {
  final BuildContext context;
  const ThemeHelper(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isLight => !isDark;

  ColorScheme get colors => Theme.of(context).colorScheme;
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
