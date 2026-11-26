// ignore_for_file: implementation_imports
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/widgets/sport_field_validators.dart';

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({
        for (final key in SportsKeys.values) key.key: key.en,
      }),
    );
  });

  test('name: required and max 100', () {
    expect(SportFieldValidators.name(' '), SportsKeys.required.en);
    expect(SportFieldValidators.name('a' * 101), SportsKeys.nameTooLong.en);
    expect(SportFieldValidators.name('Football'), isNull);
  });

  test('code: required, max 50 and English code format', () {
    expect(SportFieldValidators.code(''), SportsKeys.required.en);
    expect(SportFieldValidators.code('A' * 51), SportsKeys.codeTooLong.en);
    expect(SportFieldValidators.code('FOOTBALL'), isNull);
    expect(SportFieldValidators.code('TRAIL_RUN-2'), isNull);
    expect(SportFieldValidators.code('123'), SportsKeys.codeFormat.en);
    expect(SportFieldValidators.code('كرة'), SportsKeys.codeFormat.en);
  });

  test('sort order: optional whole number', () {
    expect(SportFieldValidators.sortOrder(''), isNull);
    expect(SportFieldValidators.sortOrder('12'), isNull);
    final message = SportsKeys.sortOrderFormat.en;
    expect(SportFieldValidators.sortOrder('-1'), message);
    expect(SportFieldValidators.sortOrder('1.5'), message);
  });
}
