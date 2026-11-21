import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ColorsKeys implements AppKey {
  title(ar: 'الألوان', en: 'Colors'),
  add(ar: 'إضافة لون', en: 'Add color'),
  edit(ar: 'تعديل اللون', en: 'Edit color'),
  // `name` would shadow the enum value-name lookup used by the key getter.
  colorName(ar: 'اسم اللون', en: 'Color name'),
  code(ar: 'رمز اللون', en: 'Color code'),
  codeHint(ar: 'مثال: BLK أو NAVY-01', en: 'Example: BLK or NAVY-01'),
  hexCode(ar: 'قيمة اللون (HEX)', en: 'Color value (HEX)'),
  hexHint(ar: 'اختياري، مثل #1A2B3C', en: 'Optional, for example #1A2B3C'),
  sortOrder(ar: 'ترتيب العرض', en: 'Display order'),
  sortOrderHint(
    ar: 'الأرقام الأصغر تظهر أولاً.',
    en: 'Lower numbers appear first.',
  ),
  presets(ar: 'ألوان جاهزة', en: 'Preset colors'),
  presetPick(ar: 'اختر {name}', en: 'Pick {name}'),
  noSample(ar: 'بدون عيّنة', en: 'No sample'),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  active(ar: 'فعّال', en: 'Active'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  status(ar: 'الحالة', en: 'Status'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(ar: 'ابحث باسم اللون أو رمزه', en: 'Search by color name or code'),
  empty(ar: 'لا توجد ألوان بعد', en: 'No colors yet'),
  emptyDescription(
    ar: 'أضف الألوان التي تتوفر بها منتجاتك لتختارها لاحقاً عند تعريف المنتج.',
    en: 'Add the colors your products come in so you can pick them when defining a product.',
  ),
  noResults(ar: 'لا توجد نتائج مطابقة', en: 'No matching colors'),
  noResultsDescription(
    ar: 'جرّب تغيير عبارة البحث أو حالة اللون.',
    en: 'Try changing the search term or color status.',
  ),
  loadError(ar: 'تعذر تحميل الألوان', en: 'Could not load colors'),
  saveError(
    ar: 'تعذر حفظ اللون. تحقق من الاتصال والصلاحيات ثم حاول مجدداً.',
    en: 'Could not save the color. Check your connection and permissions, then try again.',
  ),
  duplicateError(
    ar: 'رمز اللون مستخدم مسبقاً. اختر رمزاً مختلفاً.',
    en: 'This color code is already in use. Choose a different code.',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 100 حرف.',
    en: 'The name must be 100 characters or fewer.',
  ),
  codeTooLong(
    ar: 'يجب ألا يتجاوز الرمز 50 حرفاً.',
    en: 'The code must be 50 characters or fewer.',
  ),
  hexFormat(
    ar: 'اكتب القيمة بصيغة #RRGGBB، مثل #1A2B3C.',
    en: 'Use the #RRGGBB format, for example #1A2B3C.',
  ),
  sortOrderFormat(
    ar: 'أدخل رقماً صحيحاً صفراً أو أكبر.',
    en: 'Enter a whole number, zero or greater.',
  ),
  identitySection(ar: 'هوية اللون', en: 'Color identity'),
  appearanceSection(ar: 'المظهر', en: 'Appearance'),
  editorSubtitle(
    ar: 'أدخل اسم اللون ورمزه كما سيظهر عند ربطه بالمنتجات.',
    en: 'Enter the color name and code as they will appear when assigned to products.',
  ),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  deactivateTitle(ar: 'إيقاف اللون', en: 'Deactivate color'),
  deactivateMessage(
    ar: 'سيتم إيقاف اللون مع الاحتفاظ به وبسجلاته، ولن يظهر عند اختيار ألوان جديدة.',
    en: 'This color will be deactivated while keeping its record. It will not be offered for new selections.',
  ),
  saved(ar: 'تم حفظ اللون.', en: 'Color saved.'),
  statusUpdated(ar: 'تم تحديث حالة اللون.', en: 'Color status updated.'),
  codeLabel(ar: 'الرمز: {code}', en: 'Code: {code}'),
  noSampleLabel(ar: 'بدون قيمة HEX', en: 'No HEX value');

  const ColorsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key =>
      this == ColorsKeys.colorName ? 'colors.name' : 'colors.$name';
}
