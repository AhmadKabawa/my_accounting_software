import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/units/data/models/unit_model.dart';
import 'package:accounting_software/app/features/catalog/units/domain/entity/catalog_unit.dart';

void main() {
  Map<String, dynamic> json({
    Object? products = const [{'count': 2}],
    Object? attributes = const [{'count': 3}],
  }) => {
    'id': 7,
    'name': 'Piece',
    'symbol': 'pc',
    'unit_type': 'piece',
    'is_active': true,
    'updated_at': '2026-11-20T12:30:00Z',
    'product_variants': products,
    'attributes': attributes,
  };

  test('maps update time and sums both usage relationships', () {
    final unit = UnitModel.fromJson(json()).toEntity();

    expect(unit.id, 7);
    expect(unit.type, UnitType.piece);
    expect(unit.usageCount, 5);
    expect(unit.updatedAt, DateTime.parse('2026-11-20T12:30:00Z'));
  });

  test('missing or malformed usage count remains unknown', () {
    expect(
      UnitModel.fromJson(json(attributes: null)).usageCount,
      isNull,
    );
    expect(
      UnitModel.fromJson(json(products: const [{'count': 'unknown'}])).usageCount,
      isNull,
    );
  });

  test('invalid unit type is rejected instead of leaking raw enum text', () {
    expect(
      () => UnitModel.fromJson({...json(), 'unit_type': 'conversion'}),
      throwsFormatException,
    );
  });
}
