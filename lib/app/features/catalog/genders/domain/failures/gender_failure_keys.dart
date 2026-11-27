import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum GenderFailureKeys implements AppKey {
  inUse(
    ar: 'لا يمكن حذف الجنس لارتباطه بمجموعات مقاسات. أوقفه بدلاً من ذلك.',
    en: 'This gender is used by size groups. Deactivate it instead.',
  ),
  usageUnknown(
    ar: 'تعذر التحقق من الاستخدام؛ تم منع الحذف حفاظاً على البيانات.',
    en: 'Usage could not be verified; deletion was blocked to protect data.',
  );

  const GenderFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'genderfailures.$name';
}
