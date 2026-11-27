import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/widgets/material_field_validators.dart';
import 'package:accounting_software/app/features/catalog/materials/presentation/localization/materials_keys.dart';
void main(){setUpAll((){Localization.load(const Locale('en'),translations:Translations({for(final key in MaterialsKeys.values)key.key:key.en}));});group('MaterialFieldValidators',(){test('requires a name and code',(){expect(MaterialFieldValidators.name(' '),isNotNull);expect(MaterialFieldValidators.code(null),isNotNull);});test('enforces schema lengths',(){expect(MaterialFieldValidators.name(List.filled(101,'x').join()),isNotNull);expect(MaterialFieldValidators.code(List.filled(51,'x').join()),isNotNull);});test('accepts valid values',(){expect(MaterialFieldValidators.name('Cotton'),isNull);expect(MaterialFieldValidators.code('COT'),isNull);});});}
