import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum ColorFailureKeys implements AppKey {
  inUse(
    ar: 'اللون مستخدم في منتجات، عطّله بدل حذفه',
    en: 'This color is used in products. Deactivate it instead.',
  );

  const ColorFailureKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'colors.failure.$name';
}
