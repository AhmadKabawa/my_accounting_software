import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum UnitFailureKeys implements AppKey {
  duplicateSymbol(
    ar: 'رمز الوحدة مستخدم مسبقاً',
    en: 'This unit symbol is already in use.',
  ),
  inUse(
    ar: 'الوحدة مرتبطة بسجلات؛ أوقفها بدلاً من حذفها.',
    en: 'This unit is referenced by records. Deactivate it instead.',
  ),
  usageUnknown(
    ar: 'تعذر التحقق من استخدام الوحدة؛ الحذف غير متاح.',
    en: 'Unit usage could not be verified; deletion is blocked.',
  ),
  invalidUnitType(ar: 'نوع الوحدة غير صالح.', en: 'The unit type is invalid.');

  const UnitFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'unitfailures.$name';
}
