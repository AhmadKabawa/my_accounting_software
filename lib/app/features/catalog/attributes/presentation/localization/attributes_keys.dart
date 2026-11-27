import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum AttributesKeys implements AppKey {
  title(ar: 'الخصائص', en: 'Attributes'),
  add(ar: 'إضافة خاصية', en: 'Add attribute'),
  edit(ar: 'تعديل الخاصية', en: 'Edit attribute'),
  attributeName(ar: 'اسم الخاصية', en: 'Attribute name'),
  code(ar: 'الرمز', en: 'Code'),
  dataType(ar: 'نوع البيانات', en: 'Data type'),
  text(ar: 'نص', en: 'Text'),
  number(ar: 'رقم', en: 'Number'),
  boolean(ar: 'نعم / لا', en: 'Boolean'),
  date(ar: 'تاريخ', en: 'Date'),
  json(ar: 'JSON', en: 'JSON'),
  option(ar: 'اختيار من مجموعة', en: 'Option set'),
  unit(ar: 'وحدة القياس', en: 'Unit'),
  optionSet(ar: 'مجموعة الخيارات', en: 'Option set'),
  filterable(ar: 'قابلة للتصفية', en: 'Filterable'),
  active(ar: 'فعّالة', en: 'Active'),
  inactive(ar: 'موقوفة', en: 'Inactive'),
  all(ar: 'الكل', en: 'All'),
  search(ar: 'ابحث بالاسم أو الرمز', en: 'Search by name or code'),
  used(ar: 'مرتبطة بمنتجات', en: 'In use'),
  locked(
    ar: 'لا يمكن تغيير النوع لوجود استخدامات',
    en: 'Data type is locked while values or links exist',
  ),
  deactivateWarning(
    ar: 'إيقاف الخاصية يمنع إسناد قيم جديدة وفق سياسة ERP27',
    en: 'Deactivation blocks assigning new values under ERP27',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  loadError(ar: 'تعذر تحميل الخصائص', en: 'Could not load attributes'),
  saveError(ar: 'تعذر حفظ الخاصية', en: 'Could not save attribute'),
  total(ar: 'إجمالي الخصائص', en: 'Total attributes'),
  activeCount(ar: 'الخصائص الفعالة', en: 'Active attributes'),
  inactiveCount(ar: 'الخصائص الموقوفة', en: 'Inactive attributes'),
  filterableCount(ar: 'القابلة للتصفية', en: 'Filterable'),
  status(ar: 'الحالة', en: 'Status'),
  linkedProductTypes(ar: 'أنواع المنتجات المرتبطة', en: 'Linked product types'),
  unknown(ar: 'غير معروف', en: 'Unknown'),
  empty(ar: 'لا توجد خصائص', en: 'No attributes'),
  emptyDescription(ar: 'أنشئ أول خاصية للكتالوج', en: 'Create the first catalog attribute'),
  noResults(ar: 'لا توجد نتائج', en: 'No results'),
  noResultsDescription(ar: 'جرّب تغيير البحث أو الفلاتر', en: 'Try changing the search or filters'),
  delete(ar: 'حذف', en: 'Delete'),
  deleteBlocked(ar: 'لا يمكن حذف خاصية مستخدمة أو تعذر التحقق من استخدامها', en: 'Cannot delete an attribute that is used or has unknown usage'),
  deleted(ar: 'تم حذف الخاصية', en: 'Attribute deleted'),
  statusUpdated(ar: 'تم تحديث حالة الخاصية', en: 'Attribute status updated'),
  saved(ar: 'تم حفظ الخاصية', en: 'Attribute saved'),
  sortByName(ar: 'الاسم', en: 'Name'),
  unitName(ar: 'الوحدة', en: 'Unit'),
  optionSetName(ar: 'مجموعة الخيارات', en: 'Option set'),
  filterableOn(ar: 'قابلة للتصفية', en: 'Filterable'),
  notFilterable(ar: 'غير قابلة للتصفية', en: 'Not filterable'),
  duplicateCode(ar: 'رمز الخاصية مستخدم مسبقاً', en: 'Attribute code already exists'),
  invalidRelation(ar: 'مجموعة الخيارات غير متوافقة مع نوع الخاصية', en: 'Option set does not match attribute type'),
  inUse(ar: 'الخاصية مستخدمة ولا يمكن تغيير نوعها أو حذفها', en: 'Attribute is in use and cannot be changed or deleted'),
  nameTooLong(ar: 'يجب ألا يتجاوز الاسم 150 حرفاً', en: 'Name must be at most 150 characters'),
  codeTooLong(ar: 'يجب ألا يتجاوز الرمز 80 حرفاً', en: 'Code must be at most 80 characters'),
  confirmDeactivate(ar: 'سيمنع الإيقاف إسناد قيم جديدة وفق ERP27. القيم الحالية تبقى محفوظة.', en: 'Deactivation blocks new values under ERP27; existing values remain'),
  activate(ar: 'تفعيل', en: 'Activate'),
  deactivate(ar: 'إيقاف', en: 'Deactivate'),
  confirmDelete(ar: 'هل تريد حذف هذه الخاصية؟', en: 'Delete this attribute?');

  const AttributesKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'attributes.$name';
}
