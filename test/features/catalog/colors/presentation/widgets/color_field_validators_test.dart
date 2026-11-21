// ignore_for_file: implementation_imports
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/widgets/color_field_validators.dart';

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({
        for (final key in ColorsKeys.values) key.key: key.en,
      }),
    );
  });

  test('name: required and max 100', () {
    expect(ColorFieldValidators.name(' '), ColorsKeys.required.en);
    expect(ColorFieldValidators.name('a' * 101), ColorsKeys.nameTooLong.en);
    expect(ColorFieldValidators.name('Navy'), isNull);
  });

  test('code: required and max 50', () {
    expect(ColorFieldValidators.code(''), ColorsKeys.required.en);
    expect(ColorFieldValidators.code('a' * 51), ColorsKeys.codeTooLong.en);
    expect(ColorFieldValidators.code('NAVY-01'), isNull);
  });

  test('hex: optional, # optional, 6 or 8 digits', () {
    expect(ColorFieldValidators.hex(null), isNull);
    expect(ColorFieldValidators.hex('  '), isNull);
    expect(ColorFieldValidators.hex('#1A2B3C'), isNull);
    expect(ColorFieldValidators.hex('1a2b3c'), isNull);
    expect(ColorFieldValidators.hex('#1A2B3C80'), isNull);
    expect(ColorFieldValidators.hex('#1A2B3'), ColorsKeys.hexFormat.en);
    expect(ColorFieldValidators.hex('#GGGGGG'), ColorsKeys.hexFormat.en);
  });

  test('withHash adds the missing #', () {
    expect(ColorFieldValidators.withHash('1a2b3c'), '#1a2b3c');
    expect(ColorFieldValidators.withHash('#1a2b3c'), '#1a2b3c');
    expect(ColorFieldValidators.withHash(' '), isNull);
  });

  test('sort order: optional whole number', () {
    expect(ColorFieldValidators.sortOrder(''), isNull);
    expect(ColorFieldValidators.sortOrder('12'), isNull);
    expect(ColorFieldValidators.sortOrder('-1'), ColorsKeys.sortOrderFormat.en);
    expect(ColorFieldValidators.sortOrder('1.5'), ColorsKeys.sortOrderFormat.en);
  });
}
