import 'package:accounting_software/app/core/localization/translations/app_key.dart';
enum AppColorPickerKeys implements AppKey {
  hex(ar:'HEX',en:'HEX'), noColor(ar:'بلا لون',en:'No color'), copy(ar:'نسخ اللون',en:'Copy color'), presets(ar:'ألوان جاهزة',en:'Presets'), hue(ar:'درجة اللون',en:'Hue'), sv(ar:'التشبع والسطوع',en:'Saturation and value');
  const AppColorPickerKeys({required this.ar,required this.en});
  @override final String ar; @override final String en;
  @override String get key=>'colorpicker.$name';
}