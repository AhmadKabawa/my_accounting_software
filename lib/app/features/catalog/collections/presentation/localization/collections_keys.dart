import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum CollectionsKeys implements AppKey {
  title(ar: 'المجموعات', en: 'Collections'),
  add(ar: 'إضافة مجموعة', en: 'Add collection'),
  edit(ar: 'تعديل المجموعة', en: 'Edit collection'),
  collectionName(ar: 'اسم المجموعة', en: 'Collection name'),
  code(ar: 'الرمز', en: 'Code'),
  description(ar: 'الوصف', en: 'Description'),
  startDate(ar: 'تاريخ البداية', en: 'Start date'),
  endDate(ar: 'تاريخ النهاية', en: 'End date'),
  imageSection(ar: 'صورة المجموعة', en: 'Collection image'),
  uploadImage(ar: 'رفع صورة', en: 'Upload image'),
  replaceImage(ar: 'استبدال الصورة', en: 'Replace image'),
  removeImage(ar: 'إزالة الصورة', en: 'Remove image'),
  imageUploadPermission(
    ar: 'ليس لديك صلاحية رفع صورة المجموعة.',
    en: 'You do not have permission to upload a collection image.',
  ),
  status(ar: 'الحالة', en: 'Status'),
  active(ar: 'فعالة', en: 'Active'),
  inactive(ar: 'موقوفة', en: 'Inactive'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(
    ar: 'ابحث باسم المجموعة أو رمزها',
    en: 'Search by collection name or code',
  ),
  empty(ar: 'لا توجد مجموعات', en: 'No collections yet'),
  emptyDescription(
    ar: 'أنشئ مجموعات لتنظيم المنتجات ضمن حملات أو تشكيلات.',
    en: 'Create collections to organize products into campaigns or ranges.',
  ),
  noResults(ar: 'لا توجد نتائج', en: 'No matching collections'),
  noResultsDescription(
    ar: 'غيّر البحث أو الفلاتر.',
    en: 'Change the search or filters.',
  ),
  deleted(ar: 'تم حذف المجموعة.', en: 'Collection deleted.'),
  saved(ar: 'تم حفظ المجموعة.', en: 'Collection saved.'),
  statusUpdated(ar: 'تم تحديث الحالة.', en: 'Status updated.'),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 150 حرفاً.',
    en: 'Name must be 150 characters or fewer.',
  ),
  codeTooLong(
    ar: 'يجب ألا يتجاوز الرمز 50 حرفاً.',
    en: 'Code must be 50 characters or fewer.',
  ),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  inUse(
    ar: 'المجموعة مرتبطة بمنتجات؛ أوقفها بدلاً من حذفها.',
    en: 'This collection is linked to products; deactivate it instead.',
  ),
  duplicateError(
    ar: 'رمز المجموعة مستخدم مسبقاً.',
    en: 'This collection code is already in use.',
  ),
  saveError(ar: 'تعذر حفظ المجموعة.', en: 'Could not save collection.'),
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
  deleteTitle(ar: 'حذف المجموعة', en: 'Delete collection'),
  deleteMessage(ar: 'هل تريد حذف {name}؟', en: 'Delete {name}?'),
  deactivateTitle(ar: 'إيقاف المجموعة', en: 'Deactivate collection'),
  deactivateMessage(
    ar: 'سيتم إيقاف المجموعة مع الاحتفاظ بها.',
    en: 'The collection will be deactivated and retained.',
  ),
  sortByName(ar: 'الاسم', en: 'Name'),
  sortByStartDate(ar: 'تاريخ البداية', en: 'Start date');

  const CollectionsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalog.collections.$name';
}
