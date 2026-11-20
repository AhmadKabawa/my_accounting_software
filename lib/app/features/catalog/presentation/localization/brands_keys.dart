import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum BrandsKeys implements AppKey {
  title(ar: 'الماركات', en: 'Brands'),
  add(ar: 'إضافة ماركة', en: 'Add brand'),
  edit(ar: 'تعديل الماركة', en: 'Edit brand'),
  name(ar: 'اسم الماركة', en: 'Brand name'),
  slug(ar: 'المعرّف المختصر', en: 'Slug'),
  logo(ar: 'رابط الشعار', en: 'Logo URL'),
  description(ar: 'الوصف', en: 'Description'),
  active(ar: 'فعّالة', en: 'Active'),
  inactive(ar: 'غير فعّالة', en: 'Inactive'),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  delete(ar: 'حذف', en: 'Delete'),
  searchHint(ar: 'ابحث باسم الماركة أو المعرّف', en: 'Search by brand or slug'),
  empty(ar: 'لا توجد ماركات بعد', en: 'No brands yet'),
  loadError(ar: 'تعذر تحميل الماركات', en: 'Could not load brands'),
  saveError(ar: 'تعذر حفظ الماركة. تحقق من الاتصال والصلاحيات ثم حاول مجدداً.', en: 'Could not save the brand. Check your connection and permissions, then try again.'),
  duplicateError(ar: 'اسم الماركة أو المعرّف المختصر مستخدم مسبقاً. اختر قيمة مختلفة.', en: 'The brand name or slug is already in use. Choose a different value.'),
  deleteError(ar: 'تعذر حذف الماركة. قد تكون مرتبطة بسجلات أخرى أو لا تملك الصلاحية.', en: 'Could not delete the brand. It may be referenced by other records or you may lack permission.'),
  slugRequired(ar: 'أدخل معرّفاً مختصراً باللغة الإنجليزية والأرقام.', en: 'Enter a slug using English letters and numbers.'),
  slugHelp(ar: 'المعرّف المختصر مطلوب. إذا كان الاسم عربياً، أدخل slug إنجليزياً يدوياً.', en: 'A slug is required. For an Arabic brand name, enter an English slug manually.'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  confirmDelete(ar: 'هل تريد حذف هذه الماركة؟', en: 'Delete this brand?'),
  status(ar: 'الحالة', en: 'Status');

  const BrandsKeys({required this.ar, required this.en});
  @override final String ar;
  @override final String en;
  @override String get key => 'brands.$name';
}
