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
/**  app_key.dart
extension type const AppKey(String value) {
  @override
  String toString() => value;
}





// الآن كل الـ "subtypes" هي مجرد factory constructors أو constants
// بدون inheritance — لكن مع تصنيف منطقي عبر naming */
/// الـ sealed class الأساسية لكل مفتاح
/*abstract class AppKey {
  final String _value;
  const AppKey(this._value);

  @override
  String toString() => _value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppKey && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
  String tr({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
    BuildContext? context,
  }) {
    return _value.tr(
      args: args,
      namedArgs: namedArgs,
      gender: gender,
      context: context,
    );
  }

  /// shortcut
  String get tran => _value.tr();
}*/

/// النوع الوحيد المقبول في كل مكان
