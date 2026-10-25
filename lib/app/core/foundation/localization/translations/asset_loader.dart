import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_ar.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_en.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/enum_app_language.dart';
import 'package:accounting_software/app/core/foundation/localization/translations/app_key.dart';

class MyDartLoader extends AssetLoader {
  const MyDartLoader();
  static Map<String, dynamic> _convert(TranslationMap map) =>
      map.map((key, value) => MapEntry(key.toString(), value));

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final language = AppLanguage.fromCode(locale.languageCode);
    return switch (language) {
      AppLanguage.en => _convert(enUS),
      AppLanguage.ar => _convert(arSA),
      _ => _convert(arSA),
    };
  }
}
