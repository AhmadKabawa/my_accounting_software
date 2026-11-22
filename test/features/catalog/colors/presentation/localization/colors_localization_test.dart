import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/features/catalog/colors/presentation/localization/colors_keys.dart';
import 'package:accounting_software/app/features/catalog/colors/domain/failures/color_failure_keys.dart';
import 'package:accounting_software/app/localization/key_registry.dart';

void main() {
  test('color keys are registered, unique and translated', () {
    final english = MyDartLoader.build(allKeys, (key) => key.en);
    final arabic = MyDartLoader.build(allKeys, (key) => key.ar);
    final registered = allKeys
        .where((key) => key.key.startsWith('colors.'))
        .toList();

    expect(
      registered,
      hasLength(ColorsKeys.values.length + ColorFailureKeys.values.length),
    );
    expect(
      registered.map((key) => key.key).toSet(),
      hasLength(ColorsKeys.values.length),
    );
    expect(english['colors.title'], 'Colors');
    expect(english['colors.name'], 'Color name');
    expect(arabic['colors.title'], 'الألوان');
    expect(arabic['colors.name'], 'اسم اللون');
    for (final key in ColorsKeys.values) {
      expect(key.ar.trim(), isNotEmpty);
      expect(key.en.trim(), isNotEmpty);
    }
  });
}
