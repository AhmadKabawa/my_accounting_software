import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ColorsKeys implements AppKey {
  title(ar: 'الألوان', en: 'Colors'),
  add(ar: 'إضافة لون', en: 'Add color'),
  edit(ar: 'تعديل اللون', en: 'Edit color'),
  // `name` would shadow the enum value-name lookup used by the key getter.
  colorName(ar: 'اسم اللون', en: 'Color name'),
  code(ar: 'اختصار اللون (بالإنجليزية)', en: 'Color abbreviation'),
  codeHint(
    ar: 'حروف إنجليزية مثل RED أو BLK',
    en: 'English letters, for example RED or BLK',
  ),
  hexCode(ar: 'قيمة اللون (HEX)', en: 'Color value (HEX)'),
  productUsage(ar: 'الاستخدام (منتجات / مكونات)', en: 'Usage (products / components)'),
  hexHint(ar: 'اختياري، مثل #1A2B3C', en: 'Optional, for example #1A2B3C'),
  sortOrder(ar: 'ترتيب الظهور (اختياري)', en: 'Display order (optional)'),
  sortOrderHint(
    ar: 'يحدد مكان اللون في القوائم: الأصغر أولاً. اتركه 0 إن لم تحتج ترتيبًا خاصًا.',
    en: 'Sets where the color sits in lists: lower first. Leave 0 if you do not need a custom order.',
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
  searchHint(
    ar: 'ابحث باسم اللون أو اختصاره أو HEX',
    en: 'Search by color name, abbreviation or HEX',
  ),
  suggestedName(ar: 'الاسم المقترح', en: 'Suggested name'),
  suggestedNameHint(
    ar: 'اقتراح تلقائي قابل للتعديل؛ لن يتغير بعد تعديل الاسم يدوياً.',
    en: 'An editable suggestion; it will not change after you manually edit the name.',
  ),
  totalColors(ar: 'إجمالي الألوان', en: 'Total colors'),
  activeColors(ar: 'الألوان الفعالة', en: 'Active colors'),
  inactiveColors(ar: 'الألوان الموقوفة', en: 'Inactive colors'),
  usedColors(ar: 'ألوان مستخدمة', en: 'Used colors'),
  unusedColors(ar: 'ألوان غير مستخدمة', en: 'Unused colors'),
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
    ar: 'اختصار اللون مستخدم مسبقاً. اختر اختصاراً مختلفاً.',
    en: 'This color abbreviation is already in use. Choose a different abbreviation.',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 100 حرف.',
    en: 'The name must be 100 characters or fewer.',
  ),
  codeTooLong(
    ar: 'يجب ألا يتجاوز الاختصار 50 حرفاً.',
    en: 'The abbreviation must be 50 characters or fewer.',
  ),
  codeFormat(
    ar: 'ابدأ بحرف إنجليزي، واستخدم الحروف الإنجليزية والأرقام والشرطة أو الشرطة السفلية فقط.',
    en: 'Start with an English letter; use only English letters, numbers, hyphens or underscores.',
  ),
  hexFormat(
    ar: 'اكتب القيمة بصيغة #RRGGBB أو #RRGGBBAA، مثل #1A2B3C.',
    en: 'Use #RRGGBB or #RRGGBBAA, for example #1A2B3C.',
  ),
  sortOrderFormat(
    ar: 'أدخل رقماً صحيحاً صفراً أو أكبر.',
    en: 'Enter a whole number, zero or greater.',
  ),
  identitySection(ar: 'هوية اللون', en: 'Color identity'),
  appearanceSection(ar: 'المظهر', en: 'Appearance'),
  editorSubtitle(
    ar: 'أدخل اسم اللون واختصاره كما سيظهران عند ربطهما بالمنتجات.',
    en: 'Enter the color name and abbreviation as they will appear when assigned to products.',
  ),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  delete(ar: 'حذف', en: 'Delete'),
  gridView(ar: 'عرض شبكي', en: 'Grid view'),
  previousPage(ar: 'السابق', en: 'Previous'),
  nextPage(ar: 'التالي', en: 'Next'),
  tableView(ar: 'عرض الجدول', en: 'Table view'),
  deleted(ar: 'تم حذف اللون.', en: 'Color deleted.'),
  copyHex(ar: 'نسخ قيمة HEX', en: 'Copy HEX value'),
  deleteTitle(ar: 'حذف اللون', en: 'Delete color'),
  deleteMessage(ar: 'هل تريد حذف اللون {name}؟', en: 'Delete color {name}?'),
  deactivateTitle(ar: 'إيقاف اللون', en: 'Deactivate color'),
  deactivateMessage(
    ar: 'سيتم إيقاف اللون مع الاحتفاظ به وبسجلاته، ولن يظهر عند اختيار ألوان جديدة.',
    en: 'This color will be deactivated while keeping its record. It will not be offered for new selections.',
  ),
  saved(ar: 'تم حفظ اللون.', en: 'Color saved.'),
  statusUpdated(ar: 'تم تحديث حالة اللون.', en: 'Color status updated.'),
  codeLabel(ar: 'الاختصار: {code}', en: 'Abbr.: {code}'),
  noSampleLabel(ar: 'بدون قيمة HEX', en: 'No HEX value'),
  sortByOrder(ar: 'الترتيب اليدوي', en: 'Manual order'),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortByNewest(ar: 'الأحدث', en: 'Newest'),
  sortByCode(ar: 'الاختصار', en: 'Abbreviation'),
  duplicate(ar: 'مضاعفة', en: 'Duplicate'),
  duplicateTitle(ar: 'مضاعفة لون', en: 'Duplicate color'),
  duplicateSuffix(ar: '(نسخة)', en: '(Copy)'),
  duplicateCodeSuffix(ar: '-COPY', en: '-COPY'),
  bulkActivate(ar: 'تفعيل المحدد', en: 'Activate selected'),
  bulkDeactivate(ar: 'إيقاف المحدد', en: 'Deactivate selected'),
  bulkDelete(ar: 'حذف المحدد', en: 'Delete selected'),
  bulkDeactivateTitle(
    ar: 'إيقاف الألوان المحددة',
    en: 'Deactivate selected colors',
  ),
  bulkDeactivateMessage(
    ar: 'سيتم إيقاف {count} لون مع الاحتفاظ بسجلاتها.',
    en: '{count} colors will be deactivated and retained.',
  ),
  bulkDeleteTitle(ar: 'حذف الألوان المحددة', en: 'Delete selected colors'),
  bulkDeleteMessage(
    ar: 'سيتم حذف {count} لون.',
    en: '{count} colors will be deleted.',
  ),
  bulkResultTitle(ar: 'نتيجة العملية الجماعية', en: 'Bulk operation result'),
  bulkResultSummary(
    ar: 'نجح {success} سجل وفشل {failure} سجل.',
    en: '{success} records succeeded and {failure} failed.',
  ),
  bulkFailureLine(ar: '{name}: {reason}', en: '{name}: {reason}');

  const ColorsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key =>
      this == ColorsKeys.colorName ? 'colors.name' : 'colors.$name';
}
