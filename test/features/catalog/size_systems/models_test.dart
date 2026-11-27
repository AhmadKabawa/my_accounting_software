import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_software/app/features/catalog/size_systems/groups/data/models/size_group_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/shared/data/embedded_count.dart';
import 'package:accounting_software/app/features/catalog/size_systems/sizes/data/models/catalog_size_model.dart';
import 'package:accounting_software/app/features/catalog/size_systems/systems/data/models/size_system_model.dart';

void main() {
  group('readEmbeddedCount', () {
    test('reads [{count: n}], a map, a number', () {
      expect(
        readEmbeddedCount([
          {'count': 3},
        ]),
        3,
      );
      expect(readEmbeddedCount({'count': 2}), 2);
      expect(readEmbeddedCount(5), 5);
    });

    test('missing or malformed is unknown, never zero', () {
      expect(readEmbeddedCount(null), isNull);
      expect(readEmbeddedCount(<dynamic>[]), isNull);
      expect(
        readEmbeddedCount([
          {'count': 'x'},
        ]),
        isNull,
      );
    });
  });

  group('SizeSystemModel', () {
    test('maps a row with a group count', () {
      final system = SizeSystemModel.fromJson({
        'id': 1,
        'name': 'European',
        'code': 'EU',
        'description': null,
        'is_active': true,
        'updated_at': '2026-11-25T10:00:00Z',
        'size_groups': [
          {'count': 0},
        ],
      }).toEntity();
      expect(system.groupCount, 0);
      expect(system.canDelete, isTrue);
      expect(system.updatedAt, isNotNull);
    });

    test('an unknown group count blocks deletion', () {
      final system = SizeSystemModel.fromJson({
        'id': 1,
        'name': 'European',
        'code': 'EU',
        'is_active': true,
      }).toEntity();
      expect(system.groupCount, isNull);
      expect(system.canDelete, isFalse);
    });

    test('a row without a valid id is rejected', () {
      expect(
        () => SizeSystemModel.fromJson({'name': 'x', 'code': 'X'}),
        throwsFormatException,
      );
    });
  });

  group('SizeGroupModel', () {
    Map<String, dynamic> row({Object? sizes, Object? types, Object? usage}) => {
      'id': 7,
      'size_system_id': 1,
      'gender_id': null,
      'name': "Men's shoes",
      'code': 'EU-M-SHOES',
      'is_active': true,
      'sizes': sizes,
      'product_type_size_groups': types,
      'product_size_groups': usage,
    };

    test('an empty gender is null, not an error', () {
      final group = SizeGroupModel.fromJson(row()).toEntity();
      expect(group.genderId, isNull);
    });

    test('deletable only when all three counts are known and zero', () {
      final ok = SizeGroupModel.fromJson(
        row(
          sizes: [
            {'count': 0},
          ],
          types: [
            {'count': 0},
          ],
          usage: [
            {'count': 0},
          ],
        ),
      ).toEntity();
      expect(ok.canDelete, isTrue);

      final hasSizes = SizeGroupModel.fromJson(
        row(
          sizes: [
            {'count': 2},
          ],
          types: [
            {'count': 0},
          ],
          usage: [
            {'count': 0},
          ],
        ),
      ).toEntity();
      expect(hasSizes.canDelete, isFalse);

      final linked = SizeGroupModel.fromJson(
        row(
          sizes: [
            {'count': 0},
          ],
          types: [
            {'count': 1},
          ],
          usage: [
            {'count': 0},
          ],
        ),
      ).toEntity();
      expect(linked.canDelete, isFalse);

      final unknownUsage = SizeGroupModel.fromJson(
        row(
          sizes: [
            {'count': 0},
          ],
          types: [
            {'count': 0},
          ],
        ),
      ).toEntity();
      expect(unknownUsage.canDelete, isFalse);
    });
  });

  group('GenderOptionModel', () {
    test('maps id, name and activity', () {
      final gender = GenderOptionModel.fromJson({
        'id': 2,
        'name': 'Women',
        'is_active': false,
      }).toEntity();
      expect(gender.id, 2);
      expect(gender.isActive, isFalse);
    });
  });

  group('CatalogSizeModel', () {
    Map<String, dynamic> row({Object? value, Object? usage}) => {
      'id': 5,
      'size_group_id': 7,
      'name': '36',
      'code': 'EU36',
      'numeric_value': value,
      'sort_order': 3,
      'is_active': true,
      'product_sizes': usage,
    };

    test('numeric_value parses from number, string and null exactly', () {
      expect(
        CatalogSizeModel.fromJson(row(value: 36.5)).numericValue,
        Decimal.parse('36.5'),
      );
      expect(
        CatalogSizeModel.fromJson(row(value: '36.50')).numericValue,
        Decimal.parse('36.5'),
      );
      expect(CatalogSizeModel.fromJson(row()).numericValue, isNull);
    });

    test('CAT07-SZ-AC5: deletable only with a known zero usage count', () {
      expect(
        CatalogSizeModel.fromJson(
          row(
            usage: [
              {'count': 0},
            ],
          ),
        ).toEntity().canDelete,
        isTrue,
      );
      expect(
        CatalogSizeModel.fromJson(
          row(
            usage: [
              {'count': 4},
            ],
          ),
        ).toEntity().canDelete,
        isFalse,
      );
      expect(CatalogSizeModel.fromJson(row()).toEntity().canDelete, isFalse);
    });
  });
}
