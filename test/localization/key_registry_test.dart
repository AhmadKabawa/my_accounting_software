import 'dart:io';
import 'dart:ui';

import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/localization/key_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keys are unique across the whole registry', () {
    final seen = <String>{};
    final dup = <String>[];
    for (final k in allKeys) {
      if (!seen.add(k.key)) dup.add(k.key);
    }
    expect(dup, isEmpty, reason: 'duplicate keys: $dup');
  });

  test('every enum implementing AppKey is registered', () {
    final declared = <String>{};
    final re = RegExp(r'enum\s+(\w+)\s+implements\s+AppKey\b');
    for (final f
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      for (final m in re.allMatches(f.readAsStringSync())) {
        declared.add(m.group(1)!);
      }
    }
    final registered = allKeys.map((k) => k.runtimeType.toString()).toSet();
    expect(declared, isNotEmpty);
    expect(
      declared.difference(registered),
      isEmpty,
      reason: 'add the missing enum to lib/app/localization/key_registry.dart',
    );
  });

  test('texts are non-empty and variables match between languages', () {
    final vars = RegExp(r'\{\w+\}');
    for (final k in allKeys) {
      expect(k.ar.trim(), isNotEmpty, reason: '${k.key} (ar)');
      expect(k.en.trim(), isNotEmpty, reason: '${k.key} (en)');
      expect(
        vars.allMatches(k.ar).map((m) => m.group(0)).toSet(),
        vars.allMatches(k.en).map((m) => m.group(0)).toSet(),
        reason: '${k.key}: variables differ between ar and en',
      );
    }
  });

  // easy_localization substitutes `{name}` only. A `@name` placeholder is
  // never replaced and reaches the screen literally (the "Page @page of
  // @lastPage" bug). See docs/architecture/KNOWN_PITFALLS.md (L-01).
  test('variables use the {name} syntax, never @name', () {
    final legacy = RegExp(r'@[A-Za-z_]\w*');
    for (final k in allKeys) {
      expect(legacy.hasMatch(k.ar), isFalse, reason: '${k.key} (ar)');
      expect(legacy.hasMatch(k.en), isFalse, reason: '${k.key} (en)');
    }
  });

  test('key equals "<section>.<name>" with a non-empty section', () {
    for (final k in allKeys) {
      expect(
        k.key,
        matches(RegExp(r'^[a-z]+(?:\.[a-z]+)*\.[A-Za-z0-9]+$')),
        reason: k.key,
      );
    }
  });

  // The registry is only useful if the texts really reach `tr()`: the same
  // loader the app uses is initialised here, then every key is resolved.
  group('translation loader', () {
    for (final locale in const [Locale('ar'), Locale('en')]) {
      test('loads ${locale.languageCode} translations', () async {
        final translations = await MyDartLoader(allKeys).load('', locale);

        expect(translations.length, allKeys.length);

        for (final key in allKeys) {
          final expected = locale.languageCode == 'en' ? key.en : key.ar;

          expect(
            translations[key.key],
            expected,
            reason: 'Incorrect translation for ${key.key}',
          );
        }
      });
    }
  });
}
