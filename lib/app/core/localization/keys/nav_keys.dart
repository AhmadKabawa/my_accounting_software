import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// Texts of the `nav` section: one entry = key + Arabic + English.
///
/// Add a text by adding one entry; the key is `<prefix>.<name>` (derived),
/// so it cannot be mistyped or duplicated inside the section.
enum NavKeys implements AppKey {
  home(ar: 'الرئيسية', en: 'home'),
  chat(ar: 'محادثة', en: 'chat'),
  favorite(ar: 'مفضل', en: 'favorite'),
  person(ar: 'ملف شخصي', en: 'person');

  const NavKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'nav.$name';
}
