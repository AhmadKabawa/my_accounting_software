import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum CareInstructionsKeys implements AppKey {
  title(ar: 'تعليمات العناية', en: 'Care instructions'),
  breadcrumbTitle(ar: 'العناية', en: 'Care'),
  add(ar: 'إضافة', en: 'Add'),
  addTitle(ar: 'إضافة تعليمات عناية', en: 'Add care instruction'),
  edit(ar: 'تعديل تعليمات العناية', en: 'Edit care instruction'),
  name(ar: 'اسم التعليمات', en: 'Instruction name'),
  code(ar: 'الرمز', en: 'Code'),
  careType(ar: 'نوع العناية', en: 'Care type'),
  washing(ar: 'غسيل', en: 'Washing'),
  drying(ar: 'تجفيف', en: 'Drying'),
  ironing(ar: 'كيّ', en: 'Ironing'),
  bleaching(ar: 'تبييض', en: 'Bleaching'),
  dryCleaning(ar: 'تنظيف جاف', en: 'Dry cleaning'),
  description(ar: 'الوصف', en: 'Description'),
  status(ar: 'الحالة', en: 'Status'),
  active(ar: 'فعّالة', en: 'Active'),
  inactive(ar: 'موقوفة', en: 'Inactive'),
  allStatuses(ar: 'كل الحالات', en: 'All statuses'),
  searchHint(ar: 'بحث بالاسم/الرمز', en: 'Search name/code'),
  empty(ar: 'لا توجد تعليمات عناية', en: 'No care instructions yet'),
  emptyDescription(
    ar: 'أضف تعليمات العناية المستخدمة للمنتجات.',
    en: 'Add care instructions used by products.',
  ),
  noResults(ar: 'لا توجد نتائج', en: 'No matching care instructions'),
  noResultsDescription(
    ar: 'غيّر البحث أو الفلاتر.',
    en: 'Change the search or filters.',
  ),
  saved(ar: 'تم حفظ تعليمات العناية.', en: 'Care instruction saved.'),
  deleted(ar: 'تم حذف تعليمات العناية.', en: 'Care instruction deleted.'),
  statusUpdated(ar: 'تم تحديث الحالة.', en: 'Status updated.'),
  required(ar: 'هذا الحقل مطلوب.', en: 'This field is required.'),
  nameTooLong(
    ar: 'يجب ألا يتجاوز الاسم 150 حرفاً.',
    en: 'Name must be 150 characters or fewer.',
  ),
  codeTooLong(
    ar: 'يجب ألا يتجاوز الرمز 50 حرفاً.',
    en: 'Code must be 50 characters or fewer.',
  ),
  duplicateError(
    ar: 'رمز تعليمات العناية مستخدم مسبقاً.',
    en: 'This care instruction code is already in use.',
  ),
  inUse(
    ar: 'تعليمات العناية مستخدمة؛ أوقِفها بدلاً من الحذف.',
    en: 'This care instruction is in use; deactivate it instead of deleting it.',
  ),
  saveError(
    ar: 'تعذر حفظ تعليمات العناية.',
    en: 'Could not save care instruction.',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  activate(ar: 'تفعيل', en: 'Activate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  delete(ar: 'حذف', en: 'Delete'),
  deleteTitle(ar: 'حذف تعليمات العناية', en: 'Delete care instruction'),
  deleteMessage(ar: 'هل تريد حذف {name}؟', en: 'Delete {name}?'),
  deactivateTitle(
    ar: 'إيقاف تعليمات العناية',
    en: 'Deactivate care instruction',
  ),
  deactivateMessage(
    ar: 'سيتم إيقاف التعليمات مع الاحتفاظ بها.',
    en: 'The instruction will be deactivated and retained.',
  ),
  sortOrder(ar: 'ترتيب العرض', en: 'Display order');

  const CareInstructionsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'careinstructions.${this.name}';
}
