import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum SeasonsKeys implements AppKey {
  title(ar: 'المواسم', en: 'Seasons'),
  add(ar: 'إضافة موسم', en: 'Add season'),
  edit(ar: 'تعديل الموسم', en: 'Edit season'),
  editorSubtitle(
    ar: 'حدد نوع الموسم وفترته الزمنية.',
    en: 'Set the season type and date range.',
  ),
  seasonName(ar: 'اسم الموسم', en: 'Season name'),
  code(ar: 'الرمز', en: 'Code'),
  type(ar: 'نوع الموسم', en: 'Season type'),
  notSpecified(ar: 'غير محدد', en: 'Not specified'),
  summer(ar: 'صيفي', en: 'Summer'),
  winter(ar: 'شتوي', en: 'Winter'),
  spring(ar: 'ربيعي', en: 'Spring'),
  autumn(ar: 'خريفي', en: 'Autumn'),
  startDate(ar: 'تاريخ البداية', en: 'Start date'),
  endDate(ar: 'تاريخ النهاية', en: 'End date'),
  status(ar: 'الحالة', en: 'Status'),
  active(ar: 'فعال', en: 'Active'),
  inactive(ar: 'موقوف', en: 'Inactive'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(
    ar: 'ابحث باسم الموسم أو رمزه',
    en: 'Search by season name or code',
  ),
  empty(ar: 'لا توجد مواسم', en: 'No seasons yet'),
  emptyDescription(
    ar: 'أضف المواسم التي تصف منتجاتك.',
    en: 'Add seasons used to classify products.',
  ),
  noResults(ar: 'لا توجد نتائج', en: 'No matching seasons'),
  noResultsDescription(
    ar: 'غيّر البحث أو الفلاتر.',
    en: 'Change the search or filters.',
  ),
  deleted(ar: 'تم حذف الموسم.', en: 'Season deleted.'),
  saved(ar: 'تم حفظ الموسم.', en: 'Season saved.'),
  statusUpdated(ar: 'تم تحديث الحالة.', en: 'Status updated.'),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 100 حرف.',
    en: 'Name must be 100 characters or fewer.',
  ),
  codeTooLong(
    ar: 'يجب ألا يتجاوز الرمز 50 حرفاً.',
    en: 'Code must be 50 characters or fewer.',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  inUse(
    ar: 'الموسم مرتبط بمنتجات؛ أوقفه بدلاً من حذفه.',
    en: 'This season is linked to products; deactivate it instead.',
  ),
  duplicateError(
    ar: 'رمز الموسم مستخدم مسبقاً.',
    en: 'This season code is already in use.',
  ),
  saveError(ar: 'تعذر حفظ الموسم.', en: 'Could not save season.'),
  activate(ar: 'تفعيل', en: 'Activate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  delete(ar: 'حذف', en: 'Delete'),
  bulkActivate(ar: 'تفعيل المحدد', en: 'Activate selected'),
  bulkDeactivate(ar: 'إيقاف المحدد', en: 'Deactivate selected'),
  bulkDelete(ar: 'حذف المحدد', en: 'Delete selected'),
  bulkDeactivateTitle(
    ar: 'إيقاف السجلات المحددة',
    en: 'Deactivate selected records',
  ),
  bulkDeactivateMessage(
    ar: 'سيتم إيقاف {count} سجل مع الاحتفاظ بها.',
    en: '{count} records will be deactivated and retained.',
  ),
  bulkDeleteTitle(ar: 'حذف السجلات المحددة', en: 'Delete selected records'),
  bulkDeleteMessage(
    ar: 'سيتم حذف {count} سجل.',
    en: '{count} records will be deleted.',
  ),
  duplicate(ar: 'مضاعفة', en: 'Duplicate'),
  deleteTitle(ar: 'حذف الموسم', en: 'Delete season'),
  deleteMessage(ar: 'هل تريد حذف {name}؟', en: 'Delete {name}?'),
  deactivateTitle(ar: 'إيقاف الموسم', en: 'Deactivate season'),
  deactivateMessage(
    ar: 'سيتم إيقاف الموسم مع الاحتفاظ به.',
    en: 'The season will be deactivated and retained.',
  ),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortByStartDate(ar: 'تاريخ البداية', en: 'Start date');

  const SeasonsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalog.seasons.$name';
}
