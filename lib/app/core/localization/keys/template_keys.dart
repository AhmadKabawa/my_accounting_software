import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum TemplateKeys implements AppKey {
  unsavedChanges(
    ar: 'لديك تغييرات غير محفوظة. هل تريد المغادرة؟',
    en: 'You have unsaved changes. Leave this page?',
  ),
  save(ar: 'حفظ', en: 'Save'),
  defaultError(
    ar: 'حدث خطأ أثناء تحميل المحتوى',
    en: 'Something went wrong while loading this content',
  ),
  emptyTitle(ar: 'لا توجد بيانات', en: 'Nothing here yet'),
  emptyDescription(
    ar: 'لا يوجد محتوى لعرضه حالياً',
    en: 'There is no content to display yet',
  );

  const TemplateKeys({required this.ar, required this.en});

  @override
  final String ar;

  @override
  final String en;

  @override
  String get key => 'template.$name';
}
