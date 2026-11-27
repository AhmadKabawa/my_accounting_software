import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum SizeSystemFailureKeys implements AppKey {
  systemInUse(
    ar: 'النظام يحتوي مجموعات أو مستخدم، أوقفه بدل حذفه',
    en: 'This system has groups or is in use. Deactivate it instead.',
  ),
  groupInUse(
    ar: 'المجموعة تحتوي مقاسات أو مرتبطة بأنواع منتجات أو منتجات، أوقفها بدل حذفها',
    en: 'This group has sizes or is linked to product types or products. '
        'Deactivate it instead.',
  ),
  sizeInUse(
    ar: 'المقاس مستخدم في منتجات، أوقفه بدل حذفه',
    en: 'This size is used in products. Deactivate it instead.',
  );

  const SizeSystemFailureKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'sizeSystems.failure.$name';
}
