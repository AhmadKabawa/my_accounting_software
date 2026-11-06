// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/error/failures/failure.dart';
import 'package:accounting_software/app/core/error/translators/failure_translator.dart';
import '../../helpers/test_key.dart';

void main() {
  test('translates the message key exactly once', () {
    // The translated value is itself a key: a second tr() would turn it into
    // 'DOUBLE'.
    Localization.load(
      const Locale('en'),
      translations: Translations({
        'test.first': 'test.second',
        'test.second': 'DOUBLE',
      }),
    );

    final failure = ValidationFailure(messageKey: const TestKey('test.first'));

    expect(FailureTranslator.translate(failure), 'test.second');
  });
}
