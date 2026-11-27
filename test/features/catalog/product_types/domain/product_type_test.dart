import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/product_types/domain/entity/product_type.dart';

ProductType _type({
  int? products = 0,
  int? sizeGroups = 0,
  int? attributes = 0,
  int? optionSets = 0,
  int? care = 0,
}) => ProductType(
  id: 1,
  name: 'Shoes',
  code: 'SHOE',
  sortOrder: 0,
  isActive: true,
  productCount: products,
  sizeGroupCount: sizeGroups,
  attributeCount: attributes,
  optionSetCount: optionSets,
  careInstructionCount: care,
);

void main() {
  test('unused type is deletable and code remains editable', () {
    final type = _type();
    expect(type.usageKnown, isTrue);
    expect(type.hasUsage, isFalse);
    expect(type.canDelete, isTrue);
    expect(type.codeLocked, isFalse);
  });

  test('any product or relationship locks code and blocks deletion', () {
    for (final type in [
      _type(products: 1),
      _type(sizeGroups: 1),
      _type(attributes: 1),
      _type(optionSets: 1),
      _type(care: 1),
    ]) {
      expect(type.hasUsage, isTrue);
      expect(type.canDelete, isFalse);
      expect(type.codeLocked, isTrue);
    }
  });

  test('unknown usage blocks deletion and locks code', () {
    final type = _type(attributes: null);
    expect(type.usageKnown, isFalse);
    expect(type.hasUsage, isTrue);
    expect(type.canDelete, isFalse);
    expect(type.codeLocked, isTrue);
  });
}
