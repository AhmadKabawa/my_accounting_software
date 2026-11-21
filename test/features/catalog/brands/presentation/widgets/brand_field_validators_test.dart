// ignore_for_file: implementation_imports
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/features/catalog/brands/presentation/widgets/brand_field_validators.dart';

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({
        for (final key in BrandsKeys.values) key.key: key.en,
      }),
    );
  });

  test('name: required and max 150', () {
    expect(BrandFieldValidators.name(' '), BrandsKeys.required.en);
    expect(BrandFieldValidators.name('a' * 151), BrandsKeys.nameTooLong.en);
    expect(BrandFieldValidators.name('Northwind'), isNull);
  });

  test('slug: required, max 150, lowercase-hyphen format', () {
    expect(BrandFieldValidators.slug(''), BrandsKeys.slugRequired.en);
    expect(BrandFieldValidators.slug('a' * 151), BrandsKeys.slugTooLong.en);
    expect(BrandFieldValidators.slug('North Wind'), BrandsKeys.slugFormat.en);
    expect(BrandFieldValidators.slug('north-wind-2'), isNull);
  });
}
