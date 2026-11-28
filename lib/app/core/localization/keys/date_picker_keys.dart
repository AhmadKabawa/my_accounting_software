import 'package:accounting_software/app/core/localization/translations/app_key.dart';

enum DatePickerKeys implements AppKey {
  open(ar: 'اختيار التاريخ', en: 'Choose date'),
  clear(ar: 'مسح التاريخ', en: 'Clear date');

  const DatePickerKeys({required this.ar, required this.en});

  @override
  final String ar;
  @override
  final String en;

  @override
  String get key => 'datepicker.$name';
}
