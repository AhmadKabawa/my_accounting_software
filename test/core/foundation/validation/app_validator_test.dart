// ignore_for_file: implementation_imports
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/foundation/validation/app_validator.dart';
import '../../../helpers/test_key.dart';

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({'custom.req': 'CUSTOM'}),
    );
  });

  String? check(String? v, List<ValidationRule> r, {Map<ValidationRule, dynamic>? p}) =>
      AppValidator.validate(v, r, params: p);

  test('required rejects null, empty and blank', () {
    expect(check(null, [ValidationRule.required]), isNotNull);
    expect(check('  ', [ValidationRule.required]), isNotNull);
    expect(check('x', [ValidationRule.required]), isNull);
  });

  test('email accepts a valid address only', () {
    expect(check('a@b.com', [ValidationRule.email]), isNull);
    expect(check('not-an-email', [ValidationRule.email]), isNotNull);
  });

  test('minLength and maxLength use the given params', () {
    expect(check('abc', [ValidationRule.minLength], p: {ValidationRule.minLength: 4}), isNotNull);
    expect(check('abcd', [ValidationRule.minLength], p: {ValidationRule.minLength: 4}), isNull);
    expect(check('abcde', [ValidationRule.maxLength], p: {ValidationRule.maxLength: 4}), isNotNull);
    expect(check('abcde', [ValidationRule.maxLength]), isNull);
  });

  test('password needs upper case, a digit and a special character', () {
    expect(check('abcdefgh', [ValidationRule.password]), isNotNull);
    expect(check('Abcdefg1', [ValidationRule.password]), isNotNull);
    expect(check('Abcdef1!', [ValidationRule.password]), isNull);
    expect(check('Ab1!', [ValidationRule.password]), isNotNull); // default min 8
  });

  test('match compares against the given value', () {
    expect(check('a', [ValidationRule.match], p: {ValidationRule.match: 'a'}), isNull);
    expect(check('a', [ValidationRule.match], p: {ValidationRule.match: 'b'}), isNotNull);
  });

  test('customKeys replace the default message key', () {
    final result = AppValidator.validate(
      '',
      [ValidationRule.required],
      customKeys: {ValidationRule.required: const TestKey('custom.req')},
    );
    expect(result, 'CUSTOM');
  });

  test('the first failing rule wins', () {
    final result = AppValidator.validate('', [
      ValidationRule.required,
      ValidationRule.email,
    ], customKeys: {ValidationRule.required: const TestKey('custom.req')});
    expect(result, 'CUSTOM');
  });
}
