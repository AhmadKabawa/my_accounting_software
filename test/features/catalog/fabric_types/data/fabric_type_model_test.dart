import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/data/models/fabric_type_model.dart';
import 'package:accounting_software/app/features/catalog/fabric_types/domain/entity/fabric_type.dart';

void main() {
  group('FabricTypeModel', () {
    test('parses persisted columns and maps to entity', () {
      final model = FabricTypeModel.fromJson({
        'id': 9,
        'name': 'Jersey',
        'code': 'JER',
        'fabric_category': 'knit',
        'is_named_fabric': true,
        'description': 'Stretch knit',
        'is_active': true,
      });
      expect(model.id, 9);
      expect(model.fabricCategory, FabricCategory.knit);
      expect(model.isNamedFabric, isTrue);
      expect(model.toEntity().name, 'Jersey');
      expect(model.toJson()['is_named_fabric'], isTrue);
    });
    test('defaults nullable named flag to false', () {
      final model = FabricTypeModel.fromJson({
        'id': 3,
        'name': 'Twill',
        'code': 'TWL',
        'is_active': true,
      });
      expect(model.isNamedFabric, isFalse);
    });
  });
}
