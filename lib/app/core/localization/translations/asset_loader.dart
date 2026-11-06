import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/localization/translations/app_language.dart';

/// Builds the translation maps from the registered [AppKey] enums.
///
/// The list of keys is injected (see `lib/app/localization/key_registry.dart`)
/// so `core` never imports from `features`.
class MyDartLoader extends AssetLoader {
  const MyDartLoader(this.keys);

  final List<AppKey> keys;

  static Map<String, dynamic> build(
    List<AppKey> keys,
    String Function(AppKey) pick,
  ) => {for (final k in keys) k.key: pick(k)};

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final language = AppLanguage.fromCode(locale.languageCode);
    return switch (language) {
      AppLanguage.en => build(keys, (k) => k.en),
      AppLanguage.ar => build(keys, (k) => k.ar),
      _ => build(keys, (k) => k.ar),
    };
  }
}
