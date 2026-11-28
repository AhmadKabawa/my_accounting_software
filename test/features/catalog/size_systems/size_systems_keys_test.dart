import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/features/catalog/size_systems/presentation/localization/size_systems_keys.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/domain/failures/size_system_failure_keys.dart';

void main() {
  test('every size systems key has Arabic and English text', () {
    for (final key in SizeSystemsKeys.values) {
      expect(key.ar.trim(), isNotEmpty, reason: key.key);
      expect(key.en.trim(), isNotEmpty, reason: key.key);
    }
  });

  test('keys follow the registry shape: lowercase section, one dot', () {
    final shape = RegExp(r'^[a-z]+\.[A-Za-z0-9]+$');
    for (final key in <AppKey>[
      ...SizeSystemsKeys.values,
      ...SizeSystemFailureKeys.values,
    ]) {
      expect(shape.hasMatch(key.key), isTrue, reason: key.key);
    }
  });

  test('variables use {name} only, in both languages', () {
    for (final key in SizeSystemsKeys.values) {
      final ar = RegExp(r'\{(\w+)\}').allMatches(key.ar).map((m) => m[1]);
      final en = RegExp(r'\{(\w+)\}').allMatches(key.en).map((m) => m[1]);
      expect(ar.toList(), en.toList(), reason: key.key);
      expect(ar.every((v) => v == 'name'), isTrue, reason: key.key);
    }
  });
}
