import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum AgeGroupFailureKeys implements AppKey {
  inUse(
    ar: 'لا يمكن حذف الفئة العمرية لارتباطها بمنتجات. أوقفها بدلاً من ذلك.',
    en: 'This age group is assigned to products. Deactivate it instead.',
  ),
  usageUnknown(
    ar: 'تعذر التحقق من استخدام الفئة العمرية؛ تم منع الحذف حفاظاً على البيانات.',
    en: 'Age group usage could not be verified; deletion was blocked to protect data.',
  ),
  duplicate(
    ar: 'اسم الفئة العمرية مستخدم مسبقاً',
    en: 'An age group with this name already exists',
  ),
  invalidRange(
    ar: 'الحد الأدنى للعمر يجب ألا يتجاوز الحد الأعلى',
    en: 'Minimum age must not exceed maximum age',
  );

  const AgeGroupFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'agegroupfailure.${toString().split('.').last}';
}
