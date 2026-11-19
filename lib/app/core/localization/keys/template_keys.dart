import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum TemplateKeys implements AppKey {
  unsavedChanges(ar: 'لديك تغييرات غير محفوظة. هل تريد المغادرة؟', en: 'You have unsaved changes. Leave this page?'),
  save(ar: 'حفظ', en: 'Save');

  const TemplateKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'template.$name';
}
