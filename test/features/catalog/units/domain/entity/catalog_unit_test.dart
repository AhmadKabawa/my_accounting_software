import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';

void main() {
  CatalogUnit buildUnit(int? usage) => CatalogUnit(
    id: 1,
    name: 'Kilogram',
    symbol: 'kg',
    type: UnitType.weight,
    isActive: true,
    usageCount: usage,
  );

  test('deletion is allowed only when usage is known to be zero', () {
    expect(buildUnit(0).canDelete, isTrue);
    expect(buildUnit(1).canDelete, isFalse);
    expect(buildUnit(null).canDelete, isFalse);
  });
}
