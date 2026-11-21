import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/brands/domain/entity/brand.dart';

void main() {
  test(
    'hasProducts and canDelete handle zero, positive and unknown counts',
    () {
      const empty = Brand(
        id: 1,
        name: 'Empty',
        slug: 'empty',
        isActive: true,
        productCount: 0,
      );
      const used = Brand(
        id: 2,
        name: 'Used',
        slug: 'used',
        isActive: true,
        productCount: 2,
      );
      const unknown = Brand(
        id: 3,
        name: 'Unknown',
        slug: 'unknown',
        isActive: true,
      );

      expect(empty.hasProducts, isFalse);
      expect(empty.canDelete, isTrue);
      expect(used.hasProducts, isTrue);
      expect(used.canDelete, isFalse);
      expect(unknown.hasProducts, isFalse);
      expect(unknown.canDelete, isFalse);
    },
  );
}
