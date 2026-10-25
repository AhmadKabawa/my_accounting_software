import 'dart:ui';

enum AppLanguage {
  ar('ar'),
  en('en');

  final String code;

  const AppLanguage(this.code);

  Locale get locale => Locale(code);
  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppLanguage.ar,
    );
  }
}
