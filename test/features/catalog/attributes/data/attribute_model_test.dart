import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/attributes/data/models/attribute_model.dart';
import 'package:accounting_software/app/features/catalog/attributes/domain/entity/catalog_attribute.dart';

void main() {
  Map<String, dynamic> payload({
    Object? links = const [
      {'count': 2},
    ],
    Object? values = const [
      {'count': 3},
    ],
    String type = 'number',
  }) => {
    'id': 4,
    'name': 'Weight',
    'code': 'WEIGHT',
    'data_type': type,
    'unit_id': 2,
    'option_set_id': null,
    'is_filterable': true,
    'is_active': true,
    'units': const [
      {'id': 2, 'name': 'Kilogram', 'symbol': 'kg'},
    ],
    'option_sets': null,
    'product_type_attributes': links,
    'product_attribute_values': values,
  };

  test('maps lookup labels and independent usage counts', () {
    final attribute = AttributeModel.fromJson(payload()).toEntity();
    expect(attribute.dataType, AttributeDataType.number);
    expect(attribute.unitName, 'Kilogram');
    expect(attribute.unitSymbol, 'kg');
    expect(attribute.linkedProductTypesCount, 2);
    expect(attribute.valueCount, 3);
    expect(attribute.isInUse, isTrue);
  });

  test('unknown or malformed usage remains unsafe', () {
    expect(
      AttributeModel.fromJson(payload(links: null)).toEntity().canDelete,
      isFalse,
    );
    expect(
      AttributeModel.fromJson(
        payload(
          values: const [
            {'count': 'unknown'},
          ],
        ),
      ).toEntity().canDelete,
      isFalse,
    );
  });

  test('rejects unknown data type', () {
    expect(
      () => AttributeModel.fromJson(payload(type: 'currency')),
      throwsFormatException,
    );
  });
}
