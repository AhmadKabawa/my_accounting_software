import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum AttributesKeys implements AppKey {
  title(ar: 'الخصائص', en: 'Attributes'),
  add(ar: 'إضافة خاصية', en: 'Add attribute'),
  edit(ar: 'تعديل الخاصية', en: 'Edit attribute'),
  name(ar: 'اسم الخاصية', en: 'Attribute name'),
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
  filterableCount(ar: 'القابلة للتصفية', en: 'Filterable');

  const AttributesKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'attributes.${name}';
}
