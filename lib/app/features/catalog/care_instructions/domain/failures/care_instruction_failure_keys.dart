import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum CareInstructionFailureKeys implements AppKey {
  duplicate(
    ar: 'رمز تعليمات العناية مستخدم مسبقاً.',
    en: 'This care instruction code is already in use.',
  ),
  inUse(
    ar: 'تعليمات العناية مستخدمة؛ أوقِفها بدلاً من الحذف.',
    en: 'This care instruction is in use; deactivate it instead of deleting it.',
  );

  const CareInstructionFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalog.careInstructions.failure.$name';
}
