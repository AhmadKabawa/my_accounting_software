import 'package:accounting_software/app/core/localization/translations/app_key.dart';

/// All user-visible text of the size systems feature (systems, groups, sizes).
enum SizeSystemsKeys implements AppKey {
  hubDescription(
    ar: 'أنظمة المقاسات ومجموعاتها والمقاسات (EU وUS وUK…)',
    en: 'Size systems, their groups and sizes (EU, US, UK…)',
  ),
  systemsTitle(ar: 'أنظمة المقاسات', en: 'Size systems'),
  groupsTitle(ar: 'المجموعات', en: 'Groups'),
  sizesTitle(ar: 'المقاسات', en: 'Sizes'),
  searchHint(ar: 'ابحث بالاسم أو الرمز', en: 'Search by name or code'),
  identity(ar: 'البيانات الأساسية', en: 'Basic information'),
  editorSubtitle(
    ar: 'أدخل بيانات السجل ثم احفظ',
    en: 'Enter the record details, then save',
  ),
  nameField(ar: 'الاسم', en: 'Name'),
  code(ar: 'الرمز', en: 'Code'),
  description(ar: 'الوصف', en: 'Description'),
  status(ar: 'الحالة', en: 'Status'),
  active(ar: 'نشط', en: 'Active'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  total(ar: 'الكل', en: 'All'),
  activeTotal(ar: 'النشطة', en: 'Active'),
  inactiveTotal(ar: 'الموقوفة', en: 'Inactive'),
  updatedAt(ar: 'آخر تحديث', en: 'Last updated'),
  gender(ar: 'الجنس', en: 'Gender'),
  allGenders(ar: 'كل الأجناس', en: 'All genders'),
  noGender(ar: 'بدون جنس', en: 'No gender'),
  numericValue(ar: 'القيمة الرقمية', en: 'Numeric value'),
  sortOrder(ar: 'الترتيب', en: 'Order'),
  groupCount(ar: 'عدد المجموعات', en: 'Groups'),
  sizeCount(ar: 'عدد المقاسات', en: 'Sizes'),
  productTypeCount(ar: 'أنواع المنتجات', en: 'Product types'),
  productCount(ar: 'عدد المنتجات', en: 'Products'),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortByCode(ar: 'الرمز', en: 'Code'),
  sortByUpdated(ar: 'آخر تحديث', en: 'Last updated'),
  sortByOrder(ar: 'الترتيب', en: 'Order'),
  sortByValue(ar: 'القيمة الرقمية', en: 'Numeric value'),
  addSystem(ar: 'إضافة نظام', en: 'Add system'),
  editSystem(ar: 'تعديل النظام', en: 'Edit system'),
  addGroup(ar: 'إضافة مجموعة', en: 'Add group'),
  editGroup(ar: 'تعديل المجموعة', en: 'Edit group'),
  addSize(ar: 'إضافة مقاس', en: 'Add size'),
  editSize(ar: 'تعديل المقاس', en: 'Edit size'),
  duplicateTitle(ar: 'نسخ', en: 'Duplicate'),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  edit(ar: 'تعديل', en: 'Edit'),
  delete(ar: 'حذف', en: 'Delete'),
  activate(ar: 'تفعيل', en: 'Activate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  openGroups(ar: 'فتح المجموعات', en: 'Open groups'),
  openSizes(ar: 'فتح المقاسات', en: 'Open sizes'),
  saved(ar: 'تم الحفظ', en: 'Saved'),
  deleted(ar: 'تم الحذف', en: 'Deleted'),
  statusUpdated(ar: 'تم تحديث الحالة', en: 'Status updated'),
  deleteTitle(ar: 'حذف السجل', en: 'Delete record'),
  deleteMessage(
    ar: 'سيتم حذف {name} نهائياً. هل تريد المتابعة؟',
    en: '{name} will be permanently deleted. Continue?',
  ),
  deactivateTitle(ar: 'إيقاف السجل', en: 'Deactivate record'),
  deactivateMessage(
    ar: 'سيتوقف {name} عن الظهور في الاختيارات الجديدة فقط.',
    en: '{name} will no longer appear in new selections.',
  ),
  emptySystems(ar: 'لا توجد أنظمة مقاسات بعد', en: 'No size systems yet'),
  emptyGroups(ar: 'لا توجد مجموعات في هذا النظام', en: 'No groups in this system'),
  emptySizes(ar: 'لا توجد مقاسات في هذه المجموعة', en: 'No sizes in this group'),
  noResults(ar: 'لا نتائج مطابقة', en: 'No matching results'),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  nameTooLong(ar: 'الاسم أطول من المسموح', en: 'The name is too long'),
  codeTooLong(ar: 'الرمز أطول من المسموح', en: 'The code is too long'),
  sortFormat(
    ar: 'أدخل رقماً صحيحاً لا يقل عن صفر',
    en: 'Enter a whole number, zero or more',
  ),
  numberFormat(
    ar: 'أدخل رقماً صحيحاً بخانتين عشريتين كحد أقصى',
    en: 'Enter a number with at most two decimals',
  ),
  duplicateSystem(
    ar: 'رمز النظام مستخدم في نظام آخر',
    en: 'This code is used by another system',
  ),
  duplicateGroup(
    ar: 'رمز المجموعة مستخدم في مجموعة أخرى',
    en: 'This code is used by another group',
  ),
  duplicateSize(
    ar: 'رمز المقاس مستخدم في هذه المجموعة',
    en: 'This code is used in this group',
  ),
  generate(ar: 'توليد بنطاق', en: 'Generate range'),
  generateTitle(ar: 'توليد مقاسات بنطاق', en: 'Generate sizes from a range'),
  rangeFrom(ar: 'من', en: 'From'),
  rangeTo(ar: 'إلى', en: 'To'),
  rangeStep(ar: 'الخطوة', en: 'Step'),
  rangePrefix(ar: 'بادئة الرمز', en: 'Code prefix'),
  rangeReversed(
    ar: 'قيمة «من» يجب ألا تتجاوز «إلى»',
    en: '"From" must not be greater than "To"',
  ),
  rangeStepPositive(
    ar: 'الخطوة يجب أن تكون أكبر من صفر',
    en: 'The step must be greater than zero',
  ),
  rangeTooMany(
    ar: 'عدد المقاسات الناتجة يتجاوز الحد المسموح',
    en: 'Too many sizes would be generated',
  ),
  rangePreview(ar: 'معاينة قبل الحفظ', en: 'Preview before saving'),
  rangeCount(ar: 'عدد المقاسات الجديدة', en: 'New sizes'),
  rangeSkipped(
    ar: 'رموز موجودة وستُتخطى',
    en: 'Existing codes that will be skipped',
  ),
  rangeNothing(
    ar: 'لا توجد مقاسات جديدة للحفظ',
    en: 'There are no new sizes to save',
  ),
  rangeSaved(ar: 'تم توليد المقاسات', en: 'Sizes generated');

  const SizeSystemsKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'sizesystems.$name';
}
