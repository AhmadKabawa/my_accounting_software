import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `theme` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum ThemeKeys implements AppKey {
  light(ar: 'فاتح', en: 'Light'),
  dark(ar: 'داكن', en: 'Dark'),
  system(ar: 'تلقائي (حسب النظام)', en: 'System');

  const ThemeKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'theme.$name';
}
