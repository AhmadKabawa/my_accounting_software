// lib/core/localization/translations/translation_map.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

typedef TranslationMap = Map<AppKey, String>;

extension type const AppKey(String value) {
  String toStringKey() => value;

  String tr({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
    BuildContext? context,
  }) {
    return value.tr(
      args: args,
      namedArgs: namedArgs,
      gender: gender,
      context: context,
    );
  }

  /// Shortcut
  String get tran => value.tr();
}
