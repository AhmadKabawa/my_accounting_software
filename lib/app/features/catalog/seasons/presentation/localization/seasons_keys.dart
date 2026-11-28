import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum SeasonsKeys implements AppKey {
  title(ar: 'الخامات', en: 'Seasons'),
  add(ar: 'إضافة خامة', en: 'Add season'),
  edit(ar: 'تعديل الخامة', en: 'Edit season'),
  seasonName(ar: 'اسم الخامة', en: 'Season name'),
  code(ar: 'الرمز', en: 'Code'),
  type(ar: 'نوع الخامة', en: 'Season type'),
  notSpecified(ar: 'غير محدد', en: 'Not specified'),
  natural(ar: 'طبيعي', en: 'Natural'),
  synthetic(ar: 'صناعي', en: 'Synthetic'),
  blended(ar: 'مخلوط', en: 'Blended'),
  description(ar: 'الوصف', en: 'Description'),
  status(ar: 'الحالة', en: 'Status'),
  active(ar: 'فعالة', en: 'Active'),
  inactive(ar: 'موقوفة', en: 'Inactive'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(
    ar: 'ابحث باسم الخامة أو رمزها',
    en: 'Search by season name or code',
  ),
  empty(ar: 'لا توجد خامات', en: 'No seasons yet'),
  emptyDescription(
    ar: 'أضف الخامات المستخدمة في منتجاتك.',
    en: 'Add the seasons used in your products.',
  ),
  noResults(ar: 'لا توجد نتائج', en: 'No matching seasons'),
  noResultsDescription(
    ar: 'غيّر البحث أو الفلاتر.',
    en: 'Change the search or filters.',
  ),
  deleted(ar: 'تم حذف الخامة.', en: 'Season deleted.'),
  saved(ar: 'تم حفظ الخامة.', en: 'Season saved.'),
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
    ar: 'لا يمكن حذف السجل لأنه مرتبط ببيانات أخرى.',
    en: 'This record is referenced by other data and cannot be deleted.',
  ),
  duplicateError(
    ar: 'رمز الخامة مستخدم مسبقاً.',
    en: 'This season code is already in use.',
  ),
  saveError(ar: 'تعذر حفظ الخامة.', en: 'Could not save season.'),
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
  deleteTitle(ar: 'حذف الخامة', en: 'Delete season'),
  deleteMessage(ar: 'هل تريد حذف {name}؟', en: 'Delete {name}?'),
  deactivateTitle(ar: 'إيقاف الخامة', en: 'Deactivate season'),
  deactivateMessage(
    ar: 'سيتم إيقاف الخامة مع الاحتفاظ بها.',
    en: 'The season will be deactivated and retained.',
  ),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortByStatus(ar: 'الحالة', en: 'Status'),
  sortByCode(ar: 'الرمز', en: 'Code');

  const SeasonsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalog.seasons.$name';
}
