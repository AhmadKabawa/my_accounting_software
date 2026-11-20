import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/core/localization/translations/asset_loader.dart';
import 'package:accounting_software/app/features/catalog/presentation/localization/brands_keys.dart';
import 'package:accounting_software/app/localization/key_registry.dart';

void main() {
  test(
    'brand localization keys are registered with distinct Arabic and English values',
    () {
      final english = MyDartLoader.build(allKeys, (key) => key.en);
      final arabic = MyDartLoader.build(allKeys, (key) => key.ar);
      final registeredBrandKeys = allKeys
          .where((key) => key.key.startsWith('brands.'))
          .toList();

      expect(registeredBrandKeys, hasLength(BrandsKeys.values.length));
      expect(
        registeredBrandKeys.map((key) => key.key).toSet(),
        hasLength(BrandsKeys.values.length),
      );
      expect(english['brands.title'], 'Brands');
      expect(english['brands.name'], 'Brand name');
      expect(english['brands.deleted'], 'Brand deleted.');
      expect(arabic['brands.title'], 'الماركات');
      expect(arabic['brands.name'], 'اسم الماركة');
      expect(arabic['brands.deleted'], 'تم حذف الماركة.');
      expect(
        english.entries
            .where((entry) => entry.value == 'Brand deleted.')
            .map((entry) => entry.key),
        ['brands.deleted'],
      );
    },
  );
}
