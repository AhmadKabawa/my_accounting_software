import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum SportsKeys implements AppKey {
  title(ar: 'الرياضات', en: 'Sports'),
  add(ar: 'إضافة رياضة', en: 'Add sport'),
  edit(ar: 'تعديل الرياضة', en: 'Edit sport'),
  // `name` would shadow the enum value-name lookup used by the key getter.
  sportName(ar: 'اسم الرياضة', en: 'Sport name'),
  code(ar: 'رمز الرياضة (بالإنجليزية)', en: 'Sport code'),
  codeHint(
    ar: 'حروف إنجليزية مثل FOOTBALL أو RUNNING',
    en: 'English letters, for example FOOTBALL or RUNNING',
  ),
  description(ar: 'الوصف (اختياري)', en: 'Description (optional)'),
  sortOrder(ar: 'ترتيب الظهور (اختياري)', en: 'Display order (optional)'),
  sortOrderHint(
    ar: 'يحدد مكان الرياضة في القوائم: الأصغر أولاً. اتركه 0 إن لم تحتج ترتيبًا خاصًا.',
    en: 'Sets where the sport sits in lists: lower first. Leave 0 if you do not need a custom order.',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  active(ar: 'فعّال', en: 'Active'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  status(ar: 'الحالة', en: 'Status'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(
    ar: 'ابحث باسم الرياضة أو رمزها',
    en: 'Search by sport name or code',
  ),
  totalSports(ar: 'إجمالي الرياضات', en: 'Total sports'),
  activeSports(ar: 'الرياضات الفعالة', en: 'Active sports'),
  inactiveSports(ar: 'الرياضات الموقوفة', en: 'Inactive sports'),
  empty(ar: 'لا توجد رياضات بعد', en: 'No sports yet'),
  emptyDescription(
    ar: 'أضف الرياضات التي تناسبها منتجاتك (مثل كرة القدم أو الجري) لتختارها لاحقاً عند وصف المنتج.',
    en: 'Add the sports your products suit (such as football or running) so you can pick them when describing a product.',
  ),
  noResults(ar: 'لا توجد نتائج مطابقة', en: 'No matching sports'),
  noResultsDescription(
    ar: 'جرّب تغيير عبارة البحث أو حالة الرياضة.',
    en: 'Try changing the search term or sport status.',
  ),
  loadError(ar: 'تعذر تحميل الرياضات', en: 'Could not load sports'),
  saveError(
    ar: 'تعذر حفظ الرياضة. تحقق من الاتصال والصلاحيات ثم حاول مجدداً.',
    en: 'Could not save the sport. Check your connection and permissions, then try again.',
  ),
  duplicateError(
    ar: 'رمز الرياضة مستخدم مسبقاً. اختر رمزاً مختلفاً.',
    en: 'This sport code is already in use. Choose a different code.',
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
  codeFormat(
    ar: 'ابدأ بحرف إنجليزي، واستخدم الحروف الإنجليزية والأرقام والشرطة أو الشرطة السفلية فقط.',
    en: 'Start with an English letter; use only English letters, numbers, hyphens or underscores.',
  ),
  sortOrderFormat(
    ar: 'أدخل رقماً صحيحاً صفراً أو أكبر.',
    en: 'Enter a whole number, zero or greater.',
  ),
  identitySection(ar: 'هوية الرياضة', en: 'Sport identity'),
  detailsSection(ar: 'التفاصيل', en: 'Details'),
  editorSubtitle(
    ar: 'أدخل اسم الرياضة ورمزها كما سيظهران عند ربطهما بالمنتجات.',
    en: 'Enter the sport name and code as they will appear when assigned to products.',
  ),
  activate(ar: 'إعادة تفعيل', en: 'Reactivate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  delete(ar: 'حذف', en: 'Delete'),
  deleted(ar: 'تم حذف الرياضة.', en: 'Sport deleted.'),
  deleteTitle(ar: 'حذف الرياضة', en: 'Delete sport'),
  deleteMessage(ar: 'هل تريد حذف الرياضة {name}؟', en: 'Delete sport {name}?'),
  deactivateTitle(ar: 'إيقاف الرياضة', en: 'Deactivate sport'),
  deactivateMessage(
    ar: 'سيتم إيقاف الرياضة مع الاحتفاظ بها وبسجلاتها، ولن تظهر عند اختيار رياضات جديدة.',
    en: 'This sport will be deactivated while keeping its record. It will not be offered for new selections.',
  ),
  saved(ar: 'تم حفظ الرياضة.', en: 'Sport saved.'),
  statusUpdated(ar: 'تم تحديث حالة الرياضة.', en: 'Sport status updated.'),
  codeLabel(ar: 'الرمز: {code}', en: 'Code: {code}'),
  sortByOrder(ar: 'الترتيب اليدوي', en: 'Manual order'),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortByCode(ar: 'الرمز', en: 'Code'),
  duplicate(ar: 'مضاعفة', en: 'Duplicate'),
  duplicateTitle(ar: 'مضاعفة رياضة', en: 'Duplicate sport'),
  duplicateSuffix(ar: '(نسخة)', en: '(Copy)'),
  duplicateCodeSuffix(ar: '-COPY', en: '-COPY'),
  bulkActivate(ar: 'تفعيل المحدد', en: 'Activate selected'),
  bulkDeactivate(ar: 'إيقاف المحدد', en: 'Deactivate selected'),
  bulkDelete(ar: 'حذف المحدد', en: 'Delete selected'),
  bulkDeactivateTitle(
    ar: 'إيقاف الرياضات المحددة',
    en: 'Deactivate selected sports',
  ),
  bulkDeactivateMessage(
    ar: 'سيتم إيقاف {count} رياضة مع الاحتفاظ بسجلاتها.',
    en: '{count} sports will be deactivated and retained.',
  ),
  bulkDeleteTitle(ar: 'حذف الرياضات المحددة', en: 'Delete selected sports'),
  bulkDeleteMessage(
    ar: 'سيتم حذف {count} رياضة.',
    en: '{count} sports will be deleted.',
  );

  const SportsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key =>
      this == SportsKeys.sportName ? 'sports.name' : 'sports.$name';
}
