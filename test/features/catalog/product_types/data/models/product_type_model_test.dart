import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/product_types/data/models/product_type_model.dart';

void main() {
  group('ProductTypeModel.fromJson', () {
    test('maps fields and embedded usage counts', () {
      final model = ProductTypeModel.fromJson({
        'id': '12',
        'name': 'Shoes',
        'code': 'SHOE',
        'description': 'Footwear',
        'sort_order': 4,
        'is_active': false,
        'products': [
          {'count': 3},
        ],
        'product_type_size_groups': [
          {'count': 2},
        ],
        'product_type_attributes': [
          {'count': 1},
        ],
        'product_type_option_sets': [
          {'count': 0},
        ],
        'product_type_care_instructions': [
          {'count': 0},
        ],
        'updated_at': '2026-11-25T12:00:00Z',
      });

      expect(model.id, 12);
      expect(model.name, 'Shoes');
      expect(model.code, 'SHOE');
      expect(model.sortOrder, 4);
      expect(model.isActive, isFalse);
      expect(model.productCount, 3);
      expect(model.sizeGroupCount, 2);
      expect(model.attributeCount, 1);
      expect(model.optionSetCount, 0);
      expect(model.careInstructionCount, 0);
      expect(model.toEntity().canDelete, isFalse);
      expect(model.toEntity().codeLocked, isTrue);
    });

    test('keeps absent counts unknown instead of zero', () {
      final model = ProductTypeModel.fromJson({
        'id': 1,
        'name': 'Shirt',
        'code': 'SHIRT',
        'is_active': true,
      });

      expect(model.productCount, isNull);
      expect(model.sizeGroupCount, isNull);
      expect(model.toEntity().usageKnown, isFalse);
      expect(model.toEntity().canDelete, isFalse);
      expect(model.toEntity().codeLocked, isTrue);
    });

    test('link usage protects deletion and locks the code', () {
      final model = ProductTypeModel.fromJson({
        'id': 2,
        'name': 'Shirt',
        'code': 'SHIRT',
        'products': [
          {'count': 0},
        ],
        'product_type_size_groups': [
          {'count': 1},
        ],
        'product_type_attributes': [
          {'count': 0},
        ],
        'product_type_option_sets': [
          {'count': 0},
        ],
        'product_type_care_instructions': [
          {'count': 0},
        ],
      });

      expect(model.toEntity().canDelete, isFalse);
      expect(model.toEntity().codeLocked, isTrue);
    });

    test('treats empty embedded relations as zero', () {
      final model = ProductTypeModel.fromJson({
        'id': 1,
        'name': 'Shirt',
        'code': 'SHIRT',
        'products': <dynamic>[],
        'product_type_size_groups': <dynamic>[],
        'product_type_attributes': <dynamic>[],
        'product_type_option_sets': <dynamic>[],
        'product_type_care_instructions': <dynamic>[],
      });

      expect(model.toEntity().canDelete, isTrue);
      expect(model.toEntity().codeLocked, isFalse);
    });

    test('rejects an invalid identifier', () {
      expect(
        () => ProductTypeModel.fromJson({
          'id': 'not-an-id',
          'name': 'Shirt',
          'code': 'SHIRT',
        }),
        throwsFormatException,
      );
    });
  });
}
