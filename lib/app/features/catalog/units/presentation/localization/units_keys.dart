import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum UnitsKeys implements AppKey {
  title(ar: 'وحدات القياس', en: 'Units'),
  editorSubtitle(ar: 'بيانات وحدة القياس ورمزها ونوعها', en: 'Unit name, symbol and measurement type'),
  activeOnCreate(ar: 'تفعيل الوحدة عند الإنشاء', en: 'Activate unit on creation'),
  add(ar: 'إضافة وحدة', en: 'Add unit'),
  edit(ar: 'تعديل الوحدة', en: 'Edit unit'),
  unitName(ar: 'اسم الوحدة', en: 'Unit name'),
  symbol(ar: 'الرمز', en: 'Symbol'),
  type(ar: 'نوع الوحدة', en: 'Unit type'),
  weight(ar: 'وزن', en: 'Weight'),
  length(ar: 'طول', en: 'Length'),
  volume(ar: 'حجم', en: 'Volume'),
  piece(ar: 'قطعة', en: 'Piece'),
  active(ar: 'فعّالة', en: 'Active'),
  inactive(ar: 'موقوفة', en: 'Inactive'),
  all(ar: 'الكل', en: 'All'),
  search(ar: 'ابحث بالاسم أو الرمز', en: 'Search by name or symbol'),
  usage(ar: 'مرتبطة بسجلات', en: 'Linked records'),
  inUse(ar: 'لا يمكن حذف وحدة مستخدمة', en: 'A unit in use cannot be deleted'),
  unknownUsage(
    ar: 'تعذر التحقق من الاستخدام؛ لا يمكن الحذف',
    en: 'Usage could not be verified; deletion is blocked',
  ),
  duplicateSymbol(
    ar: 'رمز الوحدة مستخدم مسبقاً',
    en: 'This unit symbol is already in use',
  ),
  save(ar: 'حفظ', en: 'Save'),
  cancel(ar: 'إلغاء', en: 'Cancel'),
  required(ar: 'هذا الحقل مطلوب', en: 'This field is required'),
  nameTooLong(
    ar: 'الاسم يجب ألا يتجاوز 100 حرف',
    en: 'Name must be 100 characters or fewer',
  ),
  symbolTooLong(
    ar: 'الرمز يجب ألا يتجاوز 20 حرفاً',
    en: 'Symbol must be 20 characters or fewer',
  ),
  total(ar: 'إجمالي الوحدات', en: 'Total units'),
  activeCount(ar: 'الوحدات الفعالة', en: 'Active units'),
  inactiveCount(ar: 'الوحدات الموقوفة', en: 'Inactive units'),
  loadError(ar: 'تعذر تحميل الوحدات', en: 'Could not load units'),
  saveError(ar: 'تعذر حفظ الوحدة', en: 'Could not save unit'),
  saved(ar: 'تم حفظ الوحدة', en: 'Unit saved'),
  deleted(ar: 'تم حذف الوحدة', en: 'Unit deleted'),
  statusUpdated(ar: 'تم تحديث حالة الوحدة', en: 'Unit status updated');

  const UnitsKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'units.$name';
}
