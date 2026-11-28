import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/materials/data/models/material_model.dart';
import 'package:accounting_software/app/features/catalog/materials/domain/entity/material.dart';

void main() {
  group('MaterialModel', () {
    test('parses persisted columns and maps to entity', () {
      final model = MaterialModel.fromJson({
        'id': 7,
        'name': 'Cotton',
        'code': 'COT',
        'material_type': 'natural',
        'description': 'Natural fibre',
        'is_active': true,
      });
      expect(model.id, 7);
      expect(model.materialType, MaterialType.natural);
      expect(model.toEntity().name, 'Cotton');
      expect(model.toJson()['material_type'], 'natural');
    });
    test('parses known material type names and rejects unknown values', () {
      expect(MaterialType.tryParse('natural'), MaterialType.natural);
      expect(MaterialType.tryParse('synthetic'), MaterialType.synthetic);
      expect(MaterialType.tryParse('unknown'), isNull);
      expect(MaterialType.tryParse(null), isNull);
    });
    test('rejects invalid identifier', () {
      expect(
        () => MaterialModel.fromJson({
          'id': 'bad',
          'name': 'Cotton',
          'code': 'COT',
        }),
        throwsFormatException,
      );
    });
  });
}
