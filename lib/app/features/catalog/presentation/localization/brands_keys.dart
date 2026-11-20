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
  saveError(ar: 'تعذر حفظ الماركة', en: 'Could not save brand'),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  confirmDelete(ar: 'هل تريد حذف هذه الماركة؟', en: 'Delete this brand?'),
  status(ar: 'الحالة', en: 'Status');

  const BrandsKeys({required this.ar, required this.en});
  @override final String ar;
  @override final String en;
  @override String get key => 'brands.$name';
}
