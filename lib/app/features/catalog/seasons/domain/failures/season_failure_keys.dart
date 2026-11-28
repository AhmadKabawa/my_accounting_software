import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum SeasonFailureKeys implements AppKey {
  inUse(
    ar: 'السجل مستخدم؛ أوقفه بدلاً من الحذف.',
    en: 'This record is in use; deactivate it instead of deleting it.',
  );

  const SeasonFailureKeys({required this.ar, required this.en});
  @override
  final String ar;
  @override
  final String en;
  @override
  String get key => 'catalog.seasons.seasonFailure.$name';
}
