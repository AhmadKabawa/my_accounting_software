import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum TagFailureKeys implements AppKey {
  inUse(
    ar: 'الوسم مستخدم في منتجات، عطّله بدل حذفه',
    en: 'This tag is used in products. Deactivate it instead.',
  );

  const TagFailureKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'tags.$name';
}
