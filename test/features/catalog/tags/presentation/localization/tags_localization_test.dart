import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/features/catalog/tags/domain/failures/tag_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/tags/presentation/localization/tags_keys.dart';
import 'package:accounting_software/app/localization/key_registry.dart';

void main() {
  test('tag keys are registered, unique and translated', () {
    final english = MyDartLoader.build(allKeys, (key) => key.en);
    final arabic = MyDartLoader.build(allKeys, (key) => key.ar);
    final registered = allKeys
        .where((key) => key.key.startsWith('tags.'))
        .toList();
    final expected = TagsKeys.values.length + TagFailureKeys.values.length;

    expect(registered, hasLength(expected));
    expect(registered.map((key) => key.key).toSet(), hasLength(expected));
    expect(english['tags.title'], 'Tags');
    expect(english['tags.name'], 'Tag name');
    expect(arabic['tags.title'], 'الوسوم');
    expect(arabic['tags.name'], 'اسم الوسم');
    for (final key in TagsKeys.values) {
      expect(key.ar.trim(), isNotEmpty);
      expect(key.en.trim(), isNotEmpty);
    }
  });
}
