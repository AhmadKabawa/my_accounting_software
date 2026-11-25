import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum TemplateKeys implements AppKey {
  unsavedChanges(
    ar: 'لديك تغييرات غير محفوظة. إذا غادرت الآن فستفقدها.',
    en: 'You have unsaved changes. If you leave now, they will be lost.',
  ),
  leaveWithoutSaving(ar: 'مغادرة دون حفظ', en: 'Leave without saving'),
  clearContent(ar: 'مسح المحتوى', en: 'Clear content'),
  reset(ar: 'إعادة تعيين', en: 'Reset'),
  clearFormConfirmation(
    ar: 'هل تريد مسح القيم المدخلة وإعادتها إلى الحالة الابتدائية؟',
    en: 'Clear the entered values and restore the initial form values?',
  ),
  resetFormConfirmation(
    ar: 'هل تريد إعادة الحقول إلى البيانات الأصلية التي فُتح عليها النموذج؟',
    en: 'Restore all fields to the original values from when this form was opened?',
  ),
  save(ar: 'حفظ', en: 'Save'),
  retry(ar: 'إعادة المحاولة', en: 'Retry'),
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
