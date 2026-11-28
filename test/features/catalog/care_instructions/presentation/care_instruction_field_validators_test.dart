import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/localization/care_instructions_keys.dart';
import 'package:accounting_software/app/features/catalog/care_instructions/presentation/widgets/care_instruction_field_validators.dart';

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({
        for (final key in CareInstructionsKeys.values) key.key: key.en,
      }),
    );
  });

  test('requires name and code', () {
    expect(CareInstructionFieldValidators.name(' '), isNotNull);
    expect(CareInstructionFieldValidators.code(null), isNotNull);
  });

  test('enforces the database varchar lengths', () {
    expect(
      CareInstructionFieldValidators.name(List.filled(151, 'x').join()),
      isNotNull,
    );
    expect(
      CareInstructionFieldValidators.code(List.filled(51, 'x').join()),
      isNotNull,
    );
    expect(
      CareInstructionFieldValidators.name(List.filled(150, 'x').join()),
      isNull,
    );
    expect(
      CareInstructionFieldValidators.code(List.filled(50, 'x').join()),
      isNull,
    );
  });
}
