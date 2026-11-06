import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A translatable text: its lookup key plus every language it ships in.
///
/// Implemented by one `enum` per section (e.g. `AuthKeys`), so a value is a
/// compile-time constant (`const AppText(AuthKeys.signIn)` works) and a
/// missing language is a build error (`ar` / `en` are required).
/// See `docs/architecture/LOCALIZATION.md`.
abstract interface class AppKey {
  /// Lookup key, derived from the section prefix and the value name.
  String get key;

  String get ar;

  String get en;
}

extension AppKeyTr on AppKey {
  String tr({
    List<String>? args,
    Map<String, String>? namedArgs,
    String? gender,
    BuildContext? context,
  }) {
    return key.tr(
      args: args,
      namedArgs: namedArgs,
      gender: gender,
      context: context,
    );
  }

  /// Shortcut
  String get tran => key.tr();
}
