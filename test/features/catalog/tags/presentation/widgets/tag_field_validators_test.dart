// ignore_for_file: implementation_imports
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/widgets/tag_field_validators.dart';

void main() {
  setUpAll(() {
    Localization.load(
      const Locale('en'),
      translations: Translations({
        for (final key in TagsKeys.values) key.key: key.en,
      }),
    );
  });

  test('name: required and max 100', () {
    expect(TagFieldValidators.name(' '), TagsKeys.required.en);
    expect(TagFieldValidators.name('a' * 101), TagsKeys.nameTooLong.en);
    expect(TagFieldValidators.name('New arrival'), isNull);
  });

  test('slug: required, max 100 and lowercase ASCII format', () {
    expect(TagFieldValidators.slug(''), TagsKeys.required.en);
    expect(TagFieldValidators.slug('a' * 101), TagsKeys.slugTooLong.en);
    expect(TagFieldValidators.slug('new-arrival'), isNull);
    expect(TagFieldValidators.slug('sale2'), isNull);
    expect(TagFieldValidators.slug('New'), TagsKeys.slugFormat.en);
    expect(TagFieldValidators.slug('-sale'), TagsKeys.slugFormat.en);
    expect(TagFieldValidators.slug('sale-'), TagsKeys.slugFormat.en);
    expect(TagFieldValidators.slug('وسم'), TagsKeys.slugFormat.en);
  });
}
