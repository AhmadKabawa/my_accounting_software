import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/features/catalog/sports/domain/failures/sport_failure_keys.dart';
import 'package:accounting_software/app/features/catalog/sports/presentation/localization/sports_keys.dart';
import 'package:accounting_software/app/localization/key_registry.dart';

void main() {
  test('sport keys are registered, unique and translated', () {
    final english = MyDartLoader.build(allKeys, (key) => key.en);
    final arabic = MyDartLoader.build(allKeys, (key) => key.ar);
    final registered = allKeys
        .where((key) => key.key.startsWith('sports.'))
        .toList();
    final expected = SportsKeys.values.length + SportFailureKeys.values.length;

    expect(registered, hasLength(expected));
    expect(registered.map((key) => key.key).toSet(), hasLength(expected));
    expect(english['sports.title'], 'Sports');
    expect(english['sports.name'], 'Sport name');
    expect(arabic['sports.title'], 'الرياضات');
    expect(arabic['sports.name'], 'اسم الرياضة');
    for (final key in SportsKeys.values) {
      expect(key.ar.trim(), isNotEmpty);
      expect(key.en.trim(), isNotEmpty);
    }
  });
}
