import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum OptionSetsKeys implements AppKey {
  title(ar: 'مجموعات الخيارات', en: 'Option Sets'),
  add(ar: 'إضافة مجموعة', en: 'Add option set'),
  edit(ar: 'تعديل المجموعة', en: 'Edit option set'),
  optionSetName(ar: 'اسم المجموعة', en: 'Set name'),
  code(ar: 'الرمز', en: 'Code'),
  selectionType(ar: 'طريقة الاختيار', en: 'Selection type'),
  single(ar: 'اختيار واحد', en: 'Single'),
  multiple(ar: 'اختيارات متعددة', en: 'Multiple'),
  option(ar: 'الخيار', en: 'Option'),
  addOption(ar: 'إضافة خيار', en: 'Add option'),
  sortOrder(ar: 'ترتيب العرض', en: 'Display order'),
  active(ar: 'فعّالة', en: 'Active'),
  inactive(ar: 'موقوفة', en: 'Inactive'),
  all(ar: 'الكل', en: 'All'),
  search(ar: 'ابحث بالاسم أو الرمز', en: 'Search by name or code'),
  used(
    ar: 'مرتبطة بخصائص أو أنواع منتجات',
    en: 'Linked to attributes or product types',
  ),
  locked(
    ar: 'لا يمكن تغيير طريقة الاختيار لوجود ارتباطات',
    en: 'Selection type is locked while references exist',
  ),
  deleteBlocked(
    ar: 'لا يمكن حذف مجموعة تحتوي خيارات أو ارتباطات',
    en: 'A set with options or references cannot be deleted',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  loadError(
    ar: 'تعذر تحميل مجموعات الخيارات',
    en: 'Could not load option sets',
  ),
  saveError(ar: 'تعذر حفظ مجموعة الخيارات', en: 'Could not save option set'),
  total(ar: 'إجمالي المجموعات', en: 'Total sets'),
  activeCount(ar: 'المجموعات الفعالة', en: 'Active sets'),
  inactiveCount(ar: 'المجموعات الموقوفة', en: 'Inactive sets');

  const OptionSetsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'optionSets.$name';
}
