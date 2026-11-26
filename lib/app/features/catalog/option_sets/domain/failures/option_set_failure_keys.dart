import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum OptionSetFailureKeys implements AppKey {
  duplicateCode(
    ar: 'رمز مجموعة الخيارات مستخدم مسبقاً',
    en: 'This option-set code is already in use.',
  ),
  duplicateOptionCode(
    ar: 'رمز الخيار مستخدم داخل هذه المجموعة',
    en: 'This option code is already used in this set.',
  ),
  inUse(
    ar: 'مجموعة الخيارات مرتبطة بسجلات؛ أوقفها بدلاً من حذفها.',
    en: 'This option set is referenced. Deactivate it instead.',
  ),
  usageUnknown(
    ar: 'تعذر التحقق من استخدام المجموعة؛ الإجراء غير متاح.',
    en: 'Option-set usage could not be verified; the action is blocked.',
  ),
  selectionTypeLocked(
    ar: 'لا يمكن تغيير نوع الاختيار بعد استخدام المجموعة.',
    en: 'Selection type cannot change after the set is used.',
  ),
  invalidSelectionType(
    ar: 'نوع الاختيار غير صالح.',
    en: 'The selection type is invalid.',
  ),
  inactiveOptionSet(
    ar: 'مجموعة الخيارات غير نشطة ولا تقبل تعيينات جديدة.',
    en: 'This option set is inactive and cannot receive new assignments.',
  );

  const OptionSetFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'optionsetfailures.$name';
}
