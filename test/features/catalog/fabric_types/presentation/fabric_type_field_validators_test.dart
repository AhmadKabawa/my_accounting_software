import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/widgets/fabric_type_field_validators.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/presentation/localization/fabric_types_keys.dart';

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({
        for (final key in FabricTypesKeys.values) key.key: key.en,
      }),
    );
  });
  group('FabricTypeFieldValidators', () {
    test('requires a name and code', () {
      expect(FabricTypeFieldValidators.name(' '), isNotNull);
      expect(FabricTypeFieldValidators.code(null), isNotNull);
    });
    test('enforces schema lengths', () {
      expect(
        FabricTypeFieldValidators.name(List.filled(101, 'x').join()),
        isNotNull,
      );
      expect(
        FabricTypeFieldValidators.code(List.filled(51, 'x').join()),
        isNotNull,
      );
    });
    test('accepts valid values', () {
      expect(FabricTypeFieldValidators.name('Jersey'), isNull);
      expect(FabricTypeFieldValidators.code('JER'), isNull);
    });
  });
}
