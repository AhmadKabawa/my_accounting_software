import 'package:accounting_software/app/features/catalog/genders/data/models/gender_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenderModel', () {
    test('maps gender fields and embedded size-group usage count', () {
      final model = GenderModel.fromJson({
        'id': 7,
        'name': 'Women',
        'code': 'W',
        'is_active': true,
        'sort_order': 2,
        'size_groups': [{'count': 4}],
      });
      final entity = model.toEntity();
      expect(entity.id, 7);
      expect(entity.name, 'Women');
      expect(entity.code, 'W');
      expect(entity.sortOrder, 2);
      expect(entity.sizeGroupCount, 4);
      expect(entity.canDelete, isFalse);
    });

    test('unknown usage count fails closed for deletion', () {
      final entity = GenderModel.fromJson({
        'id': 8,
        'name': 'Unisex',
        'code': 'U',
        'is_active': true,
        'sort_order': 0,
      }).toEntity();
      expect(entity.sizeGroupCount, isNull);
      expect(entity.canDelete, isFalse);
    });

    test('zero usage count permits deletion', () {
      final entity = GenderModel.fromJson({
        'id': 9,
        'name': 'Kids',
        'code': 'K',
        'is_active': false,
        'sort_order': 1,
        'size_groups': [{'count': 0}],
      }).toEntity();
      expect(entity.canDelete, isTrue);
    });
  });
}
