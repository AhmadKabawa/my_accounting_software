import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum SportFailureKeys implements AppKey {
  inUse(
    ar: 'الرياضة مستخدمة في منتجات، عطّلها بدل حذفها',
    en: 'This sport is used in products. Deactivate it instead.',
  );

  const SportFailureKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'sports.$name';
}
