import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum AgeGroupsKeys implements AppKey {
  title(ar: 'الفئات العمرية', en: 'Age groups'),
  add(ar: 'إضافة فئة عمرية', en: 'Add age group'),
  edit(ar: 'تعديل الفئة العمرية', en: 'Edit age group'),
  name(ar: 'الاسم', en: 'Name'),
  minAge(ar: 'أقل عمر', en: 'Minimum age'),
  maxAge(ar: 'أعلى عمر', en: 'Maximum age'),
  sortOrder(ar: 'ترتيب الظهور', en: 'Display order'),
  status(ar: 'الحالة', en: 'Status'),
  active(ar: 'فعّال', en: 'Active'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(ar: 'ابحث باسم الفئة العمرية', en: 'Search age groups by name'),
  empty(ar: 'لا توجد فئات عمرية', en: 'No age groups yet'),
  emptyDescription(
    ar: 'أضف أول فئة عمرية لتنظيم المنتجات حسب العمر.',
    en: 'Add the first age group to organize products by age.',
  ),
  noResults(ar: 'لا توجد نتائج مطابقة', en: 'No matching results'),
  noResultsDescription(
    ar: 'جرّب تغيير البحث أو الفلاتر.',
    en: 'Try changing the search or filters.',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'Required'),
  nameTooLong(
    ar: 'الاسم يجب ألا يتجاوز 100 حرف',
    en: 'Name must be 100 characters or fewer',
  ),
  invalidInteger(
    ar: 'أدخل عدداً صحيحاً غير سالب',
    en: 'Enter a non-negative whole number',
  ),
  invalidRange(
    ar: 'الحد الأدنى للعمر يجب ألا يتجاوز الحد الأعلى',
    en: 'Minimum age must not exceed maximum age',
  ),
  duplicateError(
    ar: 'اسم الفئة العمرية مستخدم مسبقاً',
    en: 'An age group with this name already exists',
  ),
  inUse(
    ar: 'لا يمكن حذف الفئة العمرية لارتباطها بمنتجات. أوقفها بدلاً من ذلك.',
    en: 'This age group is assigned to products. Deactivate it instead.',
  ),
  usageUnknown(
    ar: 'تعذر التحقق من استخدام الفئة العمرية؛ تم منع الحذف حفاظاً على البيانات.',
    en: 'Age group usage could not be verified; deletion was blocked to protect data.',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  saved(ar: 'تم حفظ الفئة العمرية', en: 'Age group saved'),
  deleted(ar: 'تم حذف الفئة العمرية', en: 'Age group deleted'),
  delete(ar: 'حذف', en: 'Delete'),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  deleteTitle(ar: 'حذف الفئة العمرية', en: 'Delete age group'),
  deleteMessage(
    ar: 'هل تريد حذف الفئة العمرية {name}؟',
    en: 'Delete age group {name}?',
  ),
  deactivateTitle(ar: 'إيقاف الفئة العمرية', en: 'Deactivate age group'),
  deactivateMessage(
    ar: 'سيتم الاحتفاظ بالسجل وإيقافه',
    en: 'This record will be retained and deactivated',
  ),
  statusUpdated(ar: 'تم تحديث الحالة', en: 'Status updated');

  const AgeGroupsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'agegroups.${toString().split('.').last}';
}
